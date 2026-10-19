import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../tracking/presentation/pending_commands_page.dart';

import '../../core/di/injector.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/navigation/outing_flow.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../outings/presentation/outing_summary_page.dart';
import 'feedback_details_sheet.dart';
import 'feedback_sheet.dart';
import '../../outings/domain/outing.dart';
import 'home_cubit.dart';
import '../../l10n/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  @override
  void initState() {
    super.initState();
    // Once per app opening: the feedback sheet for a finished outing, or the
    // "still happening?" question for an outing left running for a long time.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<HomeCubit>();
      cubit.checkFeedback();
      cubit.checkStale();
    });
  }

  Future<T?> _push<T>(Widget page) =>
      Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

  Future<void> _openOuting(String id) => OutingFlow.open(context, id);

  Future<void> _startOuting() => OutingFlow.start(context);

  Future<void> _showStale(HomeState state) async {
    final outing = state.staleOuting!;
    final suggested = state.staleEnd!;
    final cubit = context.read<HomeCubit>();
    final action = await showModalBottomSheet<_StaleAction>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StaleSheet(outing: outing),
    );
    if (!mounted) return;
    if (action == _StaleAction.keep) {
      await cubit.keepOutingRunning(outing.id);
    } else if (action == _StaleAction.end) {
      final picked = await pickDateTime(context, suggested);
      if (picked == null || !mounted) return;
      try {
        await cubit.endOuting(outing.id, picked);
        if (mounted) {
          await _push<void>(OutingSummaryPage(outingId: outing.id));
        }
      } on ArgumentError catch (e) {
        if (mounted) showToast(context, '${e.message}');
      }
    }
  }

  Future<void> _showFeedback(HomeState state) async {
    final outing = state.feedbackOuting!;
    final cubit = context.read<HomeCubit>();
    final result = await showModalBottomSheet<FeedbackResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FeedbackSheet(outing: outing),
    );
    switch (result) {
      case FeedbackAnswered(:final mood):
        await cubit.answerFeedback(outing.id, mood);
        if (!mounted) return;
        // Optional follow-up; skipping it is always fine.
        final more = await showFeedbackDetails(context, outing.id);
        if (more == FeedbackDetailsResult.review && mounted) {
          await _push<void>(OutingSummaryPage(outingId: outing.id));
        }
      case FeedbackDismissed():
        await cubit.dismissFeedback(outing.id);
      case FeedbackSnoozed():
      case null:
        // Swiping the sheet away counts as "later", so it is not shown again
        // on every visit to the home screen.
        await cubit.snoozeFeedback(outing.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (p, c) => c.feedbackOuting != null || c.staleOuting != null,
      listener: (context, state) {
        if (state.staleOuting != null) {
          _showStale(state);
        } else {
          _showFeedback(state);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.loading) return const LoadingView();
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.sm,
                  AppSpace.gutter,
                  AppSpace.xxl,
                ),
                children: [
                  _Header(onSettings: () => AppRoutes.openSettings(context)),
                  const SizedBox(height: AppSpace.lg),
                  if (state.active != null)
                    _ActiveCard(
                      state: state,
                      onContinue: () => _openOuting(state.active!.id),
                      onFinish: () => OutingFlow.open(
                        context,
                        state.active!.id,
                        finish: true,
                      ),
                    )
                  else
                    _IdleCard(onStart: _startOuting),
                  // Lock-screen taps that need the person: a discreet card,
                  // never a sheet that opens by itself.
                  const PendingCommandsNotice(),
                  if (state.lastOuting != null && state.active == null) ...[
                    SectionTitle(tr.homeLastOuting),
                    _LastOutingCard(
                      state: state,
                      onTap: () => _push<void>(
                        OutingSummaryPage(outingId: state.lastOuting!.id),
                      ),
                    ),
                  ],
                  SectionTitle(tr.homeThisMonth),
                  _MonthCard(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: AppSpace.xs),
          child: BrandWordmark(height: 30),
        ),
        const Spacer(),
        IconButton(
          tooltip: tr.settingsTitle,
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
        SyncBadge(onTap: onSettings),
      ],
    );
  }
}

