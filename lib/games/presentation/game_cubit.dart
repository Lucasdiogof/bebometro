import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/game_repository.dart';
import '../domain/game_models.dart';

class GameState {
  const GameState({
    this.session,
    this.card,
    this.exhausted = false,
    this.finished = false,
    this.noticeKind,
  });

  final GameSession? session;

  /// The card on screen. In Verdade ou desafio it is null while the player
  /// chooses between truth and dare.
  final GameCard? card;

  /// Every eligible card was used.
  final bool exhausted;
  final bool finished;

  /// One-off notice (no cards of this kind left); shown once.
  final CardKind? noticeKind;

  bool get awaitingChoice =>
      session != null &&
      session!.game == GameType.truthOrDare &&
      card == null &&
      !exhausted &&
      !finished;

}

class GameCubit extends Cubit<GameState> {
  GameCubit(this._repo) : super(const GameState());

  final GameRepository _repo;
  final _rng = Random();

  List<GameCard> _deck(GameSession s) =>
      deckFor(_repo.allCards, s.game, s.mode);

  /// Number of cards not used yet in the current deck.
  int cardsLeftFor(GameSession s) =>
      _deck(s).where((c) => !s.usedIds.contains(c.id)).length;

  /// Starts a new match with the given settings (replaces a saved one).
  Future<void> begin({
    required GameType game,
    required GameMode mode,
    required List<String> players,
    required bool usePoints,
  }) async {
    final session = GameSession(
      game: game,
      mode: mode,
      players: players,
      usePoints: usePoints,
      startedAt: DateTime.now(),
      scores: {for (final p in players) p: 0},
    );
    await _enter(session);
  }

  /// Continues the match saved on this device, if any.
  Future<void> resume() async {
    final saved = _repo.savedSession;
    if (saved == null) {
      emit(const GameState(finished: true));
      return;
    }
    GameCard? card;
    for (final c in _repo.allCards) {
      if (c.id == saved.currentCardId) card = c;
    }
    if (card == null && saved.game != GameType.truthOrDare) {
      await _enter(saved);
      return;
    }
    emit(GameState(session: saved, card: card));
  }

  Future<void> _enter(GameSession session) async {
    await _repo.saveSession(session);
    if (session.game == GameType.truthOrDare) {
      emit(GameState(session: session));
    } else {
      _draw(session, null);
    }
  }

  void _draw(GameSession s, CardKind? kind) {
    final card = drawCard(_deck(s), s.usedIds.toSet(), _rng, kind: kind);
    if (card == null) {
      final nothingAtAll = drawCard(_deck(s), s.usedIds.toSet(), _rng) == null;
      emit(GameState(
        session: s,
        exhausted: nothingAtAll,
        noticeKind: nothingAtAll ? null : kind,
      ));
      return;
    }
    final next = s.copyWith(
      usedIds: [...s.usedIds, card.id],
      currentCardId: () => card.id,
    );
    _repo.saveSession(next);
    emit(GameState(session: next, card: card));
  }

  /// Verdade ou desafio: the player's choice.
  void choose(CardKind kind) {
    final s = state.session;
    if (s == null) return;
    _draw(s, kind);
  }

  /// Moves on to the next card (and next player's turn).
  void next() {
    final s = state.session;
    if (s == null) return;
    final advanced = s.copyWith(turn: s.turn + 1, currentCardId: () => null);
    _repo.saveSession(advanced);
    if (s.game == GameType.truthOrDare) {
      emit(GameState(session: advanced));
    } else {
      _draw(advanced, null);
    }
  }

  /// Skips the card without any penalty: same player, another card.
  void skip() {
    final s = state.session;
    final card = state.card;
    if (s == null) return;
    final cleared = s.copyWith(currentCardId: () => null);
    _repo.saveSession(cleared);
    _draw(cleared, card?.kind == CardKind.statement ? null : card?.kind);
  }

  void addPoint(String player) {
    final s = state.session;
    if (s == null || !s.usePoints) return;
    final scores = {...s.scores, player: (s.scores[player] ?? 0) + 1};
    final next = s.copyWith(scores: scores);
    _repo.saveSession(next);
    emit(GameState(session: next, card: state.card));
  }

  void removePoint(String player) {
    final s = state.session;
    if (s == null || !s.usePoints) return;
    final current = s.scores[player] ?? 0;
    if (current <= 0) return;
    final next = s.copyWith(scores: {...s.scores, player: current - 1});
    _repo.saveSession(next);
    emit(GameState(session: next, card: state.card));
  }

  /// Puts every card back in the deck and keeps playing.
  void reshuffle() {
    final s = state.session;
    if (s == null) return;
    final fresh = s.copyWith(usedIds: const [], currentCardId: () => null);
    _repo.saveSession(fresh);
    if (s.game == GameType.truthOrDare) {
      emit(GameState(session: fresh));
    } else {
      _draw(fresh, null);
    }
  }

  /// Ends the match and forgets it.
  Future<void> finish() async {
    await _repo.clearSession();
    emit(const GameState(finished: true));
  }
}
