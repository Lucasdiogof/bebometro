import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/domain/presentation_label.dart';
import '../../table/domain/table_orders.dart';
import '../../table/presentation/order_page.dart';
import '../../tab/data/tab_repository.dart';
import '../../l10n/l10n.dart';
import '../application/tracking_coordinator.dart';

/// Discreet notice shown while the current account has lock-screen taps that
/// need the person. Never opens anything by itself.
class PendingCommandsNotice extends StatelessWidget {
  const PendingCommandsNotice({super.key});

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<TrackingCoordinator>()) {
      return const SizedBox.shrink();
    }
    final coordinator = getIt<TrackingCoordinator>();
    return ValueListenableBuilder<List<PendingCommand>>(
      valueListenable: coordinator.pendingCommands,
      builder: (context, list, _) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpace.md),
          child: SurfaceCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.md,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PendingCommandsPage()),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_clock_outlined, color: AppColors.amber),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    tr.pendingNotice(list.length),
                    style: AppText.body,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "Registros pendentes": lock-screen taps of this account that could not be
/// saved on their own, with what each one needs.
class PendingCommandsPage extends StatefulWidget {
  const PendingCommandsPage({super.key});

  @override
  State<PendingCommandsPage> createState() => _PendingCommandsPageState();
}

class _PendingCommandsPageState extends State<PendingCommandsPage> {
  final _coordinator = getIt<TrackingCoordinator>();
  final _busy = <String>{};

  @override
  void initState() {
    super.initState();
    _coordinator.processCommands();
  }

  String _reasonText(PendingCommand p) => switch (p.reason) {
    PendingReason.outingEnded => tr.pendingReasonEnded,
    PendingReason.outsidePeriod => tr.pendingReasonOutside,
    PendingReason.missingDrink => tr.pendingReasonNoDrink,
    PendingReason.notPersonal => tr.pendingReasonNotPersonal,
    PendingReason.saveFailed => tr.pendingReasonFailed,
    PendingReason.unsupported => tr.pendingReasonUnsupported,
    PendingReason.inReview => tr.pendingReasonInReview,
  };

  String _placeOf(PendingCommand p) {
    final o = p.outing;
    final nick = [o.nickname, o.placeName]
        .map((v) => v?.trim())
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    return nick ?? tr.pendingOutingOn(formatDate(o.startedAt));
  }

  String _drinkOf(PendingCommand p) {
    final s = p.source;
    if (s != null) {
      final size = s.presentation != null
          ? localizePresentation(s.presentation!)
          : (s.containerMl == null ? null : formatMl(s.containerMl!));
      return size == null ? s.name : '${s.name} · $size';
    }
    final label = p.command.label;
    return (label == null || label.trim().isEmpty)
        ? tr.pendingDrinkUnknown
        : label;
  }

  Future<void> _run(PendingCommand p, Future<void> Function() op) async {
    if (_busy.contains(p.command.id)) return;
    setState(() => _busy.add(p.command.id));
    try {
      await op();
    } finally {
      if (mounted) setState(() => _busy.remove(p.command.id));
    }
  }

  Future<void> _retry(PendingCommand p) => _run(p, () async {
    await _coordinator.processCommands();
    if (!mounted) return;
    final still = _coordinator.pendingCommands.value.any(
      (x) => x.command.id == p.command.id,
    );
    showToast(context, still ? tr.pendingRetryFailed : tr.pendingSaved);
  });

  Future<void> _discard(PendingCommand p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.pendingDiscardTitle),
        content: Text(tr.pendingDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              tr.pendingDiscard,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(p, () async {
      await _coordinator.discard(p);
      if (mounted) showToast(context, tr.pendingDiscarded);
    });
  }

  /// Distinct drinks of the outing (most recent first) to pick from when the
  /// command does not say which one.
  List<DrinkEntry> _choicesFor(PendingCommand p) {
    final seen = <String>{};
    final out = <DrinkEntry>[];
    for (final e in getIt<DrinkRepository>().entriesFor(p.outing.id).reversed) {
      if (!e.isAlcoholic || !DrinkRepository.isPersonalIndividual(e)) continue;
      final key =
          '${e.catalogItemId ?? e.name}|${e.presentation}|${e.containerMl}|${e.isShared}';
      if (seen.add(key)) out.add(e);
    }
    return out;
  }

