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

/// A game in progress, kept on the device so it can be resumed. There is no
/// score: nothing here ranks people. Old saved matches that still carry
/// `use_points`/`scores` are read and those fields are ignored.
class GameSession {
  const GameSession({
    required this.game,
    required this.mode,
    required this.players,
    required this.startedAt,
    this.usedIds = const [],
    this.currentCardId,
    this.turn = 0,
    this.readerOverride,
  });

  final GameType game;
  final GameMode mode;

  /// Nicknames only; no accounts.
  final List<String> players;
  final DateTime startedAt;
  final List<String> usedIds;
  final String? currentCardId;

  /// Rotation counter: who is up (taken modulo the number of players).
  final int turn;

  /// Someone else reads this card ("Trocar leitor"); cleared on the next one.
  final int? readerOverride;

  int get _n => players.length;

  /// Truth or dare: the person who answers (chooses truth or dare).
  /// Never have I ever / who is most likely: everybody answers.
  int get responderIndex => turn % _n;

  String? get responder =>
      game == GameType.truthOrDare ? players[responderIndex] : null;

  /// Who reads the card aloud. In truth or dare it is never the person who
  /// answers (when there is someone else); otherwise it follows the rotation.
  int get readerIndex {
    final o = readerOverride;
    if (o != null && o >= 0 && o < _n) return o;
    if (game == GameType.truthOrDare && _n > 1) return (turn + 1) % _n;
    return turn % _n;
  }

  String get reader => players[readerIndex];

  GameSession copyWith({
    List<String>? usedIds,
    String? Function()? currentCardId,
    int? turn,
    int? Function()? readerOverride,
  }) => GameSession(
    game: game,
    mode: mode,
    players: players,
    startedAt: startedAt,
    usedIds: usedIds ?? this.usedIds,
    currentCardId: currentCardId != null ? currentCardId() : this.currentCardId,
    turn: turn ?? this.turn,
    readerOverride: readerOverride != null
        ? readerOverride()
        : this.readerOverride,
  );

  Map<String, dynamic> toJson() => {
    'game': game.code,
    'mode': mode.code,
    'players': players,
    'started_at': startedAt.toIso8601String(),
    'used_ids': usedIds,
    'current_card_id': currentCardId,
    'turn': turn,
    if (readerOverride != null) 'reader_override': readerOverride,
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
      startedAt:
          DateTime.tryParse(j['started_at'] as String? ?? '') ?? DateTime.now(),
      usedIds: (j['used_ids'] as List?)?.cast<String>() ?? const [],
      currentCardId: j['current_card_id'] as String?,
      turn: (j['turn'] as num?)?.toInt() ?? 0,
      readerOverride: (j['reader_override'] as num?)?.toInt(),
    );
  }
}
