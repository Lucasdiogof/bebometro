import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/beer_glass.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../history/presentation/history_page.dart';
import '../../outings/presentation/outing_page.dart';
import '../../outings/presentation/outing_summary_page.dart';
import '../../outings/presentation/start_outing_page.dart';
import '../../settings/presentation/settings_page.dart';
import 'feedback_sheet.dart';
import 'home_cubit.dart';

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
    // Once per app opening: the feedback sheet for a finished outing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeCubit>().checkFeedback();
    });
  }

  Future<T?> _push<T>(Widget page) =>
      Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

  Future<void> _openOuting(String id) async {
    final finishedId = await _push<String>(OutingPage(outingId: id));
    if (finishedId != null && mounted) {
      // The feedback prompt is deliberately not shown after the summary; it
      // waits for the next time the app is opened.
      await _push<void>(OutingSummaryPage(outingId: finishedId));
    }
  }

  Future<void> _startOuting() async {
    final id = await _push<String>(const StartOutingPage());
    if (id != null && mounted) await _openOuting(id);
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
      listenWhen: (p, c) => c.feedbackOuting != null,
      listener: (context, state) => _showFeedback(state),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.loading) return const LoadingView();
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter, AppSpace.sm, AppSpace.gutter, AppSpace.xxl),
                children: [
                  _Header(
                    onHistory: () => _push<void>(const HistoryPage()),
                    onSettings: () => _push<void>(const SettingsPage()),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  if (state.active != null)
                    _ActiveCard(
                      state: state,
                      onContinue: () => _openOuting(state.active!.id),
                    )
                  else
                    _IdleCard(onStart: _startOuting),
                  if (state.lastOuting != null && state.active == null) ...[
                    const SectionTitle('Último rolê'),
                    _LastOutingCard(
                      state: state,
                      onTap: () => _push<void>(
                        OutingSummaryPage(outingId: state.lastOuting!.id),
                      ),
                    ),
                  ],
                  const SectionTitle('Este mês'),
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
  const _Header({required this.onHistory, required this.onSettings});

  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const BeerGlass(size: 40, fill: 0.85),
      const SizedBox(width: AppSpace.sm),
      const Expanded(
        child: Text('Bebômetro', style: AppText.title),
      ),
      IconButton(
        tooltip: 'Histórico',
        onPressed: onHistory,
        icon: const Icon(Icons.history_rounded),
      ),
      IconButton(
        tooltip: 'Configurações',
        onPressed: onSettings,
        icon: const Icon(Icons.settings_outlined),
      ),
      SyncBadge(onTap: onSettings),
    ]);
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
          const Text('Bora de rolê?', style: AppText.headline),
          const SizedBox(height: AppSpace.sm),
          const Text(
            'Anote o que bebeu e quanto gastou, sem complicação.',
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.xl),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded, size: 26),
            label: const Text('Iniciar rolê'),
          ),
        ],
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.state, required this.onContinue});

  final HomeState state;
  final VoidCallback onContinue;

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
          Row(children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.success, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpace.sm),
            const Text('Rolê em andamento', style: AppText.caption),
          ]),
          const SizedBox(height: AppSpace.sm),
          Row(children: [
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
          ]),
          const SizedBox(height: AppSpace.lg),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tempo', style: AppText.caption),
                  const SizedBox(height: AppSpace.xs),
                  ElapsedText(since: outing.startedAt, style: AppText.value),
                ],
              ),
            ),
            Expanded(
              child: StatTile(label: 'Bebidas', value: '${s.entryCount}'),
            ),
            Expanded(
              child: StatTile(
                label: 'Gasto',
                value: formatCents(s.informedCents),
              ),
            ),
          ]),
          if (s.unpricedCount > 0) ...[
            const SizedBox(height: AppSpace.md),
            InfoPill(
              '${s.unpricedCount} sem preço',
              icon: Icons.sell_outlined,
              warning: true,
            ),
          ],
          const SizedBox(height: AppSpace.xl),
          FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.sports_bar_rounded),
            label: const Text('Continuar rolê'),
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
      child: Row(children: [
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
              Text(o.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
              const SizedBox(height: 2),
              Text(
                '${formatDate(o.startedAt)} · '
                '${s.entryCount} ${s.entryCount == 1 ? 'bebida' : 'bebidas'}'
                '${s.pricedCount > 0 ? ' · ${formatCents(s.informedCents)}' : ''}',
                style: AppText.caption,
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      ]),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasHistory) {
      return const SurfaceCard(
        child: EmptyView(
          icon: Icons.sports_bar_outlined,
          title: 'Seu primeiro rolê começa aqui',
          message: 'Quando você encerrar um rolê, o resumo do mês aparece '
              'aqui, só com o que você registrou.',
        ),
      );
    }
    if (state.monthOutings == 0) {
      return const SurfaceCard(
        child: Text('Nenhum rolê encerrado neste mês ainda.',
            style: AppText.caption),
      );
    }
    final unpriced = state.monthUnpriced;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child:
                  StatTile(label: 'Rolês', value: '${state.monthOutings}'),
            ),
            Expanded(
              child:
                  StatTile(label: 'Bebidas', value: '${state.monthDrinks}'),
            ),
            Expanded(
              child: StatTile(
                label: 'Gasto informado',
                value: formatCents(state.monthInformedCents),
              ),
            ),
          ]),
          if (unpriced > 0) ...[
            const SizedBox(height: AppSpace.md),
            InfoPill(
              '$unpriced ${unpriced == 1 ? 'bebida' : 'bebidas'} sem preço',
              icon: Icons.sell_outlined,
              warning: true,
            ),
          ],
        ],
      ),
    );
  }
}