class _IdleCard extends StatelessWidget {
  const _IdleCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      highlight: true,
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatWeekdayDate(DateTime.now()), style: AppText.caption),
          const SizedBox(height: AppSpace.sm),
          Text(tr.homeIdleTitle, style: AppText.headline),
          const SizedBox(height: AppSpace.sm),
          Text(tr.homeIdleBody, style: AppText.caption),
          const SizedBox(height: AppSpace.xl),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded, size: 26),
            label: Text(tr.homeStartOuting),
          ),
        ],
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({
    required this.state,
    required this.onContinue,
    required this.onFinish,
  });

  final HomeState state;
  final VoidCallback onContinue;

  /// Opens the outing straight into the finish confirmation.
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final outing = state.active!;
    final s = state.activeSummary!;
    return SurfaceCard(
      highlight: true,
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Text(tr.homeOutingRunning, style: AppText.caption),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Icon(outing.type.icon, color: AppColors.amber),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  outing.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.headline.copyWith(fontSize: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpace.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.homeTime, style: AppText.caption),
                      const SizedBox(height: AppSpace.xs),
                      // Long outings ("57 h 49 min") shrink instead of running
                      // into the next column.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ElapsedText(
                          since: outing.startedAt,
                          style: AppText.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: StatTile(label: tr.homeYourDrinks, value: '${s.entryCount}'),
              ),
              Expanded(
                child: StatTile(
                  label: tr.homeSpent,
                  value: formatCents(s.informedCents),
                ),
              ),
            ],
          ),
          if (s.unpricedCount > 0) ...[
            const SizedBox(height: AppSpace.md),
            InfoPill(
              tr.homeUnpriced(s.unpricedCount),
              icon: Icons.sell_outlined,
              warning: true,
            ),
          ],
          const SizedBox(height: AppSpace.xl),
          FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.sports_bar_rounded),
            label: Text(tr.homeContinueOuting),
          ),
          const SizedBox(height: AppSpace.sm),
          OutlinedButton.icon(
            onPressed: onFinish,
            icon: const Icon(Icons.flag_outlined),
            label: Text(tr.outingFinish),
          ),
        ],
      ),
    );
  }
}

class _LastOutingCard extends StatelessWidget {
  const _LastOutingCard({required this.state, required this.onTap});

  final HomeState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final o = state.lastOuting!;
    final s = state.lastSummary!;
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(o.type.icon, color: AppColors.amber),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    formatDate(o.startedAt),
                    tr.drinkCount(s.entryCount),
                    if (s.pricedCount > 0) formatCents(s.informedCents),
                  ].join(' · '),
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasHistory) {
      return SurfaceCard(
        child: EmptyView(
          icon: Icons.sports_bar_outlined,
          title: tr.homeFirstTitle,
          message: tr.homeFirstBody,
        ),
      );
    }
    if (state.monthOutings == 0) {
      return SurfaceCard(
        child: Text(tr.homeNoneThisMonth, style: AppText.caption),
      );
    }
    final unpriced = state.monthUnpriced;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: tr.homeOutings,
                  value: '${state.monthOutings}',
                ),
              ),
              Expanded(
                child: StatTile(
                  label: tr.homeYourDrinks,
                  value: '${state.monthDrinks}',
                ),
              ),
              Expanded(
                child: StatTile(
                  label: tr.homeInformedSpent,
                  value: formatCents(state.monthInformedCents),
                ),
              ),
            ],
          ),
          if (unpriced > 0) ...[
            const SizedBox(height: AppSpace.md),
            InfoPill(
              tr.financeUnpriced(unpriced),
              icon: Icons.sell_outlined,
              warning: true,
            ),
          ],
        ],
      ),
    );
  }
}

enum _StaleAction { keep, end }

/// "Esse rolê ainda está acontecendo?" Never ends the outing by itself.
class _StaleSheet extends StatelessWidget {
  const _StaleSheet({required this.outing});

  final Outing outing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.xl,
          0,
          AppSpace.xl,
          AppSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.staleTitle, style: AppText.title),
            const SizedBox(height: AppSpace.sm),
            Text(
              tr.staleBody(
                outing.displayName,
                formatDateTime(outing.startedAt),
                formatDuration(outing.durationAt(DateTime.now())),
              ),
              style: AppText.caption,
            ),
            const SizedBox(height: AppSpace.xl),
            FilledButton(
              onPressed: () => Navigator.pop(context, _StaleAction.keep),
              child: Text(tr.commonContinue),
            ),
            const SizedBox(height: AppSpace.sm),
            OutlinedButton(
              onPressed: () => Navigator.pop(context, _StaleAction.end),
              child: Text(tr.staleEndOtherTime),
            ),
            const SizedBox(height: AppSpace.xs),
            Text(tr.staleNote, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
