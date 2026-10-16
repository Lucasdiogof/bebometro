import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/beer_glass.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/add_drink_page.dart';
import '../../drinks/presentation/drink_entry_page.dart';
import '../../places/presentation/change_outing_place.dart';
import '../../scan/data/scan_draft_store.dart';
import '../../table/data/table_prefs_cubit.dart';
import '../../table/presentation/table_scene.dart';
import '../../table/presentation/table_sheets.dart';
import '../../glass/presentation/accumulated_glass.dart';
import '../../tab/presentation/tab_entry_card.dart';
import '../../tracking/application/tracking_coordinator.dart';
import '../../tracking/application/tracking_links.dart';
import '../../tracking/presentation/tracking_offer_sheet.dart';
import 'budget_section.dart';
import 'outing_cubit.dart';
import '../../l10n/l10n.dart';
import '../../drinks/domain/presentation_label.dart';

/// Running outing. Pops with the outing id after it is finished, so the
/// caller can show the summary.
class OutingPage extends StatelessWidget {
  const OutingPage({super.key, required this.outingId, this.finishOnOpen = false});

  final String outingId;

  /// Opens the finish confirmation right away (Home shortcut).
  final bool finishOnOpen;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OutingCubit>(param1: outingId),
      child: _OutingView(finishOnOpen: finishOnOpen),
    );
  }
}

class _OutingView extends StatefulWidget {
  const _OutingView({this.finishOnOpen = false});

  final bool finishOnOpen;

  @override
  State<_OutingView> createState() => _OutingViewState();
}

class _OutingViewState extends State<_OutingView> {
  StreamSubscription<OutingNotice>? _sub;
  bool _finishing = false;

