import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../domain/game_models.dart';
import 'game_cubit.dart';

/// A match in progress. The match is saved after every action, so leaving the
/// screen keeps it for later ("Retomar" in Resenha).
class GamePlayPage extends StatelessWidget {
  const GamePlayPage.start({
    super.key,
    required GameType this.game,
    required GameMode this.mode,
    required List<String> this.players,
    required bool this.usePoints,
  });

  const GamePlayPage.resume({super.key})
      : game = null,
        mode = null,
        players = null,
        usePoints = null;

  final GameType? game;
  final GameMode? mode;
  final List<String>? players;
  final bool? usePoints;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<GameCubit>();
        if (game == null) {
          cubit.resume();
        } else {
          cubit.begin(
            game: game!,
            mode: mode!,
            players: players!,
            usePoints: usePoints!,
          );
        }
        return cubit;
      },
      child: const _PlayView(),
    );
  }
}

class _PlayView extends StatelessWidget {
  const _PlayView();

  Future<void> _confirmFinish(BuildContext context) async {
    final cubit = context.read<GameCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar a partida?'),
        content: const Text(
            'Ela não ficará salva. Para só dar uma pausa, volte e retome depois.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continuar jogando')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Encerrar')),
        ],
      ),
    );
    if (ok == true) await cubit.finish();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    return BlocConsumer<GameCubit, GameState>(
      listenWhen: (p, c) => c.finished && !p.finished,
      listener: (context, state) => Navigator.of(context).pop(),
      builder: (context, state) {
        final session = state.session;
        if (session == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.amber),
            ),
          );
        }
        final left = cubit.cardsLeftFor(session);
        return Scaffold(
          appBar: AppBar(
            title: Text(session.game.title),
            actions: [
              TextButton(
                onPressed: () => _confirmFinish(context),
                child: const Text('Encerrar'),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: Row(children: [
                  InfoPill('Modo ${session.mode.label}', icon: Icons.tune_rounded),
                  const SizedBox(width: AppSpace.sm),
                  InfoPill('$left cartas restantes', icon: Icons.style_outlined),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.gutter),
                  child: _Stage(state: state),
                ),
              ),
              if (session.usePoints) _Scoreboard(session: session),
              _Controls(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final session = state.session!;
    final quick = reduceMotion(context);

    Widget child;
    if (state.exhausted) {
      child = _Panel(
        key: const ValueKey('exhausted'),
        children: [
          const Icon(Icons.style_rounded, size: 40, color: AppColors.amber),
          const SizedBox(height: AppSpace.md),
          const Text('Acabaram as cartas', style: AppText.title),
          const SizedBox(height: AppSpace.sm),
          const Text(
            'Dá para embaralhar tudo de novo ou encerrar a partida.',
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.lg),
          FilledButton(
            onPressed: cubit.reshuffle,
            child: const Text('Embaralhar de novo'),
          ),
        ],
      );
    } else if (state.awaitingChoice) {
      child = _Panel(
        key: ValueKey('choice-${session.turn}'),
        children: [
          Text('Vez de ${session.currentPlayer}', style: AppText.title),
          const SizedBox(height: AppSpace.sm),
          const Text('Verdade ou desafio?', style: AppText.subtitle),
          if (state.notice != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(state.notice!, style: AppText.caption, textAlign: TextAlign.center),
          ],
          const SizedBox(height: AppSpace.xl),
          FilledButton(
            onPressed: () => cubit.choose(CardKind.truth),
            child: const Text('Verdade'),
          ),
          const SizedBox(height: AppSpace.sm),
          OutlinedButton(
            onPressed: () => cubit.choose(CardKind.dare),
            child: const Text('Desafio'),
          ),
        ],
      );
    } else {
      final card = state.card!;
      child = _Panel(
        key: ValueKey(card.id),
        children: [
          if (session.game == GameType.truthOrDare)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: Text(
                '${session.currentPlayer} · ${card.kind.label}',
                style: AppText.caption.copyWith(color: AppColors.amber),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: Text('Quem lê: ${session.currentPlayer}',
                  style: AppText.caption),
            ),
          Text(
            card.text,
            textAlign: TextAlign.center,
            style: AppText.headline.copyWith(fontSize: 24, height: 1.25),
          ),
          if (card.optional || card.mode == GameMode.adult) ...[
            const SizedBox(height: AppSpace.lg),
            const Text(
              'Opcional: pode pular sem punição.',
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
          ],
        ],
      );
    }

    return AnimatedSwitcher(
      duration: quick ? Duration.zero : const Duration(milliseconds: 260),
      transitionBuilder: (w, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(anim),
          child: w,
        ),
      ),
      child: child,
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SurfaceCard(
        highlight: true,
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in children)
                  if (c is Text || c is Padding || c is InfoPill)
                    Align(alignment: Alignment.center, child: c)
                  else
                    c,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.gutter, 0, AppSpace.gutter, AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Toque no nome para somar 1 ponto', style: AppText.caption),
          const SizedBox(height: AppSpace.xs),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final p in session.players)
                ActionChip(
                  label: Text('$p · ${session.scores[p] ?? 0}'),
                  onPressed: () {
                    cubit.addPoint(p);
                    final messenger = ScaffoldMessenger.of(context);
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text('+1 para $p'),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'Desfazer',
                          onPressed: () => cubit.removePoint(p),
                        ),
                      ));
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final showCardControls =
        state.card != null && !state.exhausted && !state.awaitingChoice;
    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCardControls)
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: cubit.skip,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Pular'),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: cubit.next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Próxima'),
                ),
              ),
            ])
          else
            const Text(
              'A partida fica salva: você pode sair e retomar na Resenha.',
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
        ],
      ),
    );
  }
}
