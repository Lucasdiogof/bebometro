import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_store.dart';
import 'cloud_pull.dart';
import 'pending_uploads.dart';
import 'sync_conflicts.dart';
import '../../l10n/l10n.dart';

enum SyncStatus {
  /// Everything saved on the device was confirmed by the server.
  synced,

  /// Changes saved on the device are waiting to be sent.
  pending,
  syncing,

  /// Offline or the server refused something; will retry.
  failed,

  /// Cloud sync is not available right now (no valid session for this
  /// account, or the cloud could not start). Data stays on this device.
  localOnly,
}

/// Why the sync is not "all saved", as a code. [text] is in the language on
/// screen.
enum SyncNotice {
  localOnly,
  signInAgain,
  activeConflict,
  placeLink,
  rejected,
  waitingPlace,
  schemaGap,
  offline,
  photosPending;

  String get text => switch (this) {
        SyncNotice.localOnly => tr.syncNoticeLocalOnly,
        SyncNotice.signInAgain => tr.syncNoticeSignInAgain,
        SyncNotice.activeConflict => tr.syncNoticeActiveConflict,
        SyncNotice.placeLink => tr.syncNoticePlaceLink,
        SyncNotice.rejected => tr.syncNoticeRejected,
        SyncNotice.waitingPlace => tr.syncNoticeWaitingPlace,
        SyncNotice.schemaGap => tr.syncNoticeSchemaGap,
        SyncNotice.offline => tr.syncNoticeOffline,
        SyncNotice.photosPending => tr.syncNoticePhotos,
      };
}

class SyncState {
  const SyncState(
    this.status, {
    this.pending = 0,
    this.lastSyncAt,
    this.notice,
    this.conflicts = 0,
    this.restoring = false,
    this.restoredRows = 0,
    this.restoreFailed = false,
    this.historyRestored = true,
  });

  final SyncStatus status;
  final int pending;

  /// Changes waiting for the person's choice ("Alterações para resolver").
  final int conflicts;

  /// Reading the account's history from the cloud right now.
  final bool restoring;
  final int restoredRows;

  /// The last read from the cloud failed (retry offered).
  final bool restoreFailed;

  /// The first full read of this account on this device finished. Until then
  /// an empty history is "not recovered yet", never "nothing here".
  final bool historyRestored;

  /// Everything on the device is confirmed in the cloud, with nothing waiting
  /// and nothing to resolve.
  bool get allSaved =>
      status == SyncStatus.synced && pending == 0 && conflicts == 0;
  final DateTime? lastSyncAt;

  /// Short, user-facing explanation (a code; the text is produced in the
  /// language on screen). Technical details go to the debug log.
  final SyncNotice? notice;

  String? get message => notice?.text;

  String get label {
    switch (status) {
      case SyncStatus.synced:
        return conflicts > 0 ? tr.syncLabelConflicts(conflicts) : tr.syncLabelSynced;
      case SyncStatus.pending:
        return tr.syncLabelPending(pending);
      case SyncStatus.syncing:
        return tr.syncLabelSyncing;
      case SyncStatus.failed:
        return tr.syncLabelFailed;
      case SyncStatus.localOnly:
        return tr.syncLabelLocalOnly;
    }
  }
}

/// Sends locally saved rows to Supabase, then reads back what changed there.
///
/// Writes always land on the device first ([LocalStore] keeps a durable queue
/// of pending rows). This class drains that queue: one run at a time, parents
/// before children, upserting by client-generated UUID so a retry never
/// duplicates anything. Deletions are soft (`deleted_at`) and travel the same
/// way. A row is only dropped from the queue after the server confirmed it and
/// only if it was not edited again in the meantime.
class SyncCubit extends Cubit<SyncState> {
  SyncCubit(
    this._store, {
    required this.cloudEnabled,
    required this.userId,
    required this.conflicts,
    this.uploads,
  })  : _pull = CloudPull(_store),
        super(const SyncState(SyncStatus.synced)) {
    _lastSyncAt = _parseTime(_store.getString(_lastSyncKey));
    _sub = _store.changes.listen((_) => schedule());
    _conflictSub = conflicts.changes.listen((_) => _emitIdle());
    _emitIdle();
  }

  static const _lastSyncKey = 'sync.last_at';

  final LocalStore _store;
  final bool cloudEnabled;