  Future<void> _chooseAndReview(PendingCommand p) async {
    final choices = _choicesFor(p);
    if (choices.isEmpty) {
      showToast(context, tr.pendingNoDrinkToChoose);
      return;
    }
    final picked = await showModalBottomSheet<DrinkEntry>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpace.lg),
          children: [
            Text(tr.pendingChooseTitle, style: AppText.title),
            const SizedBox(height: AppSpace.sm),
            for (final e in choices)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(e.category.icon, color: AppColors.amber),
                title: Text(e.name),
                subtitle: Text(
                  [
                    if (e.presentation != null)
                      localizePresentation(e.presentation!),
                    if (e.paidCents != null) formatCents(e.paidCents!),
                  ].join(' · '),
                ),
                onTap: () => Navigator.pop(ctx, e),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) await _review(p, picked);
  }

  /// Opens the normal form prefilled from [template], in the command's own
  /// outing, at the original tap time. Saved with the command's record id;
  /// the command is acknowledged only after the record is on disk.
  Future<void> _review(PendingCommand p, DrinkEntry template) async {
    _coordinator.beginReview(p);
    try {
      final doc = getIt<TabRepository>().load(p.outing.id);
      final row = TableOrders.rowOfEntry(doc, template);
      if (row == null) return;
      final outcome = await Navigator.of(context).push<OrderOutcome>(
        MaterialPageRoute(
          builder: (_) => OrderPage(
            outingId: p.outing.id,
            doc: doc,
            seed: row,
            review: OrderReview(
              entryId: _coordinator.entryIdFor(p),
              at: p.command.at,
              origin: _coordinator.originOf(p),
              note: tr.pendingReviewNote(formatDateTime(p.command.at)),
            ),
          ),
        ),
      );
      if (outcome != null) {
        final ok = await _coordinator.acknowledgeSaved(p);
        if (mounted) {
          showToast(context, ok ? tr.pendingSaved : tr.pendingRetryFailed);
        }
      }
    } finally {
      _coordinator.endReview(p);
      await _coordinator.processCommands();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr.pendingTitle)),
      body: ValueListenableBuilder<List<PendingCommand>>(
        valueListenable: _coordinator.pendingCommands,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpace.gutter),
              child: Text(tr.pendingEmpty, style: AppText.caption),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.gutter,
              AppSpace.sm,
              AppSpace.gutter,
              AppSpace.xxl,
            ),
            children: [
              Text(tr.pendingIntro, style: AppText.caption),
              const SizedBox(height: AppSpace.md),
              for (final p in list) ...[
                _card(p),
                const SizedBox(height: AppSpace.md),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _card(PendingCommand p) {
    final busy = _busy.contains(p.command.id);
    final inReview = p.reason == PendingReason.inReview;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_drinkOf(p), style: AppText.title),
          const SizedBox(height: AppSpace.xs),
          Text(_placeOf(p), style: AppText.caption),
          Text(
            tr.pendingTappedAt(formatDateTime(p.command.at)),
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.sm),
          InfoPill(
            _reasonText(p),
            icon: Icons.info_outline_rounded,
            warning: !p.canRetry,
          ),
          if (!inReview) ...[
            const SizedBox(height: AppSpace.md),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                if (p.canRetry)
                  FilledButton(
                    onPressed: busy ? null : () => _retry(p),
                    child: Text(tr.pendingRetry),
                  ),
                if (p.source != null &&
                    (p.reason == PendingReason.outingEnded ||
                        p.reason == PendingReason.outsidePeriod ||
                        p.reason == PendingReason.saveFailed))
                  FilledButton(
                    onPressed: busy ? null : () => _review(p, p.source!),
                    child: Text(tr.pendingReviewAdd),
                  ),
                if (p.reason == PendingReason.missingDrink ||
                    p.reason == PendingReason.notPersonal)
                  FilledButton(
                    onPressed: busy ? null : () => _chooseAndReview(p),
                    child: Text(tr.pendingChooseDrink),
                  ),
                OutlinedButton(
                  onPressed: busy ? null : () => _discard(p),
                  child: Text(tr.pendingDiscard),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
