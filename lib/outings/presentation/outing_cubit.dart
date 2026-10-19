import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/app_prefs.dart';
import '../../core/utils/formatters.dart';
import '../../drinks/data/catalog_source.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/drink_draft.dart';
import '../../drinks/domain/drink_entry.dart';
import '../data/outing_repository.dart';
import '../domain/budget.dart';
import '../domain/outing.dart';
import '../domain/outing_summary.dart';
import '../../l10n/l10n.dart';

class OutingState {
  const OutingState({
    this.loading = true,
    this.outing,
    this.entries = const [],
    this.summary,
    this.lastAlcoholic,
  });

  final bool loading;
  final Outing? outing;
  final List<DrinkEntry> entries;
  final OutingSummary? summary;

  /// What "Mais uma" repeats.
  final DrinkEntry? lastAlcoholic;
}

/// A transient message (snackbar) with an optional undo.
class OutingNotice {
  const OutingNotice(this.text, {this.undoLabel, this.undo});

  final String text;
  final String? undoLabel;
  final Future<void> Function()? undo;
}

class OutingCubit extends Cubit<OutingState> {
  OutingCubit(this.outingId, this._outings, this._drinks, this._prefs)
    : super(const OutingState()) {
    _subs = [
      _outings.changes.listen((_) => load()),
      _drinks.changes.listen((_) => load()),
    ];
    load();
  }

  final String outingId;
  final OutingRepository _outings;
  final DrinkRepository _drinks;
  final AppPrefs _prefs;
  late final List<StreamSubscription<void>> _subs;
  final _notices = StreamController<OutingNotice>.broadcast();

  bool _busy = false;
  DateTime? _lastQuickAction;

  Stream<OutingNotice> get notices => _notices.stream;

  void load() {
    final outing = _outings.byId(outingId);
    final entries = _drinks.entriesFor(outingId);
    emit(
      OutingState(
        loading: false,
        outing: outing,
        entries: entries,
        summary: OutingSummary.of(entries),
        lastAlcoholic: _drinks.lastAlcoholic(outingId),
      ),
    );
    _checkBudget(outing, OutingSummary.of(entries));
  }

  bool _checkingBudget = false;

  /// Announces a budget threshold (80% / 100% of the informed spending) once,
  /// when it is crossed. The announced thresholds are remembered per outing
  /// and budget value, so a rebuild or reopening never repeats the warning,
  /// and turning the warnings off still marks them as seen.
  Future<void> _checkBudget(Outing? outing, OutingSummary summary) async {
    final budget = outing?.budgetCents;
    if (outing == null || budget == null || !outing.isActive) return;
    if (_checkingBudget) return;
    _checkingBudget = true;
    try {
      final status = BudgetStatus.of(budget, summary);
      final fired = _prefs.firedThresholds(outing.id, budget);
      final reached = status.reachedThresholds.toSet();
      final fresh = reached.difference(fired);
      if (fresh.isEmpty) return;
      await _prefs.markFired(outing.id, budget, {...fired, ...reached});
      if (!_prefs.budgetAlerts || _notices.isClosed) return;
      final top = fresh.reduce((a, b) => a > b ? a : b);
      _notices.add(
        OutingNotice(
          [
            tr.budgetReached(
              top,
              formatCents(status.informedCents),
              formatCents(budget),
            ),
            if (status.incomplete) tr.budgetReachedIncomplete,
          ].join(' '),
        ),
      );
    } finally {
      _checkingBudget = false;
    }
  }

  /// Sets or clears the optional budget. Thresholds already reached at the
  /// new value are marked as seen, so changing it does not trigger a warning.
  Future<void> setBudget(int? cents) async {
    await _outings.setBudget(outingId, cents);
    if (cents != null && cents > 0) {
      final summary = state.summary ?? OutingSummary.of(state.entries);
      final reached = BudgetStatus.of(cents, summary).reachedThresholds.toSet();
      await _prefs.markFired(outingId, cents, reached);
    }
  }

