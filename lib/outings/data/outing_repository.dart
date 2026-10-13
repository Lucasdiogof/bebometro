import 'package:uuid/uuid.dart';

import '../../core/data/local_store.dart';
import '../../places/domain/place_draft.dart';
import '../domain/outing.dart';

class ActiveOutingExistsException implements Exception {
  const ActiveOutingExistsException();

  @override
  String toString() => 'Já existe um rolê em andamento.';
}

class OutingRepository {
  OutingRepository(this._store);

  final LocalStore _store;
  static const _uuid = Uuid();

  Stream<void> get changes =>
      _store.changes.where((c) => c == LocalStore.outings);

  List<Outing> _all() =>
      _store.all(LocalStore.outings).map(Outing.fromJson).toList();

  /// The single running outing, restored from disk after a restart.
  Outing? get active {
    final running = _all().where((o) => o.isActive).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return running.isEmpty ? null : running.first;
  }

  int count() => _store.count(LocalStore.outings);

  Outing? byId(String id) {
    final json = _store.get(LocalStore.outings, id);
    return json == null ? null : Outing.fromJson(json);
  }

  /// Outings (running or finished) linked to a saved place, newest first.
  List<Outing> forPlace(String placeId) =>
      _all().where((o) => o.placeId == placeId).toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  /// Every outing, newest first.
  List<Outing> all() => _all()..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  /// Finished outings, newest first.
  List<Outing> ended() => _all().where((o) => !o.isActive).toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  /// The most recent finished outing still waiting for the post-outing
  /// feedback (pending, or snoozed and past its snooze time).
  Outing? pendingFeedback(DateTime now) {
    for (final outing in ended()) {
      if (outing.isFeedbackEligible(now)) return outing;
    }
    return null;
  }

  static String? _clean(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();

  static void _checkPlace(PlaceSnapshot p) {
    if (_clean(p.nickname) == null &&
        _clean(p.address) == null &&
        _clean(p.placeName) == null &&
        p.point == null) {
      throw ArgumentError('Informe um apelido ou um endereço para o local.');
    }
  }

  Future<Outing> start({
    required OutingType type,
    required PlaceSnapshot place,
    int? budgetCents,
    required DateTime startedAt,
  }) async {
    if (active != null) throw const ActiveOutingExistsException();
    _checkPlace(place);
    final now = DateTime.now();
    final outing = Outing(
      id: _uuid.v4(),
      type: type,
      nickname: _clean(place.nickname),
      address: _clean(place.address),
      city: _clean(place.city),
      state: _clean(place.state)?.toUpperCase(),
      placeId: place.placeId,
      placeName: _clean(place.placeName),
      point: place.point,
      budgetCents: budgetCents != null && budgetCents > 0 ? budgetCents : null,
      startedAt: startedAt,
      createdAt: now,
      updatedAt: now,
    );
    await _save(outing);
    return outing;
  }

  /// Explicit correction of the place of ONE outing: only its own copy
  /// changes. Same id, so drinks, photos, outing-only items and the tab stay
  /// with it; other outings and the saved place are untouched.
  Future<void> changePlace(String id, PlaceSnapshot place) async {
    final outing = byId(id);
    if (outing == null) return;
    _checkPlace(place);
    await _save(outing.withPlace(
      placeId: place.placeId,
      nickname: _clean(place.nickname),
      placeName: _clean(place.placeName),
      address: _clean(place.address),
      city: _clean(place.city),
      state: _clean(place.state)?.toUpperCase(),
      point: place.point,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> finish(String id, DateTime endedAt) async {
    final outing = byId(id);
    if (outing == null || !outing.isActive) return;
    if (endedAt.isBefore(outing.startedAt)) {
      throw ArgumentError('O fim não pode ser antes do início.');
    }
    if (endedAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      throw ArgumentError('O fim não pode estar no futuro.');
    }
    await _save(outing.copyWith(endedAt: endedAt, updatedAt: DateTime.now()));
  }

  /// Sets or clears (null) the optional drinks budget of an outing.
  Future<void> setBudget(String id, int? cents) async {
    final outing = byId(id);
    if (outing == null) return;
    await _save(outing.copyWith(
      budgetCents: () => (cents != null && cents > 0) ? cents : null,
      updatedAt: DateTime.now(),
    ));
  }

  /// Optional details of the personal account (all of them can be left out).
  Future<void> setFeedbackDetails(
    String id, {
    WakeFeeling? wake,
    Hangover? hangover,
    String? note,
  }) async {
    final outing = byId(id);
    if (outing == null) return;
    final trimmed = note?.trim();
    await _save(outing.copyWith(
      wakeFeeling: () => wake,
      hangover: () => hangover,
      feedbackNote: () => (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> answerFeedback(String id, FeedbackMood mood) async {
    final outing = byId(id);
    if (outing == null) return;
    await _save(outing.copyWith(
      feedbackMood: mood,
      feedbackStatus: FeedbackStatus.answered,
      clearSnooze: true,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> snoozeFeedback(String id, Duration by) async {
    final outing = byId(id);
    if (outing == null) return;
    final now = DateTime.now();
    await _save(outing.copyWith(
      feedbackStatus: FeedbackStatus.snoozed,
      feedbackSnoozedUntil: now.add(by),
      updatedAt: now,
    ));
  }

  Future<void> dismissFeedback(String id) async {
    final outing = byId(id);
    if (outing == null) return;
    await _save(outing.copyWith(
      feedbackStatus: FeedbackStatus.dismissed,
      clearSnooze: true,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> _save(Outing outing) =>
      _store.put(LocalStore.outings, outing.toJson());
}
