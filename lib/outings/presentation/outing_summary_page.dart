import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/drink_entry_page.dart';
import '../domain/outing_summary.dart';
import '../../table/data/table_prefs_cubit.dart';
import '../../table/presentation/table_scene.dart';
import 'budget_section.dart';
import '../../drinks/presentation/add_drink_page.dart';
import '../../home/presentation/feedback_details_sheet.dart';
import '../../share/presentation/share_card_page.dart';
import '../../outing_drinks/presentation/outing_scan_section.dart';
import 'outing_cubit.dart';
import '../../tab/presentation/tab_entry_card.dart';
import 'price_fix_page.dart';
import '../../places/presentation/change_outing_place.dart';
import 'outing_page.dart' show EntryTile;
import '../../l10n/l10n.dart';

/// Summary of a finished outing. Records can still be corrected here, and the
/// totals are recalculated from the records.
class OutingSummaryPage extends StatelessWidget {
  const OutingSummaryPage({super.key, required this.outingId});

  final String outingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OutingCubit>(param1: outingId),
      child: const _SummaryView(),
    );
  }
}

class _SummaryView extends StatefulWidget {
  const _SummaryView();

  @override
  State<_SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<_SummaryView> {
  StreamSubscription<OutingNotice>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = context.read<OutingCubit>().notices.listen((n) {
      if (!mounted) return;
      final m = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      m.showSnackBar(
        SnackBar(
          content: Text(n.text),
          duration: const Duration(seconds: 5),
          persist: false,
          action: n.undo == null
              ? null
              : SnackBarAction(
                  label: n.undoLabel ?? tr.commonUndo,
                  onPressed: () => n.undo!(),
                ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
          : tr.summaryUpdated,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OutingCubit>();
    return BlocBuilder<OutingCubit, OutingState>(
      builder: (context, state) {
        if (state.loading) return const Scaffold(body: LoadingView());
        final outing = state.outing;
        if (outing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(message: tr.outingNotFound),
          );
        }
        final s = state.summary!;
        final endedAt = outing.endedAt ?? DateTime.now();
        return Scaffold(
          appBar: AppBar(
            title: Text(tr.summaryTitle),
            actions: [
              IconButton(
                tooltip: tr.summaryShare,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShareCardPage(outingId: outing.id),
                  ),
                ),
                icon: const Icon(Icons.ios_share_rounded),
              ),
              const SyncBadge(),
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
                      highlight: true,
                      padding: const EdgeInsets.all(AppSpace.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                outing.type.icon,
                                color: AppColors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpace.sm),
                              Text(outing.type.label, style: AppText.caption),
                            ],
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Text(outing.displayName, style: AppText.headline),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            formatWeekdayDate(outing.startedAt),
                            style: AppText.subtitle.copyWith(
                              color: AppColors.amber,
                            ),
                          ),
                          if (outing.subtitleAddress != null)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpace.xs),
                              child: Text(
                                outing.subtitleAddress!,
                                style: AppText.caption,
                              ),
                            ),
                          if (outing.nickname != null &&
                              outing.placeName != null &&
                              outing.placeName != outing.nickname)
                            Text(outing.placeName!, style: AppText.caption),
                          Wrap(
                            spacing: AppSpace.sm,
                            children: [
                              if (outingHasMapTarget(outing))
                                TextButton.icon(
                                  onPressed: () =>
                                      openOutingInMaps(context, outing),
                                  icon: const Icon(
                                    Icons.map_outlined,
                                    size: 18,
                                  ),
                                  label: Text(tr.placeOpenInMaps),
                                ),
                              TextButton.icon(
                                onPressed: () =>
                                    changeOutingPlace(context, outing),
                                icon: const Icon(
                                  Icons.edit_location_alt_outlined,
                                  size: 18,
                                ),
                                label: Text(tr.placeCorrect),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.lg),
                          Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                  label: tr.summaryStart,
                                  value: formatTime(outing.startedAt),
                                ),
                              ),
                              Expanded(
                                child: StatTile(
                                  label: tr.summaryEnd,
                                  value: formatTime(endedAt),
                                ),
                              ),
                              Expanded(
                                child: StatTile(
                                  label: tr.summaryDuration,
                                  value: formatDuration(
                                    outing.durationAt(endedAt),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (state.entries.isNotEmpty) ...[
                      SectionTitle(tr.settingsTable),
                      TableScene(
                        entries: state.entries,
                        scenario: context
                            .watch<TablePrefsCubit>()
                            .state
                            .scenarioFor(outing.id, outing.type),
                        animate: false,
                        retrospective: true,
                        compact: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.sm),
                        child: Text(tr.summaryRetro, style: AppText.caption),
                      ),
                    ],
                    SectionTitle(tr.summaryConsumption),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                  label: tr.homeDrinks,
                                  value: '${s.entryCount}',
                                  icon: Icons.local_bar_rounded,
                                ),
                              ),
                              Expanded(
                                child: StatTile(
                                  label: tr.outingYourVolume,
                                  value: s.volumeLabel,
                                  icon: Icons.opacity_rounded,
                                ),
                              ),
                            ],
                          ),
                          if (s.groups.isNotEmpty) ...[
                            const Divider(height: 28),
                            for (final g in s.groups) _GroupRow(group: g),
                          ],
                          if (s.alcoholicCount > 0) ...[
                            const Divider(height: 28),
                            _AlcoholInfo(summary: s),
                          ],
                        ],
                      ),
                    ),
                    SectionTitle(tr.summarySpending),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatTile(
                            label: tr.summarySpentOnDrinks,
                            value: formatCents(s.informedCents),
                            icon: Icons.payments_outlined,
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Text(s.financeLine, style: AppText.caption),
                          if (outing.budgetCents != null) ...[
                            const SizedBox(height: AppSpace.md),
                            BudgetSection(
                              budgetCents: outing.budgetCents,
                              summary: s,
                              editable: false,
                              onChange: (_) {},
                            ),
                          ],
                          if (s.unpricedCount > 0) ...[
                            const SizedBox(height: AppSpace.md),
                            InfoPill(
                              tr.summaryUnpricedPill(s.unpricedCount),
                              icon: Icons.sell_outlined,
                              warning: true,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PriceFixPage(outingId: outing.id),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.edit_note_rounded,
                                  size: 18,
                                ),
                                label: Text(tr.summaryFillPrices),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SectionTitle(tr.summaryYourAccount),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (outing.feedbackMood != null)
                            Row(
                              children: [
                                Icon(
                                  outing.feedbackMood!.icon,
                                  color: AppColors.amber,
                                  size: 28,
                                ),
                                const SizedBox(width: AppSpace.md),
                                Text(
                                  outing.feedbackMood!.label,
                                  style: AppText.title,
                                ),
                                const Spacer(),
                                Text(
                                  tr.summaryYourAccountTag,
                                  style: AppText.caption,
                                ),
                              ],
                            )
                          else
                            Text(tr.summaryNoAccount, style: AppText.caption),
                          if (outing.wakeFeeling != null ||
                              outing.hangover != null) ...[
                            const SizedBox(height: AppSpace.md),
                            Wrap(
                              spacing: AppSpace.sm,
                              runSpacing: AppSpace.sm,
                              children: [
                                if (outing.wakeFeeling != null)
                                  InfoPill(
                                    tr.summaryWoke(
                                      outing.wakeFeeling!.label.toLowerCase(),
                                    ),
                                  ),
                                if (outing.hangover != null)
                                  InfoPill(
                                    tr.summaryHangover(
                                      outing.hangover!.label.toLowerCase(),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          if (outing.feedbackNote != null) ...[
                            const SizedBox(height: AppSpace.md),
                            Text(outing.feedbackNote!, style: AppText.body),
                          ],
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => showFeedbackDetails(
                                context,
                                outing.id,
                                editMood: true,
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: Text(
                                outing.feedbackMood == null
                                    ? tr.summaryAddAccount
                                    : tr.summaryEditAccount,
                              ),
                            ),
                          ),
                          Text(tr.summaryAccountNote, style: AppText.caption),
                        ],
                      ),
                    ),
                    SectionTitle(tr.summaryTab),
                    TabEntryCard(outingId: outing.id, detailed: true),
                    OutingScanSection(outingId: outing.id),
                    SectionTitle(tr.outingRecords(state.entries.length)),
                    if (state.entries.isEmpty)
                      EmptyView(
                        icon: Icons.sports_bar_outlined,
                        title: tr.summaryNoRecords,
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Text(
                          tr.summaryTapToCorrect,
                          style: AppText.caption,
                        ),
                      ),
                      for (final e in state.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.sm),
                          child: EntryTile(
                            entry: e,
                            onTap: () => _edit(e),
                            onDelete: () => cubit.deleteEntry(e),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              BottomActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddDrinkPage(outingId: outing.id),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(tr.summaryAddForgotten),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(tr.summaryDone),
                    ),
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

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});

  final DrinkGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              tr.groupTimes(group.count),
              style: const TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  group.detail,
                  style: AppText.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Text(
            group.personalMl == null
                ? tr.groupVolumeUnknownShort
                : formatMl(group.personalMl!),
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}

class _AlcoholInfo extends StatelessWidget {
  const _AlcoholInfo({required this.summary});

  final OutingSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatTile(
          label: tr.alcoholDeclared,
          value: summary.alcoholIncomplete
              ? tr.alcoholAtLeast(formatGrams(summary.pureAlcoholGrams))
              : formatGrams(summary.pureAlcoholGrams),
          icon: Icons.science_outlined,
        ),
        const SizedBox(height: AppSpace.sm),
        if (summary.incompleteAlcoholCount > 0) ...[
          InfoPill(
            tr.alcoholIncompletePill(summary.incompleteAlcoholCount),
            icon: Icons.help_outline_rounded,
            warning: true,
          ),
          const SizedBox(height: AppSpace.sm),
        ],
        if (summary.unknownVolumeCount > 0) ...[
          InfoPill(
            tr.alcoholNoVolumePill(summary.unknownVolumeCount),
            icon: Icons.opacity_outlined,
            warning: true,
          ),
          const SizedBox(height: AppSpace.sm),
        ],
        Text(tr.alcoholExplain, style: AppText.caption),
      ],
    );
  }
}
