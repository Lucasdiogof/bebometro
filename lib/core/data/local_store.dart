import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Durable on-device storage. Each collection is a map of id -> JSON row,
/// held in memory and written through to SharedPreferences.
///
/// Every write also records the row in a persisted "pending upload" set with
/// a version number, in the same synchronous step as the data itself, so a
/// saved row can never be missing from the queue. Uploading and clearing the
/// flag is done by the sync layer through [clearPending].
class LocalStore {
  LocalStore._(this._prefs) {
    for (final name in collections) {
      final map = <String, Map<String, dynamic>>{};
      final raw = _prefs.getString('col.$name');
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
    }
    for (final key in _prefs.getStringList(_pendingKey) ?? const <String>[]) {
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

  /// Upload order: parents before children.
  static const collections = [
    places,
    outings,
    customDrinks,
    outingDrinks,
    outingPhotos,
    drinkEntries,
  ];

  /// Collections whose rows point to an outing (`outing_id`).
  static const outingChildren = {outingDrinks, outingPhotos, drinkEntries};

  static const _pendingKey = 'sync.pending';

  static Future<LocalStore> open() async =>
      LocalStore._(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;
  final _data = <String, Map<String, Map<String, dynamic>>>{};
  final _pending = <String, int>{};
  final _changes = StreamController<String>.broadcast();
  int _seq = 0;

  /// Emits the collection name after every write.
  Stream<String> get changes => _changes.stream;

  Map<String, dynamic>? get(String collection, String id) =>
      _data[collection]![id];

  List<Map<String, dynamic>> all(String collection) =>
      _data[collection]!.values.toList();

  int count(String collection) => _data[collection]!.length;

  /// Pending uploads as "collection|id" -> version. Copy; safe to iterate.
  Map<String, int> get pending => Map<String, int>.of(_pending);

  int get pendingCount => _pending.length;

  Future<void> put(String collection, Map<String, dynamic> json) async {
    final id = json['id'] as String;
    _data[collection]![id] = json;
    _pending['$collection|$id'] = ++_seq;
    // Pending marker first: if the process dies in between, the worst case is
    // a redundant upload, never a lost one.
    await _prefs.setStringList(_pendingKey, _pending.keys.toList());
    await _prefs.setString(
      'col.$collection',
      jsonEncode(_data[collection]!.values.toList()),
    );
    _changes.add(collection);
  }

  /// Clears the pending flag only if the row was not written again since
  /// [version] was read, so an old upload never hides a newer local edit.
  Future<void> clearPending(String key, int version) async {
    if (_pending[key] != version) return;
    _pending.remove(key);
    await _prefs.setStringList(_pendingKey, _pending.keys.toList());
  }

  Set<String> getStringSet(String key) =>
      (_prefs.getStringList(key) ?? const <String>[]).toSet();

  Future<void> setStringSet(String key, Set<String> value) =>
      _prefs.setStringList(key, value.toList());

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
}
