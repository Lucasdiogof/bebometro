import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/app_prefs.dart';
import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';
import '../../outings/domain/stale_outing.dart';

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
    this.staleOuting,
    this.staleEnd,
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

  /// Set only by [HomeCubit.checkStale] when "Esse rolê ainda está
  /// acontecendo?" should be asked, with a suggested end time.
  final Outing? staleOuting;
  final DateTime? staleEnd;

  bool get hasHistory => totalOutings > 0;

  HomeState withStale(Outing outing, DateTime end) => HomeState(
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
    staleOuting: outing,
    staleEnd: end,
  );

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
  HomeCubit(this._outings, this._drinks, this._prefs)
    : super(const HomeState()) {
    _subs = [
      _outings.changes.listen((_) => load()),
      _drinks.changes.listen((_) => load()),
    ];
    load();
  }

  final OutingRepository _outings;
  final DrinkRepository _drinks;
  final AppPrefs _prefs;
  late final List<StreamSubscription<void>> _subs;
  final _stalePrompted = <String>{};

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
      final inMonth =
          outing.startedAt.year == now.year &&
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

    emit(
      HomeState(
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
      ),
    );
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

  /// Called with [checkFeedback] when the home screen opens. If the running
  /// outing has been idle for a long time, asks (once per opening, and never
  /// again for a day after the person chose to continue).
  void checkStale() {
    final outing = _outings.active;
    if (outing == null || _stalePrompted.contains(outing.id)) return;
    final now = DateTime.now();
    final until = _prefs.staleSnoozedUntil(outing.id);
    if (until != null && until.isAfter(now)) return;
    final entries = _drinks.entriesFor(outing.id);
    final last = entries.isEmpty ? null : entries.last.consumedAt;
    if (!isStaleOuting(outing, last, now)) return;
    _stalePrompted.add(outing.id);
    emit(state.withStale(outing, suggestedEnd(outing, last, now)));
  }

  /// "Continuar": keeps the outing running and stops asking for a day.
  Future<void> keepOutingRunning(String outingId) =>
      _prefs.snoozeStale(outingId, DateTime.now().add(kStaleSnooze));

  /// "Encerrar" with the (adjustable) end time the person confirmed.
  Future<void> endOuting(String outingId, DateTime endedAt) =>
      _outings.finish(outingId, endedAt);

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
