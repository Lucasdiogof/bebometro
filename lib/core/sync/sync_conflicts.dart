import 'dart:async';
import 'dart:convert';

import '../data/local_store.dart';

enum ConflictKind {
  /// The same row changed here and on the server (revision check), or was
  /// deleted on the server while edited here.
  row,

  /// Two outings running: one from this device, one already on the server.
  activeOuting,
}

/// A change that could not be sent as it is and needs a choice. The local
/// version is kept here in full; nothing is lost while it waits.
class SyncConflict {
  const SyncConflict({
    required this.kind,
    required this.collection,
    required this.id,
    required this.local,
    this.remote,
    this.remoteRevision,
    this.otherId,
    required this.at,
  });

  final ConflictKind kind;
  final String collection;
  final String id;
  final Map<String, dynamic> local;

  /// Server version (null when it could not be read yet).
  final Map<String, dynamic>? remote;
  final int? remoteRevision;

  /// For [ConflictKind.activeOuting]: the outing running on the server.
  final String? otherId;
  final DateTime at;

  String get key => '${kind.name}|$collection|$id';

  bool get remoteDeleted => remote?['deleted_at'] != null;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'collection': collection,
        'id': id,
        'local': local,
        'remote': remote,
        'remote_revision': remoteRevision,
        'other_id': otherId,
        'at': at.toUtc().toIso8601String(),
      };

  static SyncConflict? fromJson(Map<String, dynamic> j) {
    try {
      return SyncConflict(
        kind: ConflictKind.values.byName(j['kind'] as String),
        collection: j['collection'] as String,
        id: j['id'] as String,
        local: Map<String, dynamic>.from(j['local'] as Map),
        remote: j['remote'] == null
            ? null
            : Map<String, dynamic>.from(j['remote'] as Map),
        remoteRevision: (j['remote_revision'] as num?)?.toInt(),
        otherId: j['other_id'] as String?,
        at: DateTime.parse(j['at'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

/// The account's list of "Alterações para resolver", persisted in the account
/// space (never in memory only).
class SyncConflicts {
  SyncConflicts(this._store) {
    final raw = _store.getString(_key);
    if (raw != null) {
      try {
        for (final j in jsonDecode(raw) as List) {
          final c = SyncConflict.fromJson(Map<String, dynamic>.from(j as Map));
          if (c != null) _items[c.key] = c;
        }
      } catch (_) {}
    }
  }

  static const _key = 'sync.conflicts';

  final LocalStore _store;
  final _items = <String, SyncConflict>{};
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  List<SyncConflict> get all => _items.values.toList()
    ..sort((a, b) => a.at.compareTo(b.at));

  int get count => _items.length;

  bool isHeld(String collection, String id) =>
      _items.values.any((c) => c.collection == collection && c.id == id);

  Future<void> add(SyncConflict c) async {
    _items[c.key] = c;
    await _save();
  }

  Future<void> remove(SyncConflict c) async {
    _items.remove(c.key);
    await _save();
  }

  Future<void> _save() async {
    await _store.setString(
        _key, jsonEncode([for (final c in _items.values) c.toJson()]));
    if (!_changes.isClosed) _changes.add(null);
  }

  /// Keeps this device's version: queued again on top of the server revision,
  /// so the next send is accepted (and, for a row deleted on the server,
  /// restores it on purpose).
  Future<void> keepLocal(SyncConflict c) async {
    if (c.remoteRevision != null) {
      await _store.setRevisions(c.collection, {c.id: c.remoteRevision!});
    }
    await _store.put(c.collection, {
      ...c.local,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    await remove(c);
  }

  /// Uses the server's version; the local edit is discarded by the person's
  /// choice.
  Future<void> useRemote(SyncConflict c) async {
    final remote = c.remote;
    if (remote != null) {
      await _store.replaceWithRemote(c.collection, remote, c.remoteRevision ?? 0);
    }
    await remove(c);
  }

  void dispose() => _changes.close();
}
