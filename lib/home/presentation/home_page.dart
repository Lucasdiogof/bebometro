import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/beer_glass.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../history/presentation/history_page.dart';
import '../../outings/domain/outing.dart';
import '../../outings/presentation/outing_page.dart';
import '../../outings/presentation/outing_summary_page.dart';
import '../../outings/presentation/start_outing_page.dart';
import '../../settings/presentation/settings_page.dart';
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

  Future<void> _showFeedback(Outing outing) async {
    final cubit = context.read<HomeCubit>();
    final result = await showModalBottomSheet<_FeedbackResult>(
      context: context,
      builder: (_) => _FeedbackSheet(outing: outing),
    );
    switch (result) {
      case _Answered(:final mood):
        await cubit.answerFeedback(outing.id, mood);
      case _Dismissed():
        await cubit.dismissFeedback(outing.id);
      case _Snoozed():
      case null:
        // Swiping the sheet away counts as "later" so it is not shown again
        // on every visit to the home screen.
        await cubit.snoozeFeedback(outing.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (p, c) => c.feedbackOuting != null,
      listener: (context, state) => _showFeedback(state.feedbackOuting!),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.loading) return const LoadingView();
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Row(children: [
                    const BeerGlass(size: 44, fill: 0.85),
                    const SizedBox(width: 10),
                    const Text('Bebômetro',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3)),
                    const Spacer(),
                    SyncBadge(
                      onTap: () => _push<void>(const SettingsPage()),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  if (state.active != null)
                    _ActiveCard(
                      state: state,
                      onContinue: () => _openOuting(state.active!.id),
                    )
                  else
                    _IdleCard(onStart: _startOuting),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _push<void>(const HistoryPage()),
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('Histórico de rolês'),
                  ),
                  const SectionTitle('SEUS REGISTROS'),
                  _TotalsCard(state: state),
                ],
              );
            },
          ),
        ),
      ),
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
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatWeekdayDate(DateTime.now()),
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bora para o rolê?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Registre o que você bebeu e quanto gastou, sem complicação.',
            style: TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
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
      padding: const EdgeInsets.all(20),
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
            const SizedBox(width: 8),
            const Text('Rolê em andamento',
                style: TextStyle(color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(outing.type.icon, color: AppColors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(outing.displayName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900)),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tempo',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 4),
                  ElapsedText(
                    since: outing.startedAt,
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StatTile(label: 'Registros', value: '${s.entryCount}'),
            ),
            Expanded(
              child: StatTile(
                  label: 'Seu volume', value: formatMl(s.personalMl)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(
            s.financeLine,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 18),
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

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasHistory) {
      return const SurfaceCard(
        child: EmptyView(
          icon: Icons.sports_bar_outlined,
          title: 'Nada por aqui ainda',
          message: 'Seus rolês encerrados e gastos aparecem aqui. '
              'Nada é preenchido por você, só o que você registrar.',
        ),
      );
    }
    final unpriced = state.pastUnpriced;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: StatTile(label: 'Rolês', value: '${state.pastOutings}'),
            ),
            Expanded(
              child: StatTile(label: 'Bebidas', value: '${state.pastDrinks}'),
            ),
            Expanded(
              child: StatTile(
                  label: 'Seu volume', value: formatMl(state.pastPersonalMl)),
            ),
          ]),
          const SizedBox(height: 14),
          Text(
            '${formatCents(state.pastInformedCents)} informados'
            '${unpriced > 0 ? ' · $unpriced ${unpriced == 1 ? 'bebida sem preço' : 'bebidas sem preço'}' : ''}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

sealed class _FeedbackResult {
  const _FeedbackResult();
}

class _Answered extends _FeedbackResult {
  const _Answered(this.mood);

  final FeedbackMood mood;
}

class _Snoozed extends _FeedbackResult {
  const _Snoozed();
}

class _Dismissed extends _FeedbackResult {
  const _Dismissed();
}

class _FeedbackSheet extends StatelessWidget {
  const _FeedbackSheet({required this.outing});

  final Outing outing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Como foi o último rolê?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            '${outing.displayName} · ${formatDate(outing.startedAt)}. '
            'É só o seu relato, não uma medição.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              for (final mood in FeedbackMood.values)
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, _Answered(mood)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(mood.label),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context, const _Snoozed()),
                child: const Text('Depois'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context, const _Dismissed()),
                child: const Text('Não perguntar',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
