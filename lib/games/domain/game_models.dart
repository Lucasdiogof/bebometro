import 'dart:math';

import '../../l10n/l10n.dart';

enum GameType {
  neverHaveIEver('neverHaveIEver', 1),
  mostLikely('mostLikely', 2),
  truthOrDare('truthOrDare', 2);

  const GameType(this.code, this.minPlayers);

  /// Stored value (saved matches, cards); never translated.
  final String code;

  String get title => switch (this) {
    GameType.neverHaveIEver => tr.gameNeverTitle,
    GameType.mostLikely => tr.gameMostTitle,
    GameType.truthOrDare => tr.gameTruthTitle,
  };

  String get description => switch (this) {
    GameType.neverHaveIEver => tr.gameNeverDesc,
    GameType.mostLikely => tr.gameMostDesc,
    GameType.truthOrDare => tr.gameTruthDesc,
  };

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
  light('light'),
  adult('adult');

  const GameMode(this.code);

  final String code;

  String get label => switch (this) {
    GameMode.light => tr.gameModeLight,
    GameMode.adult => tr.gameModeAdult,
  };

  static GameMode? fromCode(String? code) {
    for (final m in GameMode.values) {
      if (m.code == code) return m;
    }
    return null;
  }
}

enum CardKind {
  statement('statement'),
  truth('truth'),
  dare('dare');

  const CardKind(this.code);

  final String code;

  String get label => switch (this) {
    CardKind.statement => tr.gameKindCard,
    CardKind.truth => tr.gameKindTruth,
    CardKind.dare => tr.gameKindDare,
  };

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
    required String text,
    this.translations = const {},
    this.optional = false,
    this.isCustom = false,
  }) : _text = text;

  /// Stable id ("ni-l-01"; custom cards are "custom:`<uuid>`").
  final String id;
  final GameType game;
  final GameMode mode;
  final CardKind kind;
  final String _text;

  /// Editorial translations of a bundled card, by language code. The card id
  /// and its meaning never change; a card of the user has none and always
  /// shows exactly what was written.
  final Map<String, String> translations;

  /// The card text in the language on screen (bundled cards) or as written
  /// (the user's own).
  String get text => isCustom ? _text : (translations[trLanguage] ?? _text);

  /// Shown as "pode pular sem punição" (all +18 cards are marked).
  final bool optional;
  final bool isCustom;

  Map<String, dynamic> toJson() => {
    'id': id,
    'game': game.code,
    'mode': mode.code,
    'kind': kind.code,
    'text': _text,
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
      translations: custom
          ? const {}
          : {
              for (final e in ((j['i18n'] as Map?) ?? const {}).entries)
                if (e.value is String && (e.value as String).trim().isNotEmpty)
                  e.key as String: e.value as String,
            },
      optional: j['optional'] as bool? ?? false,
      isCustom: custom,
    );
  }
}

/// The cards eligible for a game and mode. Leve = light cards; +18 = the
/// +18 cards mixed with the light ones.
List<GameCard> deckFor(List<GameCard> all, GameType game, GameMode mode) => [
  for (final c in all)
    if (c.game == game && (mode == GameMode.adult || c.mode == GameMode.light))
      c,
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
  }) => GameSession(
    game: game,
    mode: mode,
    players: players,
    usePoints: usePoints,
    startedAt: startedAt,
    usedIds: usedIds ?? this.usedIds,
    currentCardId: currentCardId != null ? currentCardId() : this.currentCardId,
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
      startedAt:
          DateTime.tryParse(j['started_at'] as String? ?? '') ?? DateTime.now(),
      usedIds: (j['used_ids'] as List?)?.cast<String>() ?? const [],
      currentCardId: j['current_card_id'] as String?,
      turn: (j['turn'] as num?)?.toInt() ?? 0,
      scores: ((j['scores'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k as String, (v as num).toInt()),
      ),
    );
  }
}
