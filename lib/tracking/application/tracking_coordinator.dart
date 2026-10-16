import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/di/injector.dart' show AccountScope;
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

  /// The language of the app changed: the texts on the lock screen are
  /// resent right away (the snapshot differs by its texts).
  void refreshTexts() {
    _last = null;
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
      accountId: AccountScope.userId,
      pendingCommands: _pendingByOuting[current.id] ?? 0,
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

  bool _processingCommands = false;

  /// Commands kept in the native queue because they cannot be applied safely
  /// here (other account, unknown outing, missing record, time outside the
  /// outing). Never dropped nor redirected; they wait for resolution.
  final unresolvedCommands = ValueNotifier<int>(0);

  /// Unresolved commands per outing, shown as "+N aguardando registro".
  Map<String, int> _pendingByOuting = const {};

  /// Registers what the person tapped on the lock screen ("Mais uma", iOS 17+).
  /// Each command carries, from the moment of the tap, the account, the
  /// outing, the real time and the record the button showed; the app repeats
  /// THAT record (same composition, portion, ABV origin and price) at THAT
  /// time. Never the last drink or the clock at processing time.
  ///
  /// The new record id comes from the command id and the command is
  /// acknowledged only after the record is on disk, so a crash in between
  /// replays the same id (no duplicate) and a record that already exists
  /// (even if the person deleted it since) is never saved again. Anything
  /// that does not match stays queued as unresolved, not acknowledged.
  Future<int> processCommands() async {
    if (_processingCommands || !_platform.isNativePlatform) return 0;
    _processingCommands = true;
    try {
      final commands = await _platform.peekCommands();
      final done = <String>[];
      var registered = 0;
      var unresolved = 0;
      final pending = <String, int>{};
      final now = DateTime.now();
      final account = AccountScope.userId;
      for (final c in commands) {
        if (c.kind != 'another') {
          unresolved++; // unknown command from a newer build: kept
          pending[c.outingId] = (pending[c.outingId] ?? 0) + 1;
          continue;
        }
        final newId = _drinks.entryIdForCommand(c.id);
        if (_drinks.entryById(newId) != null) {
          done.add(c.id); // already saved before a crash: only acknowledge
          continue;
        }
        final outing = _outings.byId(c.outingId);
        final source = c.entryId == null ? null : _drinks.entryById(c.entryId!);
        final ok = account != null &&
            (c.accountId == null || c.accountId == account) &&
            outing != null &&
            source != null &&
            source.outingId == outing.id &&
            !c.at.isBefore(outing.startedAt) &&
            (outing.endedAt == null || !c.at.isAfter(outing.endedAt!)) &&
            !c.at.isAfter(now.add(const Duration(minutes: 5)));
        if (!ok) {
          unresolved++;
          pending[c.outingId] = (pending[c.outingId] ?? 0) + 1;
          continue;
        }
        await _drinks.save(source.repeated(newId: newId, at: c.at));
        done.add(c.id);
        registered++;
      }
      if (done.isNotEmpty) await _platform.ackCommands(done);
      unresolvedCommands.value = unresolved;
      final changed = pending.length != _pendingByOuting.length ||
          pending.entries.any((e) => _pendingByOuting[e.key] != e.value);
      _pendingByOuting = pending;
      if (registered > 0 || done.isNotEmpty || changed) {
        schedule(immediate: true);
      }
      return registered;
    } finally {
      _processingCommands = false;
    }
  }

  /// Account closing (sign out or switch): takes this account's surfaces off
  /// the lock screen and stops reacting. A run already in flight sees a new
  /// generation and gives up.
  Future<void> shutdown() async {
    _generation++;
    _debounce?.cancel();
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _started = false;
    _last = null;
    await _platform.end();
  }

  void dispose() {
    _generation++;
    _debounce?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
  }
}
