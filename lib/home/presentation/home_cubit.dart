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
    this.pastOutings = 0,
    this.pastDrinks = 0,
    this.pastPersonalMl = 0,
    this.pastInformedCents = 0,
    this.pastUnpriced = 0,
    this.feedbackOuting,
  });

  final bool loading;
  final Outing? active;
  final OutingSummary? activeSummary;

  // Totals over finished outings, computed from real records only.
  final int pastOutings;
  final int pastDrinks;
  final int pastPersonalMl;
  final int pastInformedCents;
  final int pastUnpriced;

  /// Set only by [HomeCubit.checkFeedback] when the sheet should be shown.
  final Outing? feedbackOuting;

  bool get hasHistory => pastOutings > 0;
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
    var drinks = 0;
    var ml = 0;
    var cents = 0;
    var unpriced = 0;
    for (final outing in ended) {
      final s = OutingSummary.of(_drinks.entriesFor(outing.id));
      drinks += s.entryCount;
      ml += s.personalMl;
      cents += s.informedCents;
      unpriced += s.unpricedCount;
    }
    emit(HomeState(
      loading: false,
      active: active,
      activeSummary: active == null
          ? null
          : OutingSummary.of(_drinks.entriesFor(active.id)),
      pastOutings: ended.length,
      pastDrinks: drinks,
      pastPersonalMl: ml,
      pastInformedCents: cents,
      pastUnpriced: unpriced,
    ));
  }

  /// Called when the home screen becomes visible. Offers the post-outing
  /// feedback at most once per outing per app session; the answer, snooze
  /// or dismissal is persisted.
  void checkFeedback() {
    if (_outings.active != null) return;
    final pending = _outings.pendingFeedback(DateTime.now());
    if (pending == null || _promptedOutings.contains(pending.id)) return;
    _promptedOutings.add(pending.id);
    emit(HomeState(
      loading: false,
      active: state.active,
      activeSummary: state.activeSummary,
      pastOutings: state.pastOutings,
      pastDrinks: state.pastDrinks,
      pastPersonalMl: state.pastPersonalMl,
      pastInformedCents: state.pastInformedCents,
      pastUnpriced: state.pastUnpriced,
      feedbackOuting: pending,
    ));
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