  /// The account this sync belongs to. A run whose session is no longer this
  /// user stops without writing anything.
  final String userId;
  final SyncConflicts conflicts;
  final CloudPull _pull;
  late final StreamSubscription<void> _conflictSub;
  bool _restoring = false;
  int _restoredRows = 0;
  bool _restoreFailed = false;

  /// Whether the server has the revision columns (migration 20261018000000).
  /// Without them rows still go up as before, without conflict detection,
  /// and reading back is off.
  bool _serverRevisions = false;
  bool _probed = false;

  /// Extra work after the rows (private photo uploads); optional.
  final PendingUploads? uploads;
  late final StreamSubscription<String> _sub;

  Timer? _debounce;
  Timer? _retry;
  Future<void>? _running;
  bool _again = false;
  int _failures = 0;
  DateTime? _lastSyncAt;
  String? _lastMessage;
  SyncStatus? _lastProblem;

  /// Rows waiting plus photos waiting to be sent or removed on the server.
  int get _pendingTotal => _store.pendingCount + (uploads?.waiting ?? 0);

  /// Starts the first sync after launch.
  void start() => schedule(immediate: true);

  /// Debounced sync request; safe to call as often as needed.
  void schedule({bool immediate = false}) {
    if (isClosed) return;
    if (_running == null) _emitIdle();
    if (!cloudEnabled) return;
    _debounce?.cancel();
    _debounce = Timer(
      immediate ? Duration.zero : const Duration(milliseconds: 800),
      () => flush(),
    );
  }

  /// "Sincronizar agora": runs immediately and completes when the run ends.
  Future<void> syncNow() {
    _debounce?.cancel();
    _retry?.cancel();
    _failures = 0; // an explicit request should not wait on the backoff
    return flush();
  }

