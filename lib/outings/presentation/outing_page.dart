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
import '../../drinks/presentation/drink_entry_page.dart';
import '../../places/presentation/change_outing_place.dart';
import 'outing_actions.dart';
import '../../scan/data/scan_draft_store.dart';
import '../../table/data/table_prefs_cubit.dart';
import '../../table/presentation/table_scene.dart';
import '../../table/presentation/table_sheets.dart';
import '../../glass/presentation/accumulated_glass.dart';
import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../tab/data/tab_repository.dart';
import '../../tab/domain/tab_calc.dart';
import '../../tab/domain/tab_models.dart';
import '../../tab/presentation/split_page.dart';
import '../../tab/presentation/tab_cubit.dart';
import '../../tab/presentation/tab_extra_sheet.dart';
import '../../tab/presentation/tab_page.dart';
import '../../tab/presentation/tab_share_page.dart';
import '../../table/domain/table_orders.dart';
import '../../table/presentation/bill_view.dart';
import '../../table/presentation/order_page.dart';
import '../../table/presentation/orders_view.dart';
import '../../table/presentation/people_bar.dart';
import '../../table/presentation/people_view.dart';
import '../../table/presentation/person_avatar.dart';
import '../../table/presentation/person_sheets.dart';
import '../../tracking/application/tracking_coordinator.dart';
import '../../tracking/application/tracking_links.dart';
import '../../tracking/presentation/tracking_offer_sheet.dart';
import '../domain/outing.dart';
import 'budget_section.dart';
import 'outing_cubit.dart';
import '../../l10n/l10n.dart';
import '../../drinks/domain/presentation_label.dart';

/// Running outing. Pops with the outing id after it is finished, so the
/// caller can show the summary.
class OutingPage extends StatelessWidget {
  const OutingPage({
    super.key,
    required this.outingId,
    this.finishOnOpen = false,
  });

  final String outingId;

