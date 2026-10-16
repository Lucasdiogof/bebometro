import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/di/injector.dart' show AccountScope;
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../outings/domain/outing.dart';
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

  /// Lock-screen commands of THIS account that need the person (see
  /// [PendingCommand]). Commands of another account, or of an outing this
  /// account does not have, are kept in the queue but never listed here.
  final pendingCommands = ValueNotifier<List<PendingCommand>>(const []);

  /// Same count, kept for older callers.
  final unresolvedCommands = ValueNotifier<int>(0);

  /// Pending commands per outing, shown as "+N aguardando registro".
  Map<String, int> _pendingByOuting = const {};

  /// Commands open in a review form: automatic processing leaves them alone,
  /// so a review and a retry never race (both would use the same record id
  /// anyway, so even a race could not create two records).
  final _reviewing = <String>{};

  /// Every queue operation runs one after the other.
  Future<void> _queue = Future.value();
  Future<T> _serial<T>(Future<T> Function() op) {
    final done = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        done.complete(await op());
      } catch (e, st) {
        done.completeError(e, st);
      }
    });
    return done.future;
  }

  /// Record id a command creates; the same for the automatic path and for a
  /// review, which is what makes both idempotent.
  String entryIdFor(PendingCommand p) => _drinks.entryIdForCommand(p.command.id);

  /// Origin written by BOTH the automatic path and a review.
  EntryOrigin originOf(PendingCommand p) =>
      EntryOrigin.lockScreen(commandId: p.command.id, tappedAt: p.command.at);

  /// Registers what the person tapped on the lock screen ("Mais uma", iOS 17+).
  /// Each command carries, from the moment of the tap, the account, the
  /// outing, the real time and the record the button showed; the app repeats
  /// THAT record (same composition, portion, ABV origin and price) at THAT
  /// time, only while the outing is running. Never the last drink or the clock
  /// at processing time.
  ///
  /// The new record id comes from the command id and the command is
  /// acknowledged only after the record is on disk, so a crash in between
  /// replays the same id (no duplicate) and a record that already exists
  /// (even if the person deleted it since) is never saved again. A command
  /// that cannot be applied stays queued with a reason; a failure on one never
  /// stops the others.
  Future<int> processCommands() =>
      !_platform.isNativePlatform ? Future.value(0) : _serial(_process);

  Future<int> _process() async {
    final commands = await _platform.peekCommands();
    final done = <String>[];
    var registered = 0;
    final pending = <PendingCommand>[];
    final now = DateTime.now();
    final account = AccountScope.userId;
    for (final c in commands) {
      // Not this account's (or unknown here): kept, never shown or counted.
      if (account == null || (c.accountId != null && c.accountId != account)) {
        continue;
      }
      final outing = _outings.byId(c.outingId);
      if (outing == null) continue;
      if (_reviewing.contains(c.id)) {
        pending.add(PendingCommand(c, outing, null, PendingReason.inReview));
        continue;
      }
      final newId = _drinks.entryIdForCommand(c.id);
      try {
        if (_drinks.entryById(newId) != null) {
          done.add(c.id); // already saved before a crash: only acknowledge
          continue;
        }
        if (c.kind != 'another') {
          pending.add(PendingCommand(c, outing, null, PendingReason.unsupported));
          continue;
        }
        final found = c.entryId == null ? null : _drinks.entryById(c.entryId!);
        final source =
            found != null && found.outingId == outing.id ? found : null;
        final inPeriod = !c.at.isBefore(outing.startedAt) &&
            (outing.endedAt == null || !c.at.isAfter(outing.endedAt!)) &&
            !c.at.isAfter(now.add(const Duration(minutes: 5)));
        final reason = source == null
            ? PendingReason.missingDrink
            : !inPeriod
                ? PendingReason.outsidePeriod
                : !outing.isActive
                    ? PendingReason.outingEnded
                    : null;
        if (reason != null) {
          pending.add(PendingCommand(c, outing, source, reason));
          continue;
        }
        await _drinks.save(source!.repeated(
            newId: newId,
            at: c.at,
            origin: EntryOrigin.lockScreen(commandId: c.id, tappedAt: c.at)));
        done.add(c.id);
        registered++;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[tracking] command failed: ${e.runtimeType}');
        }
        DrinkEntry? found;
        try {
          found = c.entryId == null ? null : _drinks.entryById(c.entryId!);
        } catch (_) {}
        pending.add(
            PendingCommand(c, outing, found, PendingReason.saveFailed));
      }
    }
    if (done.isNotEmpty) await _platform.ackCommands(done);
    _publish(pending);
    if (registered > 0 || done.isNotEmpty) schedule(immediate: true);
    return registered;
  }

  void _publish(List<PendingCommand> pending) {
    pending.sort((a, b) => a.command.at.compareTo(b.command.at));
    pendingCommands.value = List.unmodifiable(pending);
    unresolvedCommands.value = pending.length;
    final byOuting = <String, int>{};
    for (final p in pending) {
      byOuting[p.outing.id] = (byOuting[p.outing.id] ?? 0) + 1;
    }
    final changed = byOuting.length != _pendingByOuting.length ||
        byOuting.entries.any((e) => _pendingByOuting[e.key] != e.value);
    _pendingByOuting = byOuting;
    if (changed) schedule(immediate: true);
  }

  /// A review form for [p] is open / closed.
  void beginReview(PendingCommand p) => _reviewing.add(p.command.id);
  void endReview(PendingCommand p) => _reviewing.remove(p.command.id);

  /// After a review form saved the record: acknowledges the command only if
  /// its record is really on disk (save first, then acknowledge).
  Future<bool> acknowledgeSaved(PendingCommand p) async {
    final ok = await _serial(() async {
      if (_drinks.entryById(entryIdFor(p)) == null) return false;
      await _platform.ackCommands([p.command.id]);
      return true;
    });
    _reviewing.remove(p.command.id);
    await processCommands();
    return ok;
  }

  /// Drops [p] from the queue. Never deletes a record: if the command had
  /// already been saved, that record stays.
  Future<void> discard(PendingCommand p) async {
    await _serial(() async {
      _reviewing.remove(p.command.id);
      await _platform.ackCommands([p.command.id]);
    });
    await processCommands();
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

/// Why a lock-screen command waits for the person.
enum PendingReason {
  /// The outing was closed before the app could save the tap: needs an
  /// explicit "add to that outing".
  outingEnded,

  /// The tap time falls outside the outing's period: the time must be fixed.
  outsidePeriod,

  /// The command does not say which drink to repeat (older version) or that
  /// record no longer exists: a drink must be chosen.
  missingDrink,

  /// Saving failed; trying again uses the same idempotent processing.
  saveFailed,

  /// A command this version does not know: can only be discarded.
  unsupported,

  /// Open in a review form right now.
  inReview,
}

/// A lock-screen command of the current account that was not saved.
class PendingCommand {
  const PendingCommand(this.command, this.outing, this.source, this.reason);

  final TrackingCommand command;

  /// The outing of the tap (always one of this account's).
  final Outing outing;

  /// The record the button showed, when it still exists in that outing.
  final DrinkEntry? source;
  final PendingReason reason;

  /// Saving it again with the same processing may work.
  bool get canRetry => reason == PendingReason.saveFailed;
}
