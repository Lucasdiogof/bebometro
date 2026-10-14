import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Durable on-device storage of ONE account. Each collection is a map of
/// id -> JSON row, held in memory and written through to SharedPreferences
/// under the account namespace (`acct.<userId>.`). Keys of the old,
/// pre-account layout (no prefix) are never read nor deleted.
///
/// Every local write also records the row in a persisted "pending upload" set
/// with a version number, in the same step as the data itself, so a saved row
/// can never be missing from the queue. Rows that come FROM the server are
/// written with [putRemote], which never queues them again and never
/// overwrites a row that still has a local edit waiting.
///
/// After [close] (account switched or signed out) every write is ignored, so a
/// late answer of the previous session cannot repopulate anything.
class LocalStore {
  LocalStore._(this._prefs, this.namespace) {
    for (final name in collections) {
      final map = <String, Map<String, dynamic>>{};
      final raw = _prefs.getString(_k('col.$name'));
      if (raw != null) {
        try {
          for (final row in jsonDecode(raw) as List) {
            final json = Map<String, dynamic>.from(row as Map);
            map[json['id'] as String] = json;
          }
        } catch (_) {
          // A corrupted collection starts empty rather than blocking the app.
        }
      }
      _data[name] = map;
      final revs = <String, int>{};
      final rawRev = _prefs.getString(_k('rev.$name'));
      if (rawRev != null) {
        try {
          (jsonDecode(rawRev) as Map).forEach((k, v) {
            if (v is num) revs[k as String] = v.toInt();
          });
        } catch (_) {}
      }
      _revisions[name] = revs;
    }
    for (final key in _prefs.getStringList(_k(_pendingKey)) ?? const <String>[]) {
      _pending[key] = ++_seq;
    }
  }

  static const places = 'places';
  static const outings = 'outings';
  static const customDrinks = 'custom_drinks';
  static const drinkEntries = 'drink_entries';

  /// Drinks and photos that belong to a single outing (label, menu, manual).
  static const outingDrinks = 'outing_drinks';
  static const outingPhotos = 'outing_photos';

  /// The tab (comanda) of an outing: one document per outing, id = outing id.
  static const outingTabs = 'outing_tabs';

  /// Upload order: parents before children.
  static const collections = [
    places,
    outings,
    customDrinks,
    outingDrinks,
    outingPhotos,
    outingTabs,
    drinkEntries,
  ];

  /// Collections whose rows point to an outing (`outing_id`).
  static const outingChildren = {
    outingDrinks,
    outingPhotos,
    outingTabs,
    drinkEntries,
  };

  static const _pendingKey = 'sync.pending';

  /// The account space of [userId].
  static Future<LocalStore> openAccount(String userId) async =>
      LocalStore._(await SharedPreferences.getInstance(), accountPrefix(userId));

  static String accountPrefix(String userId) => 'acct.$userId.';

  final SharedPreferences _prefs;

  /// Key prefix of this space.
  final String namespace;
  final _data = <String, Map<String, Map<String, dynamic>>>{};
  final _revisions = <String, Map<String, int>>{};
  final _pending = <String, int>{};
  final _changes = StreamController<String>.broadcast();
  int _seq = 0;
  bool _closed = false;

  String _k(String key) => '$namespace$key';

  bool get isClosed => _closed;

  void _emit(String collection) {
    if (!_closed) _changes.add(collection);
  }

  /// Emits the collection name after every write.
  Stream<String> get changes => _changes.stream;

  Map<String, dynamic>? get(String collection, String id) =>
      _data[collection]![id];

  List<Map<String, dynamic>> all(String collection) =>
      _data[collection]!.values.toList();

  int count(String collection) => _data[collection]!.length;

  bool get isEmpty => collections.every((c) => _data[c]!.isEmpty);

  /// Pending uploads as "collection|id" -> version. Copy; safe to iterate.
  Map<String, int> get pending => Map<String, int>.of(_pending);

  int get pendingCount => _pending.length;

  bool isPending(String collection, String id) =>
      _pending.containsKey('$collection|$id');

