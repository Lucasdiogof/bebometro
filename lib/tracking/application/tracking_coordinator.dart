import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../data/tracking_platform.dart';
import '../data/tracking_prefs.dart';
import '../domain/tracking_snapshot.dart';

/// What the settings screen can say about the tracking, confirmed with the
/// native side whenever possible (a preference that is on is not "active").
enum TrackingStatus {
  /// Web or an OS version without the feature.
  unsupported,
  disabled,
  permissionDenied,

  /// Switched off in the system settings (Live Activities / notifications).
  systemOff,
  noOuting,
  hidden,

  /// The person removed it from the lock screen / shade for this outing.
  dismissed,
  active,

  /// Wanted but not shown yet (e.g. iOS only starts it with the app open).
  pending,
}

/// Mirrors the persisted state of the running outing on the native surfaces.
/// The truth is always the stored records and preferences: this class only
/// reads them, never writes records, and works offline (nothing here waits for
/// the server). Quick changes are merged, and a late answer never recreates a
/// surface for an outing that has ended: every run re-checks the outing after
/// each await and a newer run cancels the older one.
class TrackingCoordinator {
  TrackingCoordinator(
    this._platform,
    this._prefs,
    this._outings,
    this._drinks,
  );

  final TrackingPlatform _platform;
  final TrackingPrefs _prefs;
  final OutingRepository _outings;
  final DrinkRepository _drinks;

  final status = ValueNotifier<TrackingStatus>(TrackingStatus.unsupported);
  final _subs = <StreamSubscription<void>>[];
  Timer? _debounce;
  int _generation = 0;
  TrackingSnapshot? _last;
  bool _started = false;

  TrackingPlatform get platform => _platform;
  TrackingPrefs get prefs => _prefs;

  void start() {
    if (_started) return;
    _started = true;
    _platform.attach();
    _subs
      ..add(_outings.changes.listen((_) => schedule()))
      ..add(_drinks.changes.listen((_) => schedule()))
      ..add(_prefs.changes.listen((_) => schedule()));
    schedule(immediate: true);
  }

  /// Merges rapid changes into one native update.
  void schedule({bool immediate = false}) {
    _debounce?.cancel();
    _debounce = Timer(
      immediate ? Duration.zero : const Duration(milliseconds: 600),
      () => unawaited(reconcile()),
    );
  }

  /// Turns the feature on in response to the person's choice. Android asks for
  /// the notification permission here and nowhere else.
  Future<TrackingStatus> enable() async {
    await _prefs.setEnabled(true);
    final caps = await _platform.capabilities();
    if (caps.supported && caps.permission == 'denied') {
      await _platform.requestPermission();
    }
    await reconcile();
    return status.value;
  }

  Future<void> disable() async {
    await _prefs.setEnabled(false);
    _last = null;
    await _platform.end();
    await reconcile();
  }

  /// "Ocultar neste rolê" (hide) and "Mostrar novamente" (show again, which
  /// also forgets a manual removal because it is an explicit request).
  Future<void> setHiddenFor(String outingId, bool hidden) async {
    await _prefs.setHidden(outingId, hidden);
    if (!hidden) {
      await _prefs.setDismissed(outingId, false);
      await _platform.clearDismissed(outingId);
      _last = null;
    }
    await reconcile();
  }

  /// Hidden, or removed by the user: offers "Mostrar novamente".
  bool isSuppressed(String outingId) =>
      _prefs.isHidden(outingId) || _prefs.isDismissed(outingId);

  /// Whether the first-outing explanation should appear now.
  Future<bool> shouldOffer() async {
    if (_prefs.offerHandled || _prefs.enabled) return false;
    final caps = await _platform.capabilities();
    return caps.supported;
  }

  Future<void> reconcile() async {
    final gen = ++_generation;
    bool stale() => gen != _generation;

    if (!_platform.isNativePlatform) {
      status.value = TrackingStatus.unsupported;
      return;
    }
    final caps = await _platform.capabilities();
    if (stale()) return;
    if (!caps.supported) {
      status.value = TrackingStatus.unsupported;
      return;
    }
    final native = await _platform.status();
    if (stale()) return;
    // A removal done by hand on the lock screen is remembered for good.
    for (final id in native.dismissed) {
      if (!_prefs.isDismissed(id)) await _prefs.setDismissed(id, true);
    }
    if (stale()) return;

    final outing = _outings.active;
    if (!_prefs.enabled) {
      if (native.shownOutingIds.isNotEmpty) await _platform.end();
      _last = null;
      if (!stale()) status.value = TrackingStatus.disabled;
      return;
    }
    if (outing == null) {
      if (native.shownOutingIds.isNotEmpty) await _platform.end();
      _last = null;
      if (!stale()) status.value = TrackingStatus.noOuting;
      return;
    }
    // Nothing from another outing may stay on screen.
    for (final id in native.shownOutingIds) {
      if (id != outing.id) await _platform.end(outingId: id);
    }
    if (stale()) return;
    if (_prefs.isHidden(outing.id)) {
      if (native.shownOutingIds.contains(outing.id)) {
        await _platform.end(outingId: outing.id);
      }
      _last = null;
      if (!stale()) status.value = TrackingStatus.hidden;
      return;
    }
    if (_prefs.isDismissed(outing.id)) {
      _last = null;
      status.value = TrackingStatus.dismissed;
      return;
    }
    if (caps.permission == 'denied') {
      status.value = TrackingStatus.permissionDenied;
      return;
    }
    if (!caps.systemEnabled) {
      status.value = TrackingStatus.systemOff;
      return;
    }

    // Read the records right before sending, after every await above.
    final current = _outings.active;
    if (current == null || current.id != outing.id) {
      schedule();
      return;
    }
    final snapshot = TrackingSnapshot.of(
      outing: current,
      entries: _drinks.entriesFor(current.id),
      lastAlcoholic: _drinks.lastAlcoholic(current.id),
      showSpend: _prefs.showSpend,
      showPlace: _prefs.showPlace,
    );
    final alreadyShown = native.shownOutingIds.contains(current.id);
    if (alreadyShown && snapshot == _last) {
      status.value = TrackingStatus.active;
      return;
    }
    final outcome = await _platform.sync(snapshot.toMap());
    if (stale()) return;

    // If the outing ended while the call was in flight, take it down again.
    final still = _outings.active;
    if (still == null || still.id != current.id) {
      await _platform.end(outingId: current.id);
      _last = null;
      schedule();
      return;
    }
    switch (outcome) {
      case TrackingOutcome.started:
      case TrackingOutcome.updated:
        _last = snapshot;
        status.value = TrackingStatus.active;
      case TrackingOutcome.dismissed:
        await _prefs.setDismissed(current.id, true);
        _last = null;
        status.value = TrackingStatus.dismissed;
      case TrackingOutcome.permissionDenied:
        status.value = TrackingStatus.permissionDenied;
      case TrackingOutcome.systemOff:
        status.value = TrackingStatus.systemOff;
      case TrackingOutcome.unavailable:
        status.value = TrackingStatus.unsupported;
      case TrackingOutcome.error:
        // Typical on iOS when the app is not in the foreground: tried again
        // when it comes back.
        _last = null;
        status.value = TrackingStatus.pending;
    }
  }

  void dispose() {
    _debounce?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
  }
}
