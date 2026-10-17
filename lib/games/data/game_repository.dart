import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

import '../../core/data/local_store.dart';
import '../domain/game_models.dart';
import '../../l10n/l10n.dart';

/// Cards (bundled + the user's own) and the saved match. Everything is local:
/// games work offline, without an account and without an active outing.
class GameRepository {
  GameRepository(this._store, this._bundled) {
    _readCustom();
  }

  static const cardsAsset = 'assets/games/cards_v1.json';
  static const _customKey = 'games.custom_cards';
  static const _sessionKey = 'games.session';
  static const _uuid = Uuid();

  final LocalStore _store;
  final List<GameCard> _bundled;
  final _custom = <GameCard>[];
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  /// Reads the bundled cards; an unreadable file just means no bundled cards.
  static Future<List<GameCard>> loadBundled() async {
    try {
      final doc = jsonDecode(
        await rootBundle.loadString(cardsAsset),
      ) as Map<String, dynamic>;
      return [
        for (final j in (doc['cards'] as List))
          ?GameCard.fromJson(Map<String, dynamic>.from(j as Map)),
      ];
    } catch (e) {
      if (kDebugMode) debugPrint('[games] could not load $cardsAsset: $e');
      return const [];
    }
  }

  void _readCustom() {
    _custom.clear();
    final raw = _store.getString(_customKey);
    if (raw == null) return;
    try {
      for (final j in jsonDecode(raw) as List) {
        final card = GameCard.fromJson(
          Map<String, dynamic>.from(j as Map),
          custom: true,
        );
        if (card != null) _custom.add(card);
      }
    } catch (_) {
      // A damaged value starts the custom cards empty instead of crashing.
    }
  }

  List<GameCard> get allCards => [..._bundled, ..._custom];
  List<GameCard> get customCards => List.unmodifiable(_custom);

  Future<GameCard> addCustom({
    required GameType game,
    required GameMode mode,
    required CardKind kind,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw ArgumentError(tr.gameCardNeedText);
    if (trimmed.length > 240) throw ArgumentError(tr.gameCardTooLong);
    final card = GameCard(
      id: 'custom:${_uuid.v4()}',
      game: game,
      mode: mode,
      kind: game == GameType.truthOrDare
          ? (kind == CardKind.dare ? CardKind.dare : CardKind.truth)
          : CardKind.statement,
      text: trimmed,
      optional: mode == GameMode.adult,
      isCustom: true,
    );
    _custom.add(card);
    await _persistCustom();
    return card;
  }

  Future<void> deleteCustom(String id) async {
    _custom.removeWhere((c) => c.id == id);
    await _persistCustom();
  }

  Future<void> _persistCustom() async {
    await _store.setString(
      _customKey,
      jsonEncode([for (final c in _custom) c.toJson()]),
    );
    _changes.add(null);
  }

  List<String> get lastPlayers {
    final raw = _store.getString('games.last_players');
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveLastPlayers(List<String> names) =>
      _store.setString('games.last_players', jsonEncode(names));

  GameSession? get savedSession {
    final raw = _store.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return GameSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(GameSession s) async {
    await _store.setString(_sessionKey, jsonEncode(s.toJson()));
    _changes.add(null);
  }

  Future<void> clearSession() async {
    await _store.setString(_sessionKey, '');
    _changes.add(null);
  }
}