  /// Runs one sync; concurrent callers share the run in progress and a new
  /// run is queued if something changed meanwhile.
  Future<void> flush() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final run = _run().whenComplete(() {
      _running = null;
      if (_again && !isClosed) {
        _again = false;
        schedule();
      }
    });
    _running = run;
    return run;
  }

  /// Every state carries the conflict and restore fields.
  @override
  void emit(SyncState state) {
    if (isClosed) return;
    super.emit(SyncState(
      state.status,
      pending: state.pending,
      lastSyncAt: state.lastSyncAt,
      notice: state.notice,
      conflicts: conflicts.count,
      restoring: _restoring,
      restoredRows: _restoredRows,
      restoreFailed: _restoreFailed,
      historyRestored:
          _pull.everCompleted || !cloudEnabled || (_probed && !_serverRevisions),
    ));
  }

  void _emitIdle() {
    if (isClosed) return;
    final pending = _pendingTotal;
    if (!cloudEnabled) {
      emit(SyncState(
        SyncStatus.localOnly,
        pending: pending,
        lastSyncAt: _lastSyncAt,
        notice: SyncNotice.localOnly,
      ));
    } else if (_lastProblem != null &&
        (pending > 0 || _lastProblem == SyncStatus.localOnly)) {
      emit(SyncState(
        _lastProblem!,
        pending: pending,
        lastSyncAt: _lastSyncAt,
        notice: _lastMessage,
      ));
    } else {
      emit(SyncState(
        pending > 0 ? SyncStatus.pending : SyncStatus.synced,
        pending: pending,
        lastSyncAt: _lastSyncAt,
      ));
    }
  }

  void _problem(SyncStatus status, SyncNotice notice,
      {required Duration retryIn}) {
    _lastProblem = status;
    _lastMessage = notice;
    emit(SyncState(
      status,
      pending: _pendingTotal,
      lastSyncAt: _lastSyncAt,
      notice: notice,
    ));
    _retry?.cancel();
    _retry = Timer(retryIn, () => flush());
  }

  Duration get _backoff {
    final seconds = 30 * (1 << (_failures > 4 ? 4 : _failures));
    return Duration(seconds: seconds > 300 ? 300 : seconds);
  }

  Future<void> _run() async {
    _retry?.cancel();
    if (!cloudEnabled) {
      _emitIdle();
      return;
    }
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      // Never signs in by itself (no anonymous fallback). No session for THIS
      // account means: keep everything local until the person signs in again.
      if (user == null || user.id != userId || user.isAnonymous) {
        _problem(SyncStatus.localOnly, SyncNotice.signInAgain,
            retryIn: const Duration(minutes: 5));
        return;
      }
      bool stale() => isClosed || client.auth.currentUser?.id != userId;
      await _probeRevisions(client);
      if (stale()) return;

      final snapshot = _store.pending;
      if (snapshot.isEmpty) {
        await _runUploads(client, user.id);
        if (stale()) return;
        await _runPull(client, stale);
        _finishAfterUploads();
        return;
      }
      emit(SyncState(SyncStatus.syncing,
          pending: snapshot.length, lastSyncAt: _lastSyncAt));

      final failedOutings = <String>{};
      var rejected = 0;
      var activeConflict = false;
      // The server refused to link an outing to its place (FK or the same-owner
      // trigger). Never worked around: the outing stays pending as it is.
      var placeLinkError = false;
      // Places the server has not confirmed (pending, rejected or table absent).
      final unconfirmedPlaces = <String>{};
      // Outings waiting for their place; their drinks wait with them.
      final heldOutings = <String>{};
      var held = 0;
      // Rows whose newer columns/tables do not exist on the server yet: the
      // compatible part is sent, the row stays pending for a later full send.
      var schemaGaps = 0;

      for (final collection in LocalStore.collections) {
        final prefix = '$collection|';
        final rows = <Map<String, dynamic>>[];
        final versions = <String, int>{};

        for (final entry in snapshot.entries) {
          if (!entry.key.startsWith(prefix)) continue;
          final id = entry.key.substring(prefix.length);
          final row = _store.get(collection, id);
          if (row == null) {
            await _store.clearPending(entry.key, entry.value);
            continue;
          }
          if (conflicts.isHeld(collection, id)) continue; // waiting for a choice
          if (LocalStore.outingChildren.contains(collection) &&
              failedOutings.contains(row['outing_id'])) {
            rejected++; // its outing is not on the server yet
            continue;
          }
          if (LocalStore.outingChildren.contains(collection) &&
              heldOutings.contains(row['outing_id'])) {
            held++;
            continue;
          }
          if (collection == LocalStore.outings &&
              unconfirmedPlaces.contains(row['place_id'])) {
            // Keep the link: wait until the place is confirmed, send nothing.
            heldOutings.add(id);
            held++;
            continue;
          }
          rows.add(_wire(collection, id, row, user.id));
          versions[id] = entry.value;
        }
        if (rows.isEmpty) continue;

        if (collection == LocalStore.outings) {
          // Finish old outings before an active one is written, so the
          // "one active outing" rule is never violated by ordering.
          rows.sort((a, b) =>
              (a['status'] == 'active' ? 1 : 0) -
              (b['status'] == 'active' ? 1 : 0));
        }

        final acked = <String>{};
        Future<void> ack(String id) async {
          await _store.clearPending('$prefix$id', versions[id]!);
          acked.add(id);
        }

        try {
          await _upsert(client, collection, rows);
          if (stale()) return;
          for (final row in rows) {
            await ack(row['id'] as String);
          }
        } on PostgrestException catch (e) {
          _log('batch upsert on $collection failed: ${e.code} ${e.message}');
          // Isolate the offending row(s); the others still go through.
          for (final row in rows) {
            final id = row['id'] as String;
            try {
              await _upsert(client, collection, [row]);
              if (stale()) return;
              await ack(id);
            } on PostgrestException catch (e) {
              _log('row $collection/$id rejected: ${e.code} ${e.message}');
              if (_tableMissing(e)) {
                schemaGaps++; // whole table absent: keep the row pending
                continue;
              }
              if (e.code == 'PT409') {
                // Changed on the server since this device last saw it: kept
                // aside for the person, never overwritten either way.
                await _recordRowConflict(client, collection, id);
                continue;
              }
              if (collection == LocalStore.outings &&
                  e.code == '23505' &&
                  row['status'] == 'active') {
                // Another outing is running on the server (started offline on
                // another device). Both are kept; the person chooses.
                await _recordActiveConflict(client, id, user.id);
                failedOutings.add(id);
                continue;
              }
              if (collection == LocalStore.outings &&
                  (e.code == '23503' || e.code == 'P0001')) {
                // Place link refused (missing place or owner mismatch): the
                // row, its place_id and its drinks stay as they are.
                placeLinkError = true;
                rejected++;
                failedOutings.add(id);
                continue;
              }
              if (_columnGap(e, collection)) {
                final core = _withoutOptionalColumns(collection, row);
                if (core != null) {
                  try {
                    await client.from(collection).upsert(core);
                    schemaGaps++; // not acked: the full row is retried later
                    continue;
                  } on PostgrestException catch (e2) {
                    _log('core row $collection/$id rejected: ${e2.code}');
                  }
                }
              }
              rejected++;
              if (collection == LocalStore.outings) {
                failedOutings.add(id);
                if (e.code == '23505') activeConflict = true;
              }
            }
          }
        }
        if (collection == LocalStore.places) {
          for (final row in rows) {
            final id = row['id'] as String;
            if (!acked.contains(id)) unconfirmedPlaces.add(id);
          }
        }
      }

      // Reading back never waits for the upload problems to be solved: the
      // history of other devices must arrive even with a row stuck here.
      if (stale()) return;
      await _runPull(client, stale);

      if (rejected > 0) {
        _failures++;
        _problem(
          SyncStatus.failed,
          activeConflict
              ? SyncNotice.activeConflict
              : placeLinkError
                  ? SyncNotice.placeLink
                  : SyncNotice.rejected,
          retryIn: _backoff,
        );
        return;
      }

      if (held > 0 && schemaGaps == 0) {
        _problem(
          SyncStatus.pending,
          SyncNotice.waitingPlace,
          retryIn: _backoff,
        );
        return;
      }

      if (schemaGaps == 0) await _runUploads(client, user.id);
      if (stale()) return;

      if (schemaGaps > 0) {
        _problem(
          SyncStatus.pending,
          SyncNotice.schemaGap,
          retryIn: const Duration(minutes: 5),
        );
        return;
      }

      _finishAfterUploads();
    } on AuthException catch (e) {
      _log('auth/network error: ${e.message}');
      _failures++;
      _problem(SyncStatus.failed, SyncNotice.offline,
          retryIn: _backoff);
    } catch (e, st) {
      _log('sync error: $e\n$st');
      _failures++;
      _problem(SyncStatus.failed, SyncNotice.offline,
          retryIn: _backoff);
    }
  }

  /// "Synced" only when nothing is left: rows edited meanwhile get another
  /// pass, and photos that could not be sent keep the state at "pending".
  void _finishAfterUploads() {
    if (_store.pendingCount > 0) {
      // An upload changed a photo row, or a row was edited while syncing.
      _again = true;
      _emitIdle();
      return;
    }
    if ((uploads?.waiting ?? 0) > 0) {
      _failures++;
      _problem(
        SyncStatus.pending,
        SyncNotice.photosPending,
        retryIn: _backoff,
      );
      return;
    }
    _finishOk();
  }

  /// Photo uploads never block or fail the structured sync.
  Future<void> _runUploads(SupabaseClient client, String ownerId) async {
    final extra = uploads;
    if (extra == null) return;
    try {
      await extra.run(client, ownerId);
    } catch (e) {
      _log('uploads failed: $e');
    }
  }

  static const _optionalColumns = {
    'outings': [
      'place_id',
      'city',
      'state',
      'budget_cents',
      'feedback_wake',
      'feedback_hangover',
      'feedback_note',
      'place_name',
      'latitude',
      'longitude',
    ],
    // Map/search fields of saved places (migration 20261017000000).
    'places': [
      'provider_name',
      'latitude',
      'longitude',
      'location_source',
      'provider',
      'provider_place_id',
    ],
    'drink_entries': ['composition', 'abv_source'],
    'custom_drinks': ['components'],
  };

  static const _serverOnly = {
    'owner_id',
    'revision',
    'server_updated_at',
    'base_revision',
  };

  /// Row as sent: local-only keys out, owner and the revision this edit was
  /// based on in (only when the server checks revisions).
  Map<String, dynamic> _wire(
      String collection, String id, Map<String, dynamic> row, String owner) {
    final out = <String, dynamic>{
      for (final e in row.entries)
        if (!e.key.startsWith('_') && !_serverOnly.contains(e.key))
          e.key: e.value,
      'owner_id': owner,
    };
    if (_serverRevisions) {
      out['base_revision'] = _store.revisionOf(collection, id);
    }
    return out;
  }

  Future<void> _upsert(
    SupabaseClient client,
    String collection,
    List<Map<String, dynamic>> rows,
  ) async {
    if (!_serverRevisions) {
      await client.from(collection).upsert(rows);
      return;
    }
    final back =
        await client.from(collection).upsert(rows).select('id, revision');
    await _store.setRevisions(collection, {
      for (final r in back)
        r['id'] as String: (r['revision'] as num).toInt(),
    });
  }

  Future<void> _probeRevisions(SupabaseClient client) async {
    if (_serverRevisions) return;
    try {
      await client.from(LocalStore.outings).select('revision').limit(1);
      _serverRevisions = true;
      _probed = true;
    } on PostgrestException catch (e) {
      if (!_columnGap(e, LocalStore.outings)) rethrow;
      _serverRevisions = false;
      _probed = true;
    }
  }

  Map<String, dynamic> _clean(Map<String, dynamic> r) =>
      Map<String, dynamic>.from(r)..removeWhere((k, _) => _serverOnly.contains(k));

  Future<void> _recordRowConflict(
      SupabaseClient client, String collection, String id) async {
    final local = _store.get(collection, id);
    if (local == null) return;
    Map<String, dynamic>? remote;
    int? rev;
    try {
      final r =
          await client.from(collection).select().eq('id', id).maybeSingle();
      if (r != null) {
        rev = (r['revision'] as num?)?.toInt();
        remote = _clean(r);
      }
    } catch (e) {
      _log('could not read remote $collection/$id: $e');
    }
    await conflicts.add(SyncConflict(
      kind: ConflictKind.row,
      collection: collection,
      id: id,
      local: local,
      remote: remote,
      remoteRevision: rev,
      at: DateTime.now(),
    ));
    await _store.dropPending(collection, id);
  }

  Future<void> _recordActiveConflict(
      SupabaseClient client, String localId, String owner) async {
    final local = _store.get(LocalStore.outings, localId);
    if (local == null) return;
    String? otherId;
    try {
      final r = await client
          .from(LocalStore.outings)
          .select()
          .eq('owner_id', owner)
          .eq('status', 'active')
          .neq('id', localId)
          .maybeSingle();
      if (r != null) {
        otherId = r['id'] as String;
        final rev = (r['revision'] as num?)?.toInt() ?? 0;
        // Brought here so the person can see and choose it.
        await _store.putRemote(
            LocalStore.outings, [(json: _clean(r), revision: rev)]);
      }
    } catch (e) {
      _log('could not read the other active outing: $e');
    }
    await conflicts.add(SyncConflict(
      kind: ConflictKind.activeOuting,
      collection: LocalStore.outings,
      id: localId,
      local: local,
      otherId: otherId,
      at: DateTime.now(),
    ));
    await _store.dropPending(LocalStore.outings, localId);
  }

  /// Reads the account's rows back (first login on a device, changes made on
  /// other devices, deletions). A failure here never fails the upload side.
  Future<void> _runPull(SupabaseClient client, bool Function() stale) async {
    if (!_serverRevisions) return;
    _restoring = true;
    _restoreFailed = false;
    _emitIdle();
    try {
      await _pull.run(
        client,
        userId,
        cancelled: stale,
        onProgress: (p) {
          _restoredRows = p.received;
          if (!stale()) _emitIdle();
        },
      );
    } catch (e) {
      _log('pull failed: $e');
      _restoreFailed = true;
    } finally {
      _restoring = false;
    }
  }

  /// "Tentar de novo" on the restore screen.
  Future<void> retryRestore() => syncNow();


  bool _tableMissing(PostgrestException e) =>
      e.code == 'PGRST205' || e.code == '42P01';

  /// A column the server does not have. Place-link errors (23503, P0001) are
  /// deliberately not here: P0001 is a generic exception code and the outing
  /// must not lose its place_id to get past a validation.
  bool _columnGap(PostgrestException e, String collection) =>
      e.code == 'PGRST204' || e.code == '42703';

  /// The row without its newer optional columns, or null if it had none.
  Map<String, dynamic>? _withoutOptionalColumns(
    String collection,
    Map<String, dynamic> row,
  ) {
    final optional = _optionalColumns[collection];
    if (optional == null || !optional.any(row.containsKey)) return null;
    return {
      for (final e in row.entries)
        if (!optional.contains(e.key)) e.key: e.value,
    };
  }

  void _finishOk() {
    _failures = 0;
    _lastProblem = null;
    _lastMessage = null;
    _lastSyncAt = DateTime.now();
    unawaited(_store.setString(_lastSyncKey, _lastSyncAt!.toIso8601String()));
    emit(SyncState(SyncStatus.synced, lastSyncAt: _lastSyncAt));
  }

  DateTime? _parseTime(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw)?.toLocal();

  void _log(String message) {
    if (kDebugMode) debugPrint('[sync] $message');
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _retry?.cancel();
    _sub.cancel();
    _conflictSub.cancel();
    return super.close();
  }
}
