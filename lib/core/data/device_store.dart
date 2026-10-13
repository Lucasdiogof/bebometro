import 'package:shared_preferences/shared_preferences.dart';

/// Preferences of the DEVICE, not of an account: lock-screen choices, table
/// view, hints already shown, budget alerts switch, and the bookkeeping of
/// sessions and old data. Keys have no account prefix.
///
/// Account data (records, queues, cursors, favourites, drafts) never goes
/// here: it lives in the account's [LocalStore] namespace.
class DeviceStore {
  DeviceStore(this.prefs);

  static Future<DeviceStore> open() async =>
      DeviceStore(await SharedPreferences.getInstance());

  /// Shared with [LocalStore], which namespaces its own keys.
  final SharedPreferences prefs;

  String? getString(String key) => prefs.getString(key);

  Future<void> setString(String key, String value) =>
      prefs.setString(key, value);

  Future<void> remove(String key) => prefs.remove(key);

  Set<String> getStringSet(String key) =>
      (prefs.getStringList(key) ?? const <String>[]).toSet();

  Future<void> setStringSet(String key, Set<String> value) =>
      prefs.setStringList(key, value.toList());

  Set<String> keys() => prefs.getKeys();
}
