import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';

class HomeState {
  const HomeState({
    this.loading = true,
    this.active,
    this.activeSummary,
    this.lastOuting,
    this.lastSummary,
    this.totalOutings = 0,
    this.monthOutings = 0,
    this.monthDrinks = 0,
    this.monthInformedCents = 0,
    this.monthUnpriced = 0,
    this.feedbackOuting,
  });

  final bool loading;
  final Outing? active;
  final OutingSummary? activeSummary;

  /// Most recent finished outing.
  final Outing? lastOuting;
  final OutingSummary? lastSummary;

  /// Number of finished outings ever (drives the empty state).
  final int totalOutings;

  // Current calendar month, from real records only.
  final int monthOutings;
  final int monthDrinks;
  final int monthInformedCents;
  final int monthUnpriced;

  /// Set only by [HomeCubit.checkFeedback] when the sheet should be shown.
  final Outing? feedbackOuting;

  bool get hasHistory => totalOutings > 0;

  HomeState withFeedback(Outing outing) => HomeState(
        loading: false,
        active: active,
        activeSummary: activeSummary,
        lastOuting: lastOuting,
        lastSummary: lastSummary,
        totalOutings: totalOutings,
        monthOutings: monthOutings,
        monthDrinks: monthDrinks,
        monthInformedCents: monthInformedCents,
        monthUnpriced: monthUnpriced,
        feedbackOuting: outing,
      );
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._outings, this._drinks) : super(const HomeState()) {
    _subs = [
      _outings.changes.listen((_) => load()),
      _drinks.changes.listen((_) => load()),
    ];
    load();
  }

  final OutingRepository _outings;
  final DrinkRepository _drinks;
  late final List<StreamSubscription<void>> _subs;

  /// Outings whose sheet was already shown in this app session.
  final _promptedOutings = <String>{};

  void load() {
    final active = _outings.active;
    final ended = _outings.ended();
    final now = DateTime.now();

    var monthOutings = 0;
    var monthDrinks = 0;
    var monthCents = 0;
    var monthUnpriced = 0;
    Outing? last;
    OutingSummary? lastSummary;

    for (final outing in ended) {
      final inMonth = outing.startedAt.year == now.year &&
          outing.startedAt.month == now.month;
      final needsSummary = inMonth || last == null;
      if (!needsSummary) {
        continue;
      }
      final s = OutingSummary.of(_drinks.entriesFor(outing.id));
      if (last == null) {
        last = outing;
        lastSummary = s;
      }
      if (inMonth) {
        monthOutings++;
        monthDrinks += s.entryCount;
        monthCents += s.informedCents;
        monthUnpriced += s.unpricedCount;
      }
    }

    emit(HomeState(
      loading: false,
      active: active,
      activeSummary: active == null
          ? null
          : OutingSummary.of(_drinks.entriesFor(active.id)),
      lastOuting: last,
      lastSummary: lastSummary,
      totalOutings: ended.length,
      monthOutings: monthOutings,
      monthDrinks: monthDrinks,
      monthInformedCents: monthCents,
      monthUnpriced: monthUnpriced,
    ));
  }

  /// Called once when the home screen opens. Offers the post-outing feedback
  /// at most once per outing per app session; the answer, snooze or dismissal
  /// is persisted.
  void checkFeedback() {
    if (_outings.active != null) return;
    final pending = _outings.pendingFeedback(DateTime.now());
    if (pending == null || _promptedOutings.contains(pending.id)) return;
    _promptedOutings.add(pending.id);
    emit(state.withFeedback(pending));
  }

  Future<void> answerFeedback(String outingId, FeedbackMood mood) =>
      _outings.answerFeedback(outingId, mood);

  Future<void> snoozeFeedback(String outingId) =>
      _outings.snoozeFeedback(outingId, const Duration(days: 1));

  Future<void> dismissFeedback(String outingId) =>
      _outings.dismissFeedback(outingId);

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