  /// Opens the finish confirmation right away (Home shortcut).
  final bool finishOnOpen;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<OutingCubit>(param1: outingId)),
        BlocProvider(
          create: (_) => TabCubit(
            outingId,
            getIt<TabRepository>(),
            getIt<DrinkRepository>(),
            getIt<OutingRepository>(),
          ),
        ),
      ],
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

  /// Whole table or one person; and which of the three views is open.
  PersonFilter _filter = const PersonFilter.table();
  _TableTab _tab = _TableTab.orders;

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
      // An outing made before people existed becomes a table when that cannot
      // change a number (its tab was never used).
      unawaited(context.read<TabCubit>().ensureTable());
      _onPending();
      if (widget.finishOnOpen && cubit.state.outing?.isActive == true) {
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
      if (getIt<DrinkRepository>().lastPersonalIndividual(_outingId) == null) {
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
      suppressed ? tr.outingTrackingBack : tr.outingTrackingHidden,
    );
  }

  void _showNotice(OutingNotice notice) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(notice.text),
        duration: const Duration(seconds: 5),
        persist: false,
        action: notice.undo == null
            ? null
            : SnackBarAction(
                label: notice.undoLabel ?? tr.commonUndo,
                onPressed: () => notice.undo!(),
              ),
      ),
    );
  }

  /// "Bebida": the new order form, for the person on screen (or a choice when
  /// the whole table is shown).
  Future<void> _addDrink({String initialText = '', Set<String>? who}) async {
    final cubit = context.read<OutingCubit>();
    final doc = context.read<TabCubit>().state.doc;
    final saved = await Navigator.of(context).push<List<DrinkEntry>>(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          outingId: cubit.outingId,
          doc: doc,
          preselected: who ?? TableOrders.preselect(doc, _safeFilter(doc)),
          initialText: initialText,
        ),
      ),
    );
    if (saved == null || !mounted) return;
    if (saved.isEmpty) {
      // Saved through the catalog/label/menu flow.
      showToast(context, tr.outingDrinkLogged);
      return;
    }
    cubit.announceAdded(_summaryOf(saved), [for (final e in saved) e.id]);
  }

  String _summaryOf(List<DrinkEntry> list) {
    final doc = context.read<TabCubit>().state.doc;
    final byName = <String, int>{};
    for (final e in list) {
      byName[e.name] = (byName[e.name] ?? 0) + 1;
    }
    final names = [
      for (final kv in byName.entries)
        kv.value > 1 ? '${kv.value}× ${kv.key}' : kv.key,
    ].join(', ');
    final who = <String>{
      for (final e in list) ...TableOrders.consumersOf(e, doc),
    };
    final people = [
      for (final id in who) doc.participant(id)?.displayName ?? '?',
    ].join(', ');
    return '$names · $people';
  }

  PersonFilter _safeFilter(TabDoc doc) =>
      _filter.isTable || doc.participant(_filter.personId!) != null
      ? _filter
      : const PersonFilter.table();

  Future<void> _addExtra({required bool food}) async {
    final tab = context.read<TabCubit>();
    final doc = tab.state.doc;
    final extra = await showTabExtraSheet(
      context,
      newId: tab.newId(),
      participants: doc.participants,
      explicitWho: true,
      defaultCategory: food ? ExtraCategory.food : ExtraCategory.cover,
      categories: food
          ? const [ExtraCategory.food]
          : const [
              ExtraCategory.cover,
              ExtraCategory.starter,
              ExtraCategory.transport,
              ExtraCategory.other,
            ],
      title: food ? tr.actionFood : tr.actionOther,
    );
    if (extra != null) await tab.saveExtra(extra);
  }

  Future<void> _water() async {
    final cubit = context.read<OutingCubit>();
    final tab = context.read<TabCubit>();
    final doc = tab.state.doc;
    final f = _safeFilter(doc);
    if (f.isTable) {
      // Whole table: the person must be chosen, nothing is assumed.
      await _addDrink(initialText: tr.drinkWater);
      return;
    }
    final consumer = f.personId == doc.me?.id ? null : f.personId;
    await cubit.addWater(consumerId: consumer);
  }

  Future<void> _editRow(OrderRow row) async {
    final tab = context.read<TabCubit>();
    if (row.extra != null) {
      final doc = tab.state.doc;
      final x = await showTabExtraSheet(
        context,
        newId: tab.newId(),
        participants: doc.participants,
        existing: row.extra,
        explicitWho: doc.autoLink,
      );
      if (x != null) await tab.saveExtra(x);
      return;
    }
    final e = row.latest;
    if (e != null) await _edit(e);
  }

  Future<void> _deleteRow(OrderRow row) async {
    final cubit = context.read<OutingCubit>();
    final tab = context.read<TabCubit>();
    if (row.extra != null) {
      final x = row.extra!;
      await tab.removeExtra(x.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(tr.noticeEntryDeleted),
            persist: false,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: tr.commonUndo,
              onPressed: () => tab.saveExtra(x),
            ),
          ),
        );
      return;
    }
    final e = row.latest;
    if (e != null) await cubit.deleteEntry(e);
  }

  Future<void> _repeatRow(OrderRow row) async {
    final cubit = context.read<OutingCubit>();
    final tab = context.read<TabCubit>();
    final doc = tab.state.doc;
    final e = row.latest;
    if (e == null) return;
    // Someone in the order left (or is not on the table): the order is not
    // repeated for them invisibly; the form opens with what is still present.
    final people = TableOrders.consumersOf(e, doc);
    final gone = [
      for (final id in people)
        if (doc.participant(id) == null || doc.participant(id)!.left) id,
    ];
    if (gone.isEmpty) {
      await cubit.repeatEntry(e);
      return;
    }
    final names = [
      for (final id in gone) doc.participant(id)?.displayName ?? tr.ordersUnassigned,
    ].join(', ');
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.repeatLeftTitle(names)),
        content: Text(tr.repeatLeftBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('repeat-adjust'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.repeatLeftAdjust),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      await _addDrink(
        initialText: e.name,
        who: {
          for (final id in people)
            if (doc.participant(id) != null && !doc.participant(id)!.left) id,
        },
      );
    }
  }

  /// "Passar para outra pessoa": gives the records of an individual order to
  /// someone else. If the order has a typed cost split, it asks first: follow
  /// the new person or keep the split as typed.
  Future<void> _moveRow(OrderRow row) async {
    final cubit = context.read<OutingCubit>();
    final tab = context.read<TabCubit>();
    final doc = tab.state.doc;
    final picked = await showModalBottomSheet<Participant>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr.ordersMoveTo, style: AppText.title),
            for (final p in doc.present)
              ListTile(
                key: ValueKey('move-${p.id}'),
                leading: PersonAvatar(
                  person: p,
                  index: doc.participants.indexOf(p),
                ),
                title: Text(p.displayName),
                onTap: () => Navigator.pop(ctx, p),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final custom = [
      for (final e in row.entries)
        if (doc.linkFor(e.id)?.assign != null) e,
    ];
    var followNew = true;
    if (custom.isNotEmpty) {
      final choice = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr.moveCustomTitle),
          content: Text(tr.moveCustomBody(picked.displayName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr.moveKeepSplit),
            ),
            FilledButton(
              key: const ValueKey('move-follow'),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr.moveFollow(picked.displayName)),
            ),
          ],
        ),
      );
      if (choice == null) return;
      followNew = choice;
    }
    if (followNew) {
      for (final e in custom) {
        await tab.setLineAssign(
          TabCalculator.entryLine(e, TabLink(entryId: e.id)),
          null,
        );
      }
    }
    final toOwner = picked.id == doc.me?.id;
    await cubit.moveEntries(
      row.entries,
      toOwner ? null : picked.id,
      toName: picked.displayName,
    );
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
      if (mounted && getIt<ScanDraftStore>().openFor(outing.id).isNotEmpty) {
        // An unfinished label/menu reading stays tied to this outing.
        showToast(context, tr.outingOpenScan);
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
        return BlocBuilder<TabCubit, TabState>(
          builder: (context, tabState) =>
              _scaffold(context, cubit, state, outing, tabState),
        );
      },
    );
  }

  /// The three numbers on top follow who is on screen: the whole table (orders,
  /// total, the owner's part) or one person (their drinks, volume and part).
  List<Widget> _tiles(
    OutingState state,
    TabState tabState,
    PersonFilter filter,
    Map<String, PersonConsumption> consumption,
  ) {
    final doc = tabState.doc;
    final r = tabState.result;
    final me = doc.me;
    if (filter.isTable) {
      final items = TableOrders.itemCount(doc, tabState.entries.values);
      return [
        StatTile(label: tr.tileItems, value: '$items'),
        StatTile(
          label: tr.tileTableTotal,
          value: r.isPartial
              ? tr.billTotalKnownShort(formatCents(r.total))
              : formatCents(r.total),
        ),
        StatTile(
          label: tr.tileYourShare,
          value: me == null ? '—' : formatCents(r.shareOf(me.id)),
        ),
      ];
    }
    final id = filter.personId!;
    final c = consumption[id];
    final isMe = id == me?.id;
    final volume = c == null || c.count == 0
        ? formatMl(0)
        : (c.unknownCount == 0
              ? formatMl(c.knownMl)
              : (c.knownMl == 0
                    ? tr.volumeUnknown
                    : tr.volumeKnownPlusUnknown(formatMl(c.knownMl), c.unknownCount)));
    return [
      StatTile(label: tr.homeDrinks, value: '${c?.count ?? 0}'),
      StatTile(
        label: isMe ? tr.outingYourVolume : tr.tileVolume,
        value: isMe ? state.summary!.volumeLabel : volume,
      ),
      StatTile(
        label: isMe ? tr.tileYourShare : tr.tileTheirShare,
        value: formatCents(r.shareOf(id)),
      ),
    ];
  }

  /// The three add buttons share one row on a phone: tight padding and a label
  /// that scales down instead of wrapping.
  static final _actionStyle = FilledButton.styleFrom(
    minimumSize: const Size(0, 52),
    padding: const EdgeInsets.symmetric(horizontal: 8),
  );
  static final _outlinedActionStyle = OutlinedButton.styleFrom(
    minimumSize: const Size(0, 52),
    padding: const EdgeInsets.symmetric(horizontal: 8),
  );

  Widget _actionLabel(String text) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1),
  );

  DrinkEntry? _lastFor(TabState tabState, PersonFilter filter) {
    final doc = tabState.doc;
    final list = [
      for (final e in tabState.entries.values)
        if (!e.isDeleted &&
            e.isAlcoholic &&
            (filter.isTable ||
                TableOrders.consumersOf(e, doc).contains(filter.personId)))
          e,
    ]..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    return list.isEmpty ? null : list.last;
  }

  String _whoLabel(DrinkEntry e, TabDoc doc) => [
    for (final id in TableOrders.consumersOf(e, doc))
      doc.participant(id)?.displayName ?? tr.ordersUnassigned,
  ].join(', ');

  Widget _scaffold(
    BuildContext context,
    OutingCubit cubit,
    OutingState state,
    Outing outing,
    TabState tabState,
  ) {
    final tab = context.read<TabCubit>();
    final doc = tabState.doc;
    final result = tabState.result;
    final filter = _safeFilter(doc);
    final summary = state.summary!;
    final prefs = context.watch<TablePrefsCubit>().state;
    final prefsCubit = context.read<TablePrefsCubit>();
    final scenario = prefs.scenarioFor(outing.id, outing.type);
    final consumption = TabCalculator.consumption(
      doc,
      tabState.entries.values,
    );
    final rows = TableOrders.rows(doc, tabState.entries, filter);
    final last = _lastFor(tabState, filter);
    final viewEntries = [
      for (final e in tabState.entries.values)
        if (!e.isDeleted &&
            (filter.isTable ||
                TableOrders.consumersOf(e, doc).contains(filter.personId)))
          e,
    ]..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    final showLegacy = outing.isActive && !doc.autoLink;
    final isMeView = !filter.isTable && filter.personId == doc.me?.id;
    final c = filter.isTable ? null : consumption[filter.personId];
    final pills = filter.isTable
        ? [
            if (result.pendingCount > 0)
              InfoPill(
                tr.homeUnpriced(result.pendingCount),
                icon: Icons.sell_outlined,
                warning: true,
              ),
            if (consumption.values.any((x) => x.unknownCount > 0))
              InfoPill(
                tr.outingNoVolume(
                  consumption.values.fold(0, (a, x) => a + x.unknownCount),
                ),
                icon: Icons.opacity_outlined,
                warning: true,
              ),
          ]
        : [
            if (isMeView && summary.unpricedCount > 0)
              InfoPill(
                tr.homeUnpriced(summary.unpricedCount),
                icon: Icons.sell_outlined,
                warning: true,
              ),
            if ((c?.unknownCount ?? 0) > 0)
              InfoPill(
                tr.outingNoVolume(c!.unknownCount),
                icon: Icons.opacity_outlined,
                warning: true,
              ),
            if (isMeView && summary.incompleteAlcoholCount > 0)
              InfoPill(
                tr.outingAlcoholIncomplete(summary.incompleteAlcoholCount),
                icon: Icons.help_outline_rounded,
                warning: true,
              ),
          ];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              outing.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.title,
            ),
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
              if (v == 'edit') showEditOutingSheet(context, outing);
              if (v == 'delete') confirmDeleteOuting(context, outing);
              if (v == 'map') openOutingInMaps(context, outing);
            },
            itemBuilder: (_) {
              final tracking = getIt<TrackingCoordinator>();
              final offer =
                  tracking.prefs.enabled &&
                  tracking.status.value != TrackingStatus.unsupported;
              return [
                if (offer)
                  PopupMenuItem(
                    value: 'tracking',
                    child: Text(
                      tracking.isSuppressed(_outingId)
                          ? tr.outingShowOnLock
                          : tr.outingHideHere,
                    ),
                  ),
                if (outingHasMapTarget(outing))
                  PopupMenuItem(value: 'map', child: Text(tr.placeOpenInMaps)),
                PopupMenuItem(value: 'edit', child: Text(tr.outingEditTitle)),
                PopupMenuItem(value: 'place', child: Text(tr.placeCorrect)),
                if (outing.isActive)
                  PopupMenuItem(value: 'finish', child: Text(tr.outingFinish)),
                PopupMenuItem(value: 'delete', child: Text(tr.outingDelete)),
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
                AppSpace.gutter,
                0,
                AppSpace.gutter,
                AppSpace.xl,
              ),
              children: [
                SurfaceCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
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
                        ],
                      ),
                      const SizedBox(height: AppSpace.lg),
                      Row(
                        key: const ValueKey('tiles'),
                        children: [
                          for (final t in _tiles(state, tabState, filter, consumption))
                            Expanded(child: t),
                        ],
                      ),
                      if (pills.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.md),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: AppSpace.sm,
                            runSpacing: AppSpace.sm,
                            children: pills,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                PeopleBar(
                  doc: doc,
                  filter: filter,
                  onChanged: (f) => setState(() => _filter = f),
                  onAdd: () => addPersonFlow(context, tab),
                  onManage: (p) => managePersonFlow(context, tab, p),
                ),
                if (showLegacy) ...[
                  const SizedBox(height: AppSpace.sm),
                  _LegacyBanner(onConvert: tab.convertToTable),
                ],
                const SizedBox(height: AppSpace.sm),
                BudgetSection(
                  budgetCents: outing.budgetCents,
                  summary: summary,
                  onChange: cubit.setBudget,
                ),
                const SizedBox(height: AppSpace.sm),
                SegmentedButton<_TableTab>(
                  key: const ValueKey('table-tabs'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: _TableTab.orders,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: Text(tr.tabOrders),
                    ),
                    ButtonSegment(
                      value: _TableTab.people,
                      icon: const Icon(Icons.groups_rounded),
                      label: Text(tr.tabPeople),
                    ),
                    ButtonSegment(
                      value: _TableTab.bill,
                      icon: const Icon(Icons.payments_outlined),
                      label: Text(tr.tabBill),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),
                const SizedBox(height: AppSpace.md),
                if (_tab == _TableTab.orders) ...[
                  SectionTitle(tr.ordersTitle(rows.length)),
                  OrdersView(
                    rows: rows,
                    doc: doc,
                    active: outing.isActive,
                    onEdit: _editRow,
                    onRepeat: _repeatRow,
                    onDelete: _deleteRow,
                    onMove: _moveRow,
                  ),
                  const SizedBox(height: AppSpace.md),
                  SurfaceCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: const ValueKey('illustrated-table'),
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(bottom: AppSpace.md),
                        title: Text(tr.tableIllustrated, style: AppText.subtitle),
                        subtitle: Text(tr.tableIllustratedHint, style: AppText.caption),
                        children: [
                          TableScene(
                            entries: viewEntries,
                            scenario: scenario,
                            animate: prefs.animations,
                            onEdit: _edit,
                            onDelete: cubit.deleteEntry,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: PopupMenuButton<String>(
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
                                  value: 'scenario',
                                  child: Text(tr.tableChangeScene),
                                ),
                                PopupMenuItem(
                                  value: 'about',
                                  child: Text(tr.tableAboutMenu),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_tab == _TableTab.people)
                  PeopleView(
                    doc: doc,
                    result: result,
                    consumption: consumption,
                    onSeeOrders: (p) => setState(() {
                      _filter = PersonFilter.person(p.id);
                      _tab = _TableTab.orders;
                    }),
                    onManage: (p) => managePersonFlow(context, tab, p),
                  ),
                if (_tab == _TableTab.bill)
                  BillView(
                    doc: doc,
                    result: result,
                    onSettings: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TabPage(outingId: outing.id),
                      ),
                    ),
                    onSplit: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SplitPage(cubit: tab)),
                    ),
                    onShare: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TabSharePage(
                          outing: outing,
                          doc: doc,
                          result: result,
                        ),
                      ),
                    ),
                  ),
                if (isMeView || doc.participants.length <= 1) ...[
                  const SizedBox(height: AppSpace.md),
                  SurfaceCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(bottom: AppSpace.md),
                        title: Text(tr.glassBigTitle, style: AppText.subtitle),
                        subtitle: Text(tr.glassBigSubtitle, style: AppText.caption),
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
                ],
                const SizedBox(height: AppSpace.lg),
                // A real, findable button (not a lost link). Amber outline, no
                // red: finishing is normal, and the sheet still asks. Finishing
                // does not mean the bill was paid.
                OutlinedButton.icon(
                  key: const ValueKey('finish-outing'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.amber,
                    side: const BorderSide(color: AppColors.amber, width: 1.5),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                  _RepeatButton(
                    entry: last,
                    who: _whoLabel(last, doc),
                    onPressed: () {
                      final row = TableOrders.rowOfEntry(doc, last);
                      if (row != null) _repeatRow(row);
                    },
                  ),
                  const SizedBox(height: AppSpace.sm),
                ],
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        key: const ValueKey('add-drink'),
                        style: _actionStyle,
                        onPressed: _addDrink,
                        icon: const Icon(Icons.local_bar_outlined, size: 20),
                        label: _actionLabel(tr.actionDrink),
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('add-food'),
                        style: _outlinedActionStyle,
                        onPressed: () => _addExtra(food: true),
                        icon: const Icon(Icons.restaurant_rounded, size: 20),
                        label: _actionLabel(tr.actionFood),
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('add-other'),
                        style: _outlinedActionStyle,
                        onPressed: () => _addExtra(food: false),
                        icon: const Icon(Icons.receipt_long_outlined, size: 20),
                        label: _actionLabel(tr.actionOther),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('add-water'),
                      tooltip: tr.drinkWater,
                      onPressed: _water,
                      icon: const Icon(
                        Icons.water_drop_outlined,
                        color: Color(0xFF6EC1E4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _TableTab { orders, people, bill }

/// An old outing whose tab was already used: the new model is offered, never
/// forced, because it adds the records that were not on the bill before.
class _LegacyBanner extends StatelessWidget {
  const _LegacyBanner({required this.onConvert});

  final Future<void> Function() onConvert;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('legacy-banner'),
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.legacyTitle, style: AppText.subtitle),
          const SizedBox(height: AppSpace.xs),
          Text(tr.legacyBody, style: AppText.caption),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const ValueKey('legacy-convert'),
              onPressed: onConvert,
              child: Text(tr.legacyAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({
    required this.entry,
    required this.onPressed,
    this.who,
  });

  final DrinkEntry entry;
  final VoidCallback onPressed;

  /// Names of who the repeated order is for ("Mais uma para Ana").
  final String? who;

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
                horizontal: AppSpace.lg,
                vertical: AppSpace.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.replay_rounded,
                    color: Color(0xFF241800),
                    size: 22,
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          who == null ? tr.repeatButton : tr.repeatFor(who!),
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
                            color: Color(0xCC241800),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    this.who,
  });

  final DrinkEntry entry;
  final VoidCallback onTap;

  /// Who the record belongs to, shown when the outing has people.
  final String? who;
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
      ?who,
      formatTime(entry.consumedAt),
      if (entry.isMixed && entry.composition!.customized)
        tr.groupRecipeAdjusted,
      if (entry.presentation != null && !entry.isShared)
        localizePresentation(entry.presentation!),
      if (entry.isShared && personal != null && container != null)
        tr.entrySharedPart(
          entry.peopleCount,
          formatMl(personal),
          formatMl(container),
        )
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
        AppSpace.md,
        AppSpace.sm,
        AppSpace.xs,
        AppSpace.sm,
      ),
      child: Row(
        children: [
          Icon(entry.category.icon, color: AppColors.amber),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle,
                ),
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
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textMuted,
            ),
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
        ],
      ),
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
        padding: EdgeInsets.fromLTRB(
          AppSpace.xl,
          0,
          AppSpace.xl,
          AppSpace.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
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
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, color: AppColors.amber),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Text(
                      tr.finishEnd(formatDateTime(_endedAt)),
                      style: AppText.subtitle,
                    ),
                  ),
                  Text(
                    tr.commonAdjust,
                    style: const TextStyle(color: AppColors.amber),
                  ),
                ],
              ),
            ),
            if (!_valid)
              Padding(
                padding: EdgeInsets.only(top: AppSpace.sm),
                child: Text(
                  tr.repoEndBeforeStart,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            const SizedBox(height: AppSpace.xl),
            FilledButton(
              onPressed: _valid ? () => Navigator.pop(context, _endedAt) : null,
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