  /// Server revision last seen for a row (null = never confirmed).
  int? revisionOf(String collection, String id) => _revisions[collection]![id];

  Future<void> put(String collection, Map<String, dynamic> json) async {
    if (_closed) return;
    final id = json['id'] as String;
    _data[collection]![id] = json;
    _pending['$collection|$id'] = ++_seq;
    // Pending marker first: if the process dies in between, the worst case is
    // a redundant upload, never a lost one.
    await _prefs.setStringList(_k(_pendingKey), _pending.keys.toList());
    await _persist(collection);
    _emit(collection);
  }

  /// Rows read from the server (already stripped of server-only columns).
  /// A row with a local edit still waiting is left alone: the upload decides
  /// (and reports a conflict if the server moved on). Returns how many rows
  /// were applied. Nothing is queued for upload.
  Future<int> putRemote(
    String collection,
    List<({Map<String, dynamic> json, int revision})> rows,
  ) async {
    if (_closed || rows.isEmpty) return 0;
    var applied = 0;
    for (final r in rows) {
      final id = r.json['id'] as String;
      if (_pending.containsKey('$collection|$id')) continue;
      final known = _revisions[collection]![id];
      if (known != null && known >= r.revision && _data[collection]![id] != null) {
        continue; // already have this (or a newer) version
      }
      _data[collection]![id] = r.json;
      _revisions[collection]![id] = r.revision;
      applied++;
    }
    await _persist(collection);
    await _persistRevisions(collection);
    if (applied > 0) _emit(collection);
    return applied;
  }

  /// Records the revisions the server returned after an upload.
  Future<void> setRevisions(String collection, Map<String, int> revs) async {
    if (_closed || revs.isEmpty) return;
    _revisions[collection]!.addAll(revs);
    await _persistRevisions(collection);
  }

  /// Clears the pending flag only if the row was not written again since
  /// [version] was read, so an old upload never hides a newer local edit.
  Future<void> clearPending(String key, int version) async {
    if (_closed) return;
    if (_pending[key] != version) return;
    _pending.remove(key);
    await _prefs.setStringList(_k(_pendingKey), _pending.keys.toList());
  }

  /// Takes a row out of the queue regardless of version (it went to the list
  /// of changes to resolve, which keeps the local copy).
  Future<void> dropPending(String collection, String id) async {
    if (_closed) return;
    if (_pending.remove('$collection|$id') == null) return;
    await _prefs.setStringList(_k(_pendingKey), _pending.keys.toList());
  }

  /// Replaces a row with the server version chosen by the person, without
  /// queueing it.
  Future<void> replaceWithRemote(
      String collection, Map<String, dynamic> json, int revision) async {
    if (_closed) return;
    final id = json['id'] as String;
    _pending.remove('$collection|$id');
    _data[collection]![id] = json;
    _revisions[collection]![id] = revision;
    await _prefs.setStringList(_k(_pendingKey), _pending.keys.toList());
    await _persist(collection);
    await _persistRevisions(collection);
    _emit(collection);
  }

  Future<void> _persist(String collection) => _prefs.setString(
        _k('col.$collection'),
        jsonEncode(_data[collection]!.values.toList()),
      );

  Future<void> _persistRevisions(String collection) => _prefs.setString(
        _k('rev.$collection'),
        jsonEncode(_revisions[collection]),
      );

  Set<String> getStringSet(String key) =>
      (_prefs.getStringList(_k(key)) ?? const <String>[]).toSet();

  Future<void> setStringSet(String key, Set<String> value) async {
    if (_closed) return;
    await _prefs.setStringList(_k(key), value.toList());
  }

  String? getString(String key) => _prefs.getString(_k(key));

  Future<void> setString(String key, String value) async {
    if (_closed) return;
    await _prefs.setString(_k(key), value);
  }

  Future<void> remove(String key) async {
    if (_closed) return;
    await _prefs.remove(_k(key));
  }

  /// Stops accepting writes and events. Data on disk stays.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _changes.close();
  }
}
