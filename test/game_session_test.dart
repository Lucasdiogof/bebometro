import 'package:bebometro/games/domain/game_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GameSession session(GameType g, {int turn = 0, int? override}) => GameSession(
        game: g,
        mode: GameMode.light,
        players: const ['Ana', 'Bia', 'Caio'],
        startedAt: DateTime(2026, 10, 19),
        turn: turn,
        readerOverride: override,
      );

  test('an old saved match with points still opens and the score is dropped', () {
    final s = GameSession.fromJson({
      'game': 'mostLikely',
      'mode': 'light',
      'players': ['Ana', 'Bia'],
      'use_points': true,
      'scores': {'Ana': 3, 'Bia': 1},
      'started_at': '2026-10-01T20:00:00.000',
      'used_ids': ['ml-l-01'],
      'current_card_id': 'ml-l-01',
      'turn': 3,
    })!;
    expect(s.players, ['Ana', 'Bia']);
    expect(s.usedIds, ['ml-l-01']);
    expect(s.currentCardId, 'ml-l-01');
    expect(s.turn, 3);
    expect(s.reader, 'Bia');
    final json = s.toJson();
    expect(json.containsKey('scores'), isFalse);
    expect(json.containsKey('use_points'), isFalse);
  });

  test('never / most likely: the reader rotates, everybody answers', () {
    expect(session(GameType.mostLikely).reader, 'Ana');
    expect(session(GameType.mostLikely, turn: 1).reader, 'Bia');
    expect(session(GameType.mostLikely, turn: 4).reader, 'Bia');
    expect(session(GameType.mostLikely).responder, isNull);
  });

  test('truth or dare: the reader is never the person who answers', () {
    for (var t = 0; t < 7; t++) {
      final s = session(GameType.truthOrDare, turn: t);
      expect(s.reader, isNot(s.responder));
    }
  });

  test('changing the reader survives save and load, and the next card clears it', () {
    final s = session(GameType.mostLikely, override: 2);
    expect(s.reader, 'Caio');
    final back = GameSession.fromJson(s.toJson())!;
    expect(back.reader, 'Caio');
    final next = s.copyWith(turn: 1, readerOverride: () => null);
    expect(next.reader, 'Bia');
  });

  test('an out-of-range reader override falls back to the rotation', () {
    expect(session(GameType.neverHaveIEver, override: 9).reader, 'Ana');
  });
}
