import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../table/presentation/person_avatar.dart';
import '../../tab/domain/tab_models.dart';
import '../domain/game_models.dart';
import 'game_cubit.dart';
import '../../l10n/l10n.dart';

/// A match in progress. The match is saved after every action, so leaving the
/// screen keeps it for later ("Retomar" in Resenha).
class GamePlayPage extends StatelessWidget {
  const GamePlayPage.start({
    super.key,
    required GameType this.game,
    required GameMode this.mode,
    required List<String> this.players,
  });

  const GamePlayPage.resume({super.key})
    : game = null,
      mode = null,
      players = null;

  final GameType? game;
  final GameMode? mode;
  final List<String>? players;

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
        title: Text(tr.gameFinishTitle),
        content: Text(tr.gameFinishBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.gameKeepPlaying),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.gameFinish),
          ),
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
                child: Text(tr.gameFinish),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.gutter,
                ),
                child: Row(
                  children: [
                    InfoPill(
                      tr.gameModePill(session.mode.label),
                      icon: Icons.tune_rounded,
                    ),
                    const SizedBox(width: AppSpace.sm),
                    InfoPill(
                      tr.gameCardsLeft(left),
                      icon: Icons.style_outlined,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.gutter),
                  child: _Stage(state: state),
                ),
              ),
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
          Text(tr.gameOutOfCards, style: AppText.title),
          const SizedBox(height: AppSpace.sm),
          Text(
            tr.gameOutOfCardsHint,
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.lg),
          FilledButton(
            onPressed: cubit.reshuffle,
            child: Text(tr.gameReshuffle),
          ),
        ],
      );
    } else if (state.awaitingChoice) {
      child = _Panel(
        key: ValueKey('choice-${session.turn}'),
        children: [
          _ReaderBanner(session: session),
          const SizedBox(height: AppSpace.lg),
          Text(tr.gameTurnOf(session.responder!), style: AppText.title),
          const SizedBox(height: AppSpace.sm),
          Text(tr.gameTruthOrDareQ, style: AppText.subtitle),
          if (state.noticeKind != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              state.noticeKind == CardKind.truth
                  ? tr.gameNoTruthLeft
                  : tr.gameNoDareLeft,
              style: AppText.caption,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpace.xl),
          FilledButton(
            onPressed: () => cubit.choose(CardKind.truth),
            child: Text(CardKind.truth.label),
          ),
          const SizedBox(height: AppSpace.sm),
          OutlinedButton(
            onPressed: () => cubit.choose(CardKind.dare),
            child: Text(CardKind.dare.label),
          ),
        ],
      );
    } else {
      final card = state.card!;
      child = _Panel(
        key: ValueKey(card.id),
        children: [
          _ReaderBanner(session: session),
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.md, bottom: AppSpace.lg),
            child: Text(
              session.game == GameType.truthOrDare
                  ? '${tr.gameResponder(session.responder!)} · ${card.kind.label}'
                  : tr.gameEveryoneAnswers,
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(color: AppColors.amber),
            ),
          ),
          Text(
            card.text,
            textAlign: TextAlign.center,
            style: AppText.headline.copyWith(fontSize: 24, height: 1.25),
          ),
          if (card.optional || card.mode == GameMode.adult) ...[
            const SizedBox(height: AppSpace.lg),
            Text(
              tr.gameOptional,
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

/// "Ana, leia a pergunta": the reader, big, with initial + words (never only
/// color). The reader is not the one who answers in truth or dare.
class _ReaderBanner extends StatelessWidget {
  const _ReaderBanner({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final name = session.reader;
    return Semantics(
      container: true,
      label: tr.gameReaderCall(name),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: PersonAvatar(
              person: Participant(id: 'game:$name', name: name),
              index: session.readerIndex,
              size: 48,
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.gameReaderLabel,
                  style: AppText.overline.copyWith(color: AppColors.amber),
                ),
                Text(
                  tr.gameReaderCall(name),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title,
                ),
              ],
            ),
          ),
        ],
      ),
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

class _Controls extends StatelessWidget {
  const _Controls({required this.state});

  final GameState state;

  Future<void> _pickReader(BuildContext context) async {
    final cubit = context.read<GameCubit>();
    final session = state.session!;
    final index = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
              child: Text(tr.gameChooseReader, style: AppText.title),
            ),
            for (var i = 0; i < session.players.length; i++)
              ListTile(
                leading: PersonAvatar(
                  person: Participant(
                    id: 'game:${session.players[i]}',
                    name: session.players[i],
                  ),
                  index: i,
                ),
                title: Text(session.players[i]),
                trailing: i == session.readerIndex
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    );
    if (index != null) cubit.changeReader(index);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final session = state.session!;
    final showCardControls =
        state.card != null && !state.exhausted && !state.awaitingChoice;
    final canPass = !state.exhausted && session.players.length > 1;
    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCardControls)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: cubit.skip,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: Text(tr.gameSkip),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: cubit.next,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(tr.gameNext),
                  ),
                ),
              ],
            ),
          if (canPass)
            Padding(
              padding: EdgeInsets.only(top: showCardControls ? AppSpace.xs : 0),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: cubit.passTurn,
                    child: Text(tr.gamePassTurn),
                  ),
                  if (showCardControls)
                    TextButton(
                      onPressed: () => _pickReader(context),
                      child: Text(tr.gameChangeReader),
                    ),
                ],
              ),
            ),
          if (!showCardControls && !canPass)
            Text(
              tr.gameSavedNote(tr.navGames),
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
        ],
      ),
    );
  }
}
