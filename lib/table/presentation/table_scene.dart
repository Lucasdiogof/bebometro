import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart' show reduceMotion;
import '../../drinks/domain/drink_entry.dart';
import '../domain/drink_vessel.dart';
import '../domain/table_layout.dart';
import '../domain/table_scenario.dart';
import 'scene_painter.dart';
import 'table_sheets.dart';
import 'vessel_painter.dart';
import '../../l10n/l10n.dart';

/// Illustrated table of the outing, built from the real records.
///
/// * Decorative only: nothing here changes a record.
/// * The "emptying" level is computed from the elapsed time (see
///   [vesselFill]); a light clock repaints only the small vessel painters, and
///   it stops when the screen is hidden, the app is in the background, motion
///   is reduced or animations are off.
/// * With [retrospective] (finished outing) every vessel is shown empty and
///   nothing is tappable.
class TableScene extends StatefulWidget {
  const TableScene({
    super.key,
    required this.entries,
    required this.scenario,
    required this.animate,
    this.retrospective = false,
    this.compact = false,
    this.onEdit,
    this.onDelete,
  });

  /// Live records of the outing, oldest first.
  final List<DrinkEntry> entries;
  final TableScenario scenario;

  /// The user's "table animations" preference.
  final bool animate;
  final bool retrospective;
  final bool compact;
  final void Function(DrinkEntry)? onEdit;
  final void Function(DrinkEntry)? onDelete;

  @override
  State<TableScene> createState() => _TableSceneState();
}

class _TableSceneState extends State<TableScene> with WidgetsBindingObserver {
  final _clock = ValueNotifier<DateTime>(DateTime.now());
  Timer? _timer;
  bool _resumed = true;
  /// Entrance animation start per item key, decided once when the item is
  /// first seen: 1 (no animation) for what was already on the table.
  final _begins = <String, double>{};
  bool _firstPlan = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTimer();
  }

  @override
  void didUpdateWidget(TableScene old) {
    super.didUpdateWidget(old);
    _syncTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _syncTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _clock.dispose();
    super.dispose();
  }

  bool get _active =>
      widget.animate &&
      !widget.retrospective &&
      _resumed &&
      TickerMode.valuesOf(context).enabled &&
      !reduceMotion(context);

  /// Runs the clock only while it can be seen; coming back it jumps straight
  /// to the right level because the level depends on elapsed time alone.
  void _syncTimer() {
    if (_active) {
      _clock.value = DateTime.now();
      _timer ??= Timer.periodic(const Duration(seconds: 3), (_) {
        _clock.value = DateTime.now();
      });
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _edit(DrinkEntry e) => widget.onEdit?.call(e);
  void _delete(DrinkEntry e) => widget.onDelete?.call(e);

  void _open(TableItem item) {
    if (widget.retrospective || widget.onEdit == null) return;
    if (item.count == 1) {
      showEntryDetailSheet(context, item.entries.first,
          onEdit: _edit, onDelete: _delete);
    } else {
      showEntryGroupSheet(
        context,
        item.isOverflow
            ? tr.tableOthersTitle(item.count)
            : tr.tableGroupTitle(item.count, item.lead.name),
        item.entries,
        onEdit: _edit,
        onDelete: _delete,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final plan = planTable(
        widget.entries,
        constraints.maxWidth,
        compact: widget.compact,
      );
      final initial = _firstPlan;
      _firstPlan = false;
      final active = _active;
      final staticNow = DateTime.now();
      final reduce = reduceMotion(context);
      return Semantics(
        container: true,
        label: widget.retrospective
            ? tr.tableSemanticsOuting(widget.entries.length)
            : tr.tableSemanticsTable(widget.entries.length),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: plan.height,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: ScenePainter(widget.scenario, plan.tableTop),
                    ),
                  ),
                ),
                if (widget.entries.isEmpty)
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        tr.tableEmpty,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                for (var i = 0; i < plan.items.length; i++)
                  _positioned(plan, i, active, staticNow, reduce, initial),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _positioned(
    TablePlan plan,
    int i,
    bool active,
    DateTime staticNow,
    bool reduce,
    bool initial,
  ) {
    final item = plan.items[i];
    final slot = plan.slots[i];
    final w = kVesselW * slot.scale;
    final h = kVesselH * slot.scale;
    final lead = item.lead;
    final kind = vesselKindFor(lead);
    final shared = lead.isShared && lead.personalMl != null && item.count == 1;

    Widget vessel;
    if (item.isOverflow) {
      vessel = Center(
        child: Container(
          width: w * 0.9,
          height: w * 0.9,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            '+${item.count}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      );
    } else {
      vessel = RepaintBoundary(
        child: CustomPaint(
          size: Size(w, h),
          painter: VesselPainter(
            kind: kind,
            liquid: liquidColorFor(lead),
            foam: hasFoam(lead, kind),
            clock: _clock,
            fixedNow: active ? null : staticNow,
            signature: Object.hash(
              lead.id,
              lead.updatedAt.microsecondsSinceEpoch,
              lead.consumedAt.microsecondsSinceEpoch,
              widget.retrospective,
            ),
            fillAt: (now) =>
                widget.retrospective ? 0 : vesselFill(lead, kind, now),
          ),
        ),
      );
    }

    final label = item.isOverflow
        ? tr.tableOverflowSemantics(item.count)
        : vesselSemantics(lead, kind, count: item.count);

    Widget content = SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: vessel),
          if (item.count > 1 && !item.isOverflow)
            Positioned(
              right: -4,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '×${item.count}',
                  style: const TextStyle(
                      color: Color(0xFF241800),
                      fontSize: 11,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          if (shared)
            Positioned(
              left: -8,
              right: -8,
              bottom: -14,
              child: Text(
                tr.tableYours(formatMl(lead.personalMl!)),
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        color: Colors.black.withValues(alpha: 0.7), blurRadius: 3),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    content = Semantics(
      button: !widget.retrospective,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.retrospective ? null : () => _open(item),
        child: content,
      ),
    );

    // New records pop in (not the ones already on the table when it opened).
    final begin = _begins.putIfAbsent(
        item.key, () => (initial || reduce) ? 1.0 : 0.0);
    return Positioned(
      key: ValueKey(item.key),
      left: slot.cx - w / 2,
      top: slot.baseY - 86 * slot.scale,
      width: w,
      height: h,
      child: TweenAnimationBuilder<double>(
        key: ValueKey('anim-${item.key}'),
        tween: Tween(begin: begin, end: 1.0),
        duration: begin >= 1.0
            ? Duration.zero
            : const Duration(milliseconds: 380),
        curve: Curves.easeOutBack,
        builder: (context, v, child) => Opacity(
          opacity: v.clamp(0.0, 1.0).toDouble(),
          child: Transform.scale(scale: 0.6 + 0.4 * v, child: child),
        ),
        child: content,
      ),
    );
  }
}
