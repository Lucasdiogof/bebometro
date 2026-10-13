import 'dart:math';

enum GameType {
  neverHaveIEver('neverHaveIEver', 'Eu nunca', 'Quem já fez, conta. Sem pressão.', 1),
  mostLikely('mostLikely', 'Quem é mais provável', 'A turma aponta quem combina mais com a frase.', 2),
  truthOrDare('truthOrDare', 'Verdade ou desafio', 'Cada um na sua vez, com opção de pular.', 2);

  const GameType(this.code, this.title, this.description, this.minPlayers);

  final String code;
  final String title;
  final String description;

  /// Fewest participants needed to start.
  final int minPlayers;

  static GameType? fromCode(String? code) {
    for (final g in GameType.values) {
      if (g.code == code) return g;
    }
    return null;
  }
}

/// Light has no sexual content. +18 adds flirting and humour for adults, with
/// optional challenges; it never asks for explicit content.
enum GameMode {
  light('light', 'Leve'),
  adult('adult', '+18');

  const GameMode(this.code, this.label);

  final String code;
  final String label;

  static GameMode? fromCode(String? code) {
    for (final m in GameMode.values) {
      if (m.code == code) return m;
    }
    return null;
  }
}

enum CardKind {
  statement('statement', 'Carta'),
  truth('truth', 'Verdade'),
  dare('dare', 'Desafio');

  const CardKind(this.code, this.label);

  final String code;
  final String label;

  static CardKind fromCode(String? code) => CardKind.values.firstWhere(
        (k) => k.code == code,
        orElse: () => CardKind.statement,
      );
}

class GameCard {
  const GameCard({
    required this.id,
    required this.game,
    required this.mode,
    required this.kind,
    required this.text,
    this.optional = false,
    this.isCustom = false,
  });

  /// Stable id ("ni-l-01"; custom cards are "custom:`<uuid>`").
  final String id;
  final GameType game;
  final GameMode mode;
  final CardKind kind;
  final String text;

  /// Shown as "pode pular sem punição" (all +18 cards are marked).
  final bool optional;
  final bool isCustom;

  Map<String, dynamic> toJson() => {
        'id': id,
        'game': game.code,
        'mode': mode.code,
        'kind': kind.code,
        'text': text,
        'optional': optional,
      };

  static GameCard? fromJson(Map<String, dynamic> j, {bool custom = false}) {
    final game = GameType.fromCode(j['game'] as String?);
    final mode = GameMode.fromCode(j['mode'] as String?);
    final text = j['text'] as String?;
    if (game == null || mode == null || text == null || text.trim().isEmpty) {
      return null;
    }
    return GameCard(
      id: j['id'] as String,
      game: game,
      mode: mode,
      kind: CardKind.fromCode(j['kind'] as String?),
      text: text,
      optional: j['optional'] as bool? ?? false,
      isCustom: custom,
    );
  }
}

/// The cards eligible for a game and mode. Leve = light cards; +18 = the
/// +18 cards mixed with the light ones.
List<GameCard> deckFor(List<GameCard> all, GameType game, GameMode mode) => [
      for (final c in all)
        if (c.game == game && (mode == GameMode.adult || c.mode == GameMode.light)) c,
    ];

/// Picks a card that was not used yet (never repeats until the set runs out).
/// Returns null when every eligible card was used.
GameCard? drawCard(
  List<GameCard> deck,
  Set<String> used,
  Random rng, {
  CardKind? kind,
}) {
  final pool = [
    for (final c in deck)
      if (!used.contains(c.id) && (kind == null || c.kind == kind)) c,
  ];
  if (pool.isEmpty) return null;
  return pool[rng.nextInt(pool.length)];
}

/// A game in progress, kept on the device so it can be resumed.
class GameSession {
  const GameSession({
    required this.game,
    required this.mode,
    required this.players,
    required this.usePoints,
    required this.startedAt,
    this.usedIds = const [],
    this.currentCardId,
    this.turn = 0,
    this.scores = const {},
  });

  final GameType game;
  final GameMode mode;

  /// Nicknames only; no accounts.
  final List<String> players;
  final bool usePoints;
  final DateTime startedAt;
  final List<String> usedIds;
  final String? currentCardId;

  /// Index of whose turn it is (taken modulo the number of players).
  final int turn;
  final Map<String, int> scores;

  String get currentPlayer => players[turn % players.length];

  GameSession copyWith({
    List<String>? usedIds,
    String? Function()? currentCardId,
    int? turn,
    Map<String, int>? scores,
  }) =>
      GameSession(
        game: game,
        mode: mode,
        players: players,
        usePoints: usePoints,
        startedAt: startedAt,
        usedIds: usedIds ?? this.usedIds,
        currentCardId:
            currentCardId != null ? currentCardId() : this.currentCardId,
        turn: turn ?? this.turn,
        scores: scores ?? this.scores,
      );

  Map<String, dynamic> toJson() => {
        'game': game.code,
        'mode': mode.code,
        'players': players,
        'use_points': usePoints,
        'started_at': startedAt.toIso8601String(),
        'used_ids': usedIds,
        'current_card_id': currentCardId,
        'turn': turn,
        'scores': scores,
      };

  static GameSession? fromJson(Map<String, dynamic> j) {
    final game = GameType.fromCode(j['game'] as String?);
    final mode = GameMode.fromCode(j['mode'] as String?);
    final players = (j['players'] as List?)?.cast<String>() ?? const <String>[];
    if (game == null || mode == null || players.isEmpty) return null;
    return GameSession(
      game: game,
      mode: mode,
      players: players,
      usePoints: j['use_points'] as bool? ?? false,
      startedAt: DateTime.tryParse(j['started_at'] as String? ?? '') ??
          DateTime.now(),
      usedIds: (j['used_ids'] as List?)?.cast<String>() ?? const [],
      currentCardId: j['current_card_id'] as String?,
      turn: (j['turn'] as num?)?.toInt() ?? 0,
      scores: ((j['scores'] as Map?) ?? const {})
          .map((k, v) => MapEntry(k as String, (v as num).toInt())),
    );
  }
}