  late final String _outingId;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OutingCubit>();
    _outingId = cubit.outingId;
    _sub = cubit.notices.listen(_showNotice);
    TrackingActions.visibleOuting.value = _outingId;
    TrackingActions.pending.addListener(_onPending);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onPending();
      if (widget.finishOnOpen &&
          cubit.state.outing?.isActive == true) {
        unawaited(_finish());
        return;
      }
      // One-time explanation of the lock-screen tracking, first outing only.
      if (cubit.state.outing?.isActive == true) {
        unawaited(offerTrackingIfNeeded(context));
      }
    });
  }

  @override
  void dispose() {
    TrackingActions.pending.removeListener(_onPending);
    if (TrackingActions.visibleOuting.value == _outingId) {
      TrackingActions.visibleOuting.value = null;
    }
    _sub?.cancel();
    super.dispose();
  }

  /// A quick action asked from the lock screen (link). Registered at once.
  void _onPending() {
    final p = TrackingActions.pending.value;
    if (p == null || !mounted || p.outingId != _outingId) return;
    TrackingActions.pending.value = null; // consumed once
    unawaited(_runQuick(p.action));
  }

  /// The tap on the lock screen was the decision: registers right away (with
  /// the usual Undo notice) instead of asking again.
  Future<void> _runQuick(String action) async {
    final cubit = context.read<OutingCubit>();
    if (cubit.state.outing?.isActive != true) {
      showToast(context, tr.outingAlreadyEnded);
      return;
    }
    if (action == 'another') {
      if (cubit.state.lastAlcoholic == null) {
        showToast(context, tr.outingNothingToRepeat);
        return;
      }
      await cubit.repeatLast();
    } else {
      await cubit.addWater();
    }
  }

  Future<void> _toggleTracking() async {
    final coordinator = getIt<TrackingCoordinator>();
    final suppressed = coordinator.isSuppressed(_outingId);
    await coordinator.setHiddenFor(_outingId, !suppressed);
    if (!mounted) return;
    showToast(
        context,
        suppressed
            ? tr.outingTrackingBack
            : tr.outingTrackingHidden);
  }

  void _showNotice(OutingNotice notice) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(notice.text),
      duration: const Duration(seconds: 5),
      action: notice.undo == null
          ? null
          : SnackBarAction(
              label: notice.undoLabel ?? tr.commonUndo,
              onPressed: () => notice.undo!(),
            ),
    ));
  }

  Future<void> _addDrink() async {
    final id = context.read<OutingCubit>().outingId;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddDrinkPage(outingId: id)),
    );
    if (saved == true && mounted) showToast(context, tr.outingDrinkLogged);
  }

  Future<void> _edit(DrinkEntry entry) async {
    final outcome = await Navigator.of(context).push<EntryOutcome>(
      MaterialPageRoute(builder: (_) => DrinkEntryPage.edit(entry: entry)),
    );
    if (!mounted || outcome == null) return;
    showToast(
      context,
      outcome == EntryOutcome.deleted
          ? tr.noticeEntryDeleted
          : tr.outingEntryUpdated,
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
    final cubit = context.read<OutingCubit>();
    final outing = cubit.state.outing;
    if (outing == null) return;
    final endedAt = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FinishSheet(
        startedAt: outing.startedAt,
        entryCount: cubit.state.entries.length,
      ),
    );
    if (endedAt == null) return;
    setState(() => _finishing = true);
    try {
      await cubit.finish(endedAt);
      if (mounted &&
          getIt<ScanDraftStore>().openFor(outing.id).isNotEmpty) {
        // An unfinished label/menu reading stays tied to this outing.
        showToast(
          context,
          tr.outingOpenScan,
        );
      }
      if (mounted) Navigator.of(context).pop(outing.id);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() => _finishing = false);
      showToast(context, '${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OutingCubit>();
    return BlocBuilder<OutingCubit, OutingState>(
      builder: (context, state) {
        if (state.loading) {
          return const Scaffold(body: LoadingView());
        }
        final outing = state.outing;
        if (outing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(message: tr.outingNotFound),
          );
        }
        final summary = state.summary!;
        final last = state.lastAlcoholic;
        final entries = state.entries.reversed.toList();
        final prefs = context.watch<TablePrefsCubit>().state;
        final prefsCubit = context.read<TablePrefsCubit>();
        final scenario = prefs.scenarioFor(outing.id, outing.type);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outing.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title),
                Text(
                  tr.outingTypeSince(outing.type.label, formatTime(outing.startedAt)),
                  style: AppText.caption,
                ),
              ],
            ),
            actions: [
              const SyncBadge(),
              if (outing.isActive)
                IconButton(
                  tooltip: tr.outingFinish,
                  onPressed: _finishing ? null : _finish,
                  icon: const Icon(Icons.flag_outlined),
                ),
              PopupMenuButton<String>(
                tooltip: tr.commonMoreOptions,
                onSelected: (v) {
                  if (v == 'finish') _finish();
                  if (v == 'tracking') _toggleTracking();
                  if (v == 'place') changeOutingPlace(context, outing);
                  if (v == 'map') openOutingInMaps(context, outing);
                },
                itemBuilder: (_) {
                  final tracking = getIt<TrackingCoordinator>();
                  final offer = tracking.prefs.enabled &&
                      tracking.status.value != TrackingStatus.unsupported;
                  return [
                    if (offer)
                      PopupMenuItem(
                        value: 'tracking',
                        child: Text(tracking.isSuppressed(_outingId)
                            ? tr.outingShowOnLock
                            : tr.outingHideHere),
                      ),
                    if (outingHasMapTarget(outing))
                      PopupMenuItem(
                          value: 'map', child: Text(tr.placeOpenInMaps)),
                    PopupMenuItem(
                        value: 'place', child: Text(tr.placeCorrect)),
                    PopupMenuItem(
                        value: 'finish', child: Text(tr.outingFinish)),
                  ];
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                  children: [
                    SurfaceCard(
                      child: Column(children: [
                        Row(children: [
                          BeerGlass(
                            size: 64,
                            fill: summary.alcoholicCount == 0
                                ? 0.15
                                : (0.25 + summary.alcoholicCount * 0.12),
                          ),
                          const SizedBox(width: AppSpace.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr.outingRunningFor, style: AppText.caption),
                                ElapsedText(
                                  since: outing.startedAt,
                                  style: AppText.headline,
                                ),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: AppSpace.lg),
                        Row(children: [
                          Expanded(
                            child: StatTile(
                              label: tr.homeDrinks,
                              value: '${summary.entryCount}',
                            ),
                          ),
                          Expanded(
                            child: StatTile(
                              label: tr.outingYourVolume,
                              value: summary.volumeLabel,
                            ),
                          ),
                          Expanded(
                            child: StatTile(
                              label: tr.homeInformedSpent,
                              value: formatCents(summary.informedCents),
                            ),
                          ),
                        ]),
                        if (summary.unpricedCount > 0 ||
                            summary.unknownVolumeCount > 0 ||
                            summary.incompleteAlcoholCount > 0) ...[
                          const SizedBox(height: AppSpace.md),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: AppSpace.sm,
                              runSpacing: AppSpace.sm,
                              children: [
                                if (summary.unpricedCount > 0)
                                  InfoPill(
                                    tr.homeUnpriced(summary.unpricedCount),
                                    icon: Icons.sell_outlined,
                                    warning: true,
                                  ),
                                if (summary.unknownVolumeCount > 0)
                                  InfoPill(
                                    tr.outingNoVolume(summary.unknownVolumeCount),
                                    icon: Icons.opacity_outlined,
                                    warning: true,
                                  ),
                                if (summary.incompleteAlcoholCount > 0)
                                  InfoPill(
                                    tr.outingAlcoholIncomplete(summary.incompleteAlcoholCount),
                                    icon: Icons.help_outline_rounded,
                                    warning: true,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ]),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    BudgetSection(
                      budgetCents: outing.budgetCents,
                      summary: summary,
                      onChange: cubit.setBudget,
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Row(children: [
                      Expanded(
                        child: SegmentedButton<TableView>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: TableView.table,
                              icon: Icon(Icons.table_restaurant_outlined),
                              label: Text(tr.tableViewTable),
                            ),
                            ButtonSegment(
                              value: TableView.list,
                              icon: Icon(Icons.view_list_rounded),
                              label: Text(tr.tableViewList),
                            ),
                          ],
                          selected: {prefs.view},
                          onSelectionChanged: (s) =>
                              prefsCubit.setView(s.first),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: tr.tableOptions,
                        onSelected: (v) {
                          if (v == 'scenario') {
                            showScenarioPicker(
                              context,
                              current: scenario,
                              onSelected: (s) =>
                                  prefsCubit.setScenario(outing.id, s),
                            );
                          } else if (v == 'about') {
                            showTableAbout(context);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                              value: 'scenario', child: Text(tr.tableChangeScene)),
                          PopupMenuItem(
                              value: 'about',
                              child: Text(tr.tableAboutMenu)),
                        ],
                      ),
                    ]),
                    if (prefs.view == TableView.table) ...[
                      const SizedBox(height: AppSpace.sm),
                      TableScene(
                        entries: state.entries,
                        scenario: scenario,
                        animate: prefs.animations,
                        onEdit: _edit,
                        onDelete: cubit.deleteEntry,
                      ),
                      if (state.entries.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: AppSpace.sm),
                          child: Text(tr.outingFirstDrinkHint,
                              style: AppText.caption),
                        ),
                    ] else ...[
                      SectionTitle(tr.outingRecords(entries.length)),
                      if (entries.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpace.xl),
                          child: EmptyView(
                            icon: Icons.sports_bar_outlined,
                            title: tr.outingNoDrinks,
                            message: tr.outingNoDrinksBody,
                          ),
                        )
                      else
                        for (final e in entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpace.sm),
                            child: EntryTile(
                              entry: e,
                              onTap: () => _edit(e),
                              onDelete: () => cubit.deleteEntry(e),
                              onRepeat: outing.isActive
                                  ? () => cubit.repeatEntry(e)
                                  : null,
                            ),
                          ),
                    ],
                    const SizedBox(height: AppSpace.md),
                    SurfaceCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding:
                              const EdgeInsets.only(bottom: AppSpace.md),
                          title: Text(tr.glassBigTitle,
                              style: AppText.subtitle),
                          subtitle: Text(tr.glassBigSubtitle,
                              style: AppText.caption),
                          children: [
                            AccumulatedGlass(
                              alcoholicMl: summary.alcoholicMl,
                              otherMl: summary.otherMl,
                              unknownVolumeCount: summary.unknownVolumeCount,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    TabEntryCard(outingId: outing.id),
                    const SizedBox(height: AppSpace.lg),
                    // A real, findable button (not a lost link). Amber outline, no
                    // red: finishing is normal, and the sheet still asks.
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppColors.amber,
                        side: const BorderSide(color: AppColors.amber, width: 1.5),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      onPressed: _finishing ? null : _finish,
                      icon: const Icon(Icons.flag_outlined),
                      label: Text(tr.outingFinish),
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (last != null) ...[
                      _RepeatButton(entry: last, onPressed: cubit.repeatLast),
                      const SizedBox(height: AppSpace.sm),
                    ],
                    Row(children: [
                      Expanded(
                        child: last == null
                            ? FilledButton.icon(
                                onPressed: _addDrink,
                                icon: const Icon(Icons.add_rounded),
                                label: Text(tr.outingAddDrink),
                              )
                            : OutlinedButton.icon(
                                onPressed: _addDrink,
                                icon: const Icon(Icons.add_rounded),
                                label: Text(tr.outingAddDrink),
                              ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                        ),
                        onPressed: cubit.addWater,
                        icon: const Icon(Icons.water_drop_outlined,
                            color: Color(0xFF6EC1E4)),
                        label: Text(tr.drinkWater),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({required this.entry, required this.onPressed});

  final DrinkEntry entry;
  final VoidCallback onPressed;

  String get _what {
    final container = entry.containerMl;
    final personal = entry.personalMl;
    if (entry.isMixed) {
      return entry.composition!.customized
          ? tr.repeatAdjusted(entry.name)
          : entry.name;
    }
    final size = container == null ? '' : ' ${formatMl(container)}';
    return entry.isShared && personal != null
        ? '${entry.name}$size · ${tr.repeatYourPart(formatMl(personal))}'
        : '${entry.name}$size';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tr.repeatSemantics(_what),
      child: Material(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.lg, vertical: AppSpace.sm),
              child: Row(children: [
                const Icon(Icons.replay_rounded,
                    color: Color(0xFF241800), size: 22),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tr.repeatButton,
                        style: const TextStyle(
                          color: Color(0xFF241800),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        [
                          _what,
                          if (entry.priceKind == PriceKind.informed &&
                              entry.paidCents != null)
                            formatCents(entry.paidCents!),
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xCC241800), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// A drink record row, used in the running outing and in the summary.
class EntryTile extends StatelessWidget {
  const EntryTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.onDelete,
    this.onRepeat,
  });

  final DrinkEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  /// Only in the running outing: logs this same drink again, now.
  final VoidCallback? onRepeat;

  String get _priceText => switch (entry.priceKind) {
        PriceKind.informed => formatCents(entry.paidCents ?? 0),
        PriceKind.complimentary => tr.priceComplimentary,
        PriceKind.unknown => tr.priceNone,
      };

  @override
  Widget build(BuildContext context) {
    final personal = entry.personalMl;
    final container = entry.containerMl;
    final alcohol = entry.alcohol;
    final meta = <String>[
      formatTime(entry.consumedAt),
      if (entry.isMixed && entry.composition!.customized) tr.groupRecipeAdjusted,
      if (entry.presentation != null && !entry.isShared)
        localizePresentation(entry.presentation!),
      if (entry.isShared && personal != null && container != null)
        tr.entrySharedPart(
            entry.peopleCount, formatMl(personal), formatMl(container))
      else if (personal == null)
        tr.groupVolumeUnknown
      else if (entry.presentation == null)
        formatMl(personal),
      if (entry.isMixed && alcohol != null && !alcohol.isComplete)
        tr.entryAlcoholIncomplete,
    ];
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
          AppSpace.md, AppSpace.sm, AppSpace.xs, AppSpace.sm),
      child: Row(children: [
        Icon(entry.category.icon, color: AppColors.amber),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
              const SizedBox(height: 2),
              Text(meta.join(' · '), style: AppText.caption),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Text(
          _priceText,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: entry.hasPrice ? AppColors.text : AppColors.textMuted,
          ),
        ),
        PopupMenuButton<String>(
          tooltip: tr.entryOptions,
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.textMuted),
          onSelected: (v) {
            if (v == 'edit') onTap();
            if (v == 'repeat') onRepeat?.call();
            if (v == 'delete') onDelete?.call();
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(tr.entryCorrect)),
            if (onRepeat != null)
              PopupMenuItem(value: 'repeat', child: Text(tr.entryRepeat)),
            if (onDelete != null)
              PopupMenuItem(value: 'delete', child: Text(tr.commonDelete)),
          ],
        ),
      ]),
    );
  }
}

class _FinishSheet extends StatefulWidget {
  const _FinishSheet({required this.startedAt, required this.entryCount});

  final DateTime startedAt;
  final int entryCount;

  @override
  State<_FinishSheet> createState() => _FinishSheetState();
}

class _FinishSheetState extends State<_FinishSheet> {
  late DateTime _endedAt = DateTime.now();

  bool get _valid => !_endedAt.isBefore(widget.startedAt);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl,
            AppSpace.lg + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.finishTitle, style: AppText.title),
            const SizedBox(height: AppSpace.xs),
            Text(tr.finishBody(widget.entryCount), style: AppText.caption),
            const SizedBox(height: AppSpace.lg),
            SurfaceCard(
              onTap: () async {
                final picked = await pickDateTime(context, _endedAt);
                if (picked != null) setState(() => _endedAt = picked);
              },
              child: Row(children: [
                const Icon(Icons.flag_rounded, color: AppColors.amber),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(tr.finishEnd(formatDateTime(_endedAt)),
                      style: AppText.subtitle),
                ),
                Text(tr.commonAdjust,
                    style: const TextStyle(color: AppColors.amber)),
              ]),
            ),
            if (!_valid)
              Padding(
                padding: EdgeInsets.only(top: AppSpace.sm),
                child: Text(tr.repoEndBeforeStart,
                    style: const TextStyle(color: AppColors.danger)),
              ),
            const SizedBox(height: AppSpace.xl),
            FilledButton(
              onPressed:
                  _valid ? () => Navigator.pop(context, _endedAt) : null,
              child: Text(tr.finishAndSummary),
            ),
            const SizedBox(height: AppSpace.xs),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr.finishKeepGoing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
