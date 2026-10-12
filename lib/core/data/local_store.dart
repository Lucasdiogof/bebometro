import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Durable on-device storage. Each collection is a map of id -> JSON row,
/// held in memory and written through to SharedPreferences.
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
  }

  static const outings = 'outings';
  static const customDrinks = 'custom_drinks';
  static const drinkEntries = 'drink_entries';

  /// Sync order matters: parents before children.
  static const collections = [outings, customDrinks, drinkEntries];

  static Future<LocalStore> open() async =>
      LocalStore._(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;
  final _data = <String, Map<String, Map<String, dynamic>>>{};
  final _changes = StreamController<String>.broadcast();

  /// Emits the collection name after every write.
  Stream<String> get changes => _changes.stream;

  Map<String, dynamic>? get(String collection, String id) =>
      _data[collection]![id];

  List<Map<String, dynamic>> all(String collection) =>
      _data[collection]!.values.toList();

  Future<void> put(String collection, Map<String, dynamic> json) async {
    _data[collection]![json['id'] as String] = json;
    await _prefs.setString(
      'col.$collection',
      jsonEncode(_data[collection]!.values.toList()),
    );
    _changes.add(collection);
  }

  Set<String> getStringSet(String key) =>
      (_prefs.getStringList(key) ?? const <String>[]).toSet();

  Future<void> setStringSet(String key, Set<String> value) =>
      _prefs.setStringList(key, value.toList());
}
