import 'package:flutter/material.dart';

import '../../outings/presentation/outing_page.dart';
import '../../outings/presentation/outing_summary_page.dart';
import '../../places/domain/place.dart';
import '../../outings/presentation/start_outing_page.dart';

/// Opens the outing screens from anywhere (home, catalog, the "rolê em
/// andamento" bar) without stacking the same screen twice.
class OutingFlow {
  const OutingFlow._();

  static bool _busy = false;

  /// Opens the running outing. When it is finished from there, shows its
  /// summary (the feedback prompt waits for the next app opening).
  ///
  /// [finish] opens it straight into the finish confirmation (the Home
  /// shortcut): the same sheet, the same confirmation, nothing ends by itself.
  static Future<void> open(
    BuildContext context,
    String outingId, {
    bool finish = false,
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      final navigator = Navigator.of(context);
      final finishedId = await navigator.push<String>(
        MaterialPageRoute(
          builder: (_) => OutingPage(outingId: outingId, finishOnOpen: finish),
        ),
      );
      if (finishedId != null && context.mounted) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => OutingSummaryPage(outingId: finishedId),
          ),
        );
      }
    } finally {
      _busy = false;
    }
  }

  /// Starts a new outing (or recovers the running one) and opens it. Returns
  /// the outing id, or null when the person backed out.
  static Future<String?> start(BuildContext context, {Place? place}) async {
    if (_busy) return null;
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => StartOutingPage(place: place)),
    );
    if (id != null && context.mounted) await open(context, id);
    return id;
  }
}
