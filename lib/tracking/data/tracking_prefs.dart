import 'dart:async';

import '../../core/data/device_store.dart';

/// Device-local choices for the lock-screen tracking. Not synced and needing
/// no migration. Everything that must survive a restart is stored, because
/// "hidden" and "removed by the user" are tied to one outing, not to memory.
class TrackingPrefs {
  TrackingPrefs(this._store);

  final DeviceStore _store;
  final _changes = StreamController<void>.broadcast();

  static const _enabled = 'tracking.enabled';
  static const _showSpend = 'tracking.show_spend';
  static const _showPlace = 'tracking.show_place';
  static const _offerHandled = 'tracking.offer_handled';
  static const _hidden = 'tracking.hidden_outings';
  static const _dismissed = 'tracking.dismissed_outings';

  Stream<void> get changes => _changes.stream;

  /// Off until the person turns it on (here or from the first-outing offer).
  bool get enabled => _store.getString(_enabled) == '1';

  /// Spending is private by default.
  bool get showSpend => _store.getString(_showSpend) == '1';

  /// The place name is private by default: "Rolê em andamento" is shown.
  bool get showPlace => _store.getString(_showPlace) == '1';

  /// The first-outing explanation was already shown (accepted or not).
  bool get offerHandled => _store.getString(_offerHandled) == '1';

  Future<void> _set(String key, bool on) async {
    await _store.setString(key, on ? '1' : '0');
    _changes.add(null);
  }

  Future<void> setEnabled(bool on) => _set(_enabled, on);
  Future<void> setShowSpend(bool on) => _set(_showSpend, on);
  Future<void> setShowPlace(bool on) => _set(_showPlace, on);
  Future<void> markOfferHandled() => _set(_offerHandled, true);

  bool isHidden(String outingId) =>
      _store.getStringSet(_hidden).contains(outingId);

  bool isDismissed(String outingId) =>
      _store.getStringSet(_dismissed).contains(outingId);

  Future<void> _toggle(String key, String id, bool on) async {
    final set = _store.getStringSet(key);
    final changed = on ? set.add(id) : set.remove(id);
    if (!changed) return;
    await _store.setStringSet(key, set);
    _changes.add(null);
  }

  Future<void> setHidden(String outingId, bool on) =>
      _toggle(_hidden, outingId, on);

  Future<void> setDismissed(String outingId, bool on) =>
      _toggle(_dismissed, outingId, on);
}
