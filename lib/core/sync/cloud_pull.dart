import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_store.dart';

class PullProgress {
  const PullProgress(this.collection, this.received, this.done);

  /// Collection being read.
  final String collection;

  /// Rows received so far in this run (all collections).
  final int received;
  final bool done;
}

/// Reads the account's rows from Supabase into the account space.
///
/// * Keyset pagination on `(server_updated_at, id)`, [pageSize] rows per page,
///   until a short page: never just the first batch.
/// * `server_updated_at` and `revision` are set by the server (trigger), never
///   by the phone's clock. Each run starts [lookback] before the saved cursor,
///   because a transaction that committed late can carry an earlier
///   timestamp; reading a row twice is harmless ([LocalStore.putRemote] skips
///   revisions it already has).
/// * The cursor of a collection only moves after its page is on disk, so a
///   failure in the middle resumes from the last stored page.
/// * Deletions are rows with `deleted_at` (tombstones) and arrive the same way.
/// * Rows with a local edit waiting are not overwritten; the upload's revision
///   check decides.
/// * Nothing read here is queued for upload.
class CloudPull {
  CloudPull(this._store);

  final LocalStore _store;

  static const pageSize = 500;
  static const lookback = Duration(minutes: 2);
  static const _serverOnly = {
    'owner_id',
    'revision',
    'server_updated_at',
    'base_revision',
  };
  static const completeKey = 'pull.complete';

  bool get everCompleted => _store.getString(completeKey) == '1';

  String _cursorKey(String c) => 'pull.cursor.$c';

  /// PostgREST prints `+00:00`; a `+` would be read as a space in the query
  /// string, so filters use the `Z` form.
  static String _z(String ts) => DateTime.parse(ts).toUtc().toIso8601String();

  Future<int> run(
    SupabaseClient client,
    String userId, {
    void Function(PullProgress)? onProgress,
    required bool Function() cancelled,
  }) async {
    var received = 0;
    for (final collection in LocalStore.collections) {
      String? lastTs;
      String? lastId;
      final cursor = _store.getString(_cursorKey(collection));
      String? since;
      if (cursor != null) {
        final ts = cursor.split('|').first;
        since = DateTime.parse(ts).toUtc().subtract(lookback).toIso8601String();
      }
      while (true) {
        if (cancelled()) return received;
        var q = client.from(collection).select().eq('owner_id', userId);
        if (lastTs != null) {
          q = q.or(
            'server_updated_at.gt.$lastTs,'
            'and(server_updated_at.eq.$lastTs,id.gt.$lastId)',
          );
        } else if (since != null) {
          q = q.gte('server_updated_at', since);
        }
        final page = await q
            .order('server_updated_at', ascending: true)
            .order('id', ascending: true)
            .limit(pageSize);
        if (cancelled()) return received;
        final rows = <({Map<String, dynamic> json, int revision})>[];
        for (final raw in page) {
          final r = Map<String, dynamic>.from(raw);
          final rev = (r['revision'] as num?)?.toInt() ?? 0;
          r.removeWhere((k, _) => _serverOnly.contains(k));
          rows.add((json: r, revision: rev));
        }
        await _store.putRemote(collection, rows);
        received += rows.length;
        if (page.isNotEmpty) {
          final last = page.last;
          lastTs = _z(last['server_updated_at'] as String);
          lastId = last['id'] as String;
          // Persisted only now that the page is stored.
          await _store.setString(_cursorKey(collection), '$lastTs|$lastId');
        }
        onProgress?.call(PullProgress(collection, received, false));
        if (page.length < pageSize) break;
      }
    }
    await _store.setString(completeKey, '1');
    onProgress?.call(PullProgress('', received, true));
    return received;
  }
}
