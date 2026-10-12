import 'package:uuid/uuid.dart';

import '../../core/data/local_store.dart';
import '../../core/sync/sync_cubit.dart';
import '../domain/outing.dart';

class ActiveOutingExistsException implements Exception {
  const ActiveOutingExistsException();

  @override
  String toString() => 'Já existe um rolê em andamento.';
}

class OutingRepository {
  OutingRepository(this._store, this._sync);

  final LocalStore _store;
  final SyncCubit _sync;
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

  Outing? byId(String id) {
    final json = _store.get(LocalStore.outings, id);
    return json == null ? null : Outing.fromJson(json);
  }

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

  Future<Outing> start({
    required OutingType type,
    String? nickname,
    String? address,
    required DateTime startedAt,
  }) async {
    if (active != null) throw const ActiveOutingExistsException();
    final nick = nickname?.trim();
    final addr = address?.trim();
    if ((nick == null || nick.isEmpty) && (addr == null || addr.isEmpty)) {
      throw ArgumentError('Informe um apelido ou um endereço para o local.');
    }
    final now = DateTime.now();
    final outing = Outing(
      id: _uuid.v4(),
      type: type,
      nickname: (nick == null || nick.isEmpty) ? null : nick,
      address: (addr == null || addr.isEmpty) ? null : addr,
      startedAt: startedAt,
      createdAt: now,
      updatedAt: now,
    );
    await _save(outing);
    return outing;
  }

  Future<void> finish(String id, DateTime endedAt) async {
    final outing = byId(id);
    if (outing == null || !outing.isActive) return;
    if (endedAt.isBefore(outing.startedAt)) {
      throw ArgumentError('O fim não pode ser antes do início.');
    }
    await _save(outing.copyWith(endedAt: endedAt, updatedAt: DateTime.now()));
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

  Future<void> _save(Outing outing) async {
    await _store.put(LocalStore.outings, outing.toJson());
    await _sync.markDirty(LocalStore.outings, outing.id);
  }
}