  /// Guards "Mais uma"/water against double taps and overlapping calls.
  bool _acquire() {
    final now = DateTime.now();
    final last = _lastQuickAction;
    if (_busy || (last != null && now.difference(last).inMilliseconds < 500)) {
      return false;
    }
    _busy = true;
    _lastQuickAction = now;
    return true;
  }

  Future<void> repeatLast() async {
    // The quick action repeats only an individual order of the owner (what the
    // button on the lock screen showed), never a guest's or a shared bottle.
    final last = _drinks.lastPersonalIndividual(outingId);
    if (last != null) await repeatEntry(last);
  }

  /// Repeats ANY earlier record of this outing (same composition, portion,
  /// origin of the ABV and price), logged now. "Mais uma" is this for the
  /// last alcoholic drink; the row menu uses it for the others.
  Future<void> repeatEntry(DrinkEntry source) async {
    if (source.outingId != outingId ||
        state.outing?.isActive != true ||
        !_acquire()) {
      return;
    }
    try {
      final entry = source.repeated(newId: _drinks.newId(), at: DateTime.now());
      await _drinks.save(entry);
      _notices.add(
        OutingNotice(
          [
            tr.noticeAnotherOne(entry.name),
            if (entry.personalMl != null) formatMl(entry.personalMl!),
          ].join(' · '),
          undoLabel: tr.commonUndo,
          undo: () => _drinks.delete(entry.id),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  /// A glass of water. [consumerId] is the person it is for (null = the
  /// owner); the table view never calls this without choosing a person.
  Future<void> addWater({String? consumerId}) async {
    if (state.outing?.isActive != true || !_acquire()) return;
    try {
      final now = DateTime.now();
      final draft = DrinkDraft.fromItem(
        CatalogSource.water,
        now: now,
      ).withConsumer(consumerId);
      final entry = draft.toEntry(
        id: _drinks.newId(),
        outingId: outingId,
        now: now,
      );
      await _drinks.save(entry);
      _notices.add(
        OutingNotice(
          [
            tr.noticeWater,
            if (entry.personalMl != null) formatMl(entry.personalMl!),
          ].join(' · '),
          undoLabel: tr.commonUndo,
          undo: () => _drinks.delete(entry.id),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  /// Tells that an order was added, with an Undo that removes every record
  /// of it (they were saved together).
  void announceAdded(String summary, List<String> ids) {
    _notices.add(
      OutingNotice(
        tr.orderAdded(summary),
        undoLabel: tr.commonUndo,
        undo: () async {
          for (final id in ids) {
            await _drinks.delete(id);
          }
        },
      ),
    );
  }

  /// Gives individual records to another person (null = the owner). Price,
  /// time and everything else stay; Undo puts each one back with its previous
  /// person. [toName] is only for the message.
  Future<void> moveEntries(
    List<DrinkEntry> entries,
    String? toConsumerId, {
    required String toName,
  }) async {
    final before = {for (final e in entries) e.id: e.consumerId};
    for (final e in entries) {
      await _drinks.reassign(e.id, consumerId: toConsumerId);
    }
    _notices.add(
      OutingNotice(
        tr.noticeMovedTo(toName),
        undoLabel: tr.commonUndo,
        undo: () async {
          for (final kv in before.entries) {
            await _drinks.reassign(kv.key, consumerId: kv.value);
          }
        },
      ),
    );
  }

  Future<void> deleteEntry(DrinkEntry entry) async {
    await _drinks.delete(entry.id);
    _notices.add(
      OutingNotice(
        tr.noticeEntryDeleted,
        undoLabel: tr.commonUndo,
        undo: () => _drinks.restore(entry.id),
      ),
    );
  }

  Future<void> finish(DateTime endedAt) => _outings.finish(outingId, endedAt);

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    _notices.close();
    return super.close();
  }
}
