import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/navigation/outing_flow.dart';
import '../../core/widgets/common.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/presentation/outing_summary_page.dart';
import '../data/tracking_platform.dart';
import 'tracking_coordinator.dart';

/// A quick action asked from the lock screen, waiting for the person to
/// confirm it inside the app. Nothing is registered by opening a link.
class PendingTrackingAction {
  const PendingTrackingAction(this.outingId, this.action);

  final String outingId;

  /// `another` or `water`.
  final String action;
}

/// Shared between the link handler and the running-outing screen.
class TrackingActions {
  const TrackingActions._();

  /// Set by the link handler, consumed (and cleared) by the outing screen.
  static final pending = ValueNotifier<PendingTrackingAction?>(null);

  /// The outing whose screen is open right now, so a link does not push a
  /// second copy of it.
  static final visibleOuting = ValueNotifier<String?>(null);
}

/// Turns taps on the lock-screen surfaces into navigation. It waits for the
/// app to be ready, validates everything against the stored records and takes
/// nothing from the link except the outing id and the kind of action: prices,
/// ABV and drinks are always read from the local records.
class TrackingLinks {
  TrackingLinks(this._platform, this._outings, this._coordinator);

  final TrackingPlatform _platform;
  final OutingRepository _outings;
  final TrackingCoordinator _coordinator;

  final navigatorKey = GlobalKey<NavigatorState>();
  String? _lastKey;
  DateTime? _lastAt;
  bool _polling = false;

  void start() {
    _platform.onLink = () => unawaited(poll());
    unawaited(poll());
  }

  /// Asks the native side for a tap that arrived while the app was closed or
  /// in the background. Safe to call often: a tap is delivered once.
  Future<void> poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final link = await _platform.consumeLink();
      if (link != null) await _handle(link);
    } finally {
      _polling = false;
    }
  }

  Future<void> _handle(TrackingLink link) async {
    // A re-delivered event must not open the same thing twice.
    final key = '${link.outingId}|${link.action}';
    final now = DateTime.now();
    if (_lastKey == key &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastKey = key;
    _lastAt = now;

    final navigator = await _readyNavigator();
    if (navigator == null) return;
    final context = navigator.context;

    final outing = _outings.byId(link.outingId);
    if (outing == null) {
      showToast(context, 'Esse rolê não existe mais neste aparelho.');
      _coordinator.schedule(immediate: true);
      return;
    }
    if (!outing.isActive) {
      // Old tap on an outing that is over: no consumption, just the summary,
      // and the stale surface is taken down.
      _coordinator.schedule(immediate: true);
      unawaited(navigator.push(MaterialPageRoute<void>(
        builder: (_) => OutingSummaryPage(outingId: outing.id),
      )));
      return;
    }
    final action = link.action;
    if (action == 'another' || action == 'water') {
      TrackingActions.pending.value = PendingTrackingAction(outing.id, action);
    }
    if (TrackingActions.visibleOuting.value != outing.id) {
      unawaited(OutingFlow.open(context, outing.id));
    }
  }

  /// The app may still be starting: wait a little for the navigator.
  Future<NavigatorState?> _readyNavigator() async {
    for (var i = 0; i < 40; i++) {
      final nav = navigatorKey.currentState;
      if (nav != null && nav.mounted) return nav;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return null;
  }
}
