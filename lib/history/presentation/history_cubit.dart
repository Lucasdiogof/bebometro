import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/formatters.dart';
import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';
import '../../tab/data/tab_repository.dart';
import '../../l10n/l10n.dart';

class HistoryItem {
  const HistoryItem(this.outing, this.summary);

  final Outing outing;
  final OutingSummary summary;
}

enum HistoryPeriod {
  all,
  thisMonth,
  last90Days;

  String get label => switch (this) {
    HistoryPeriod.all => tr.historyPeriodAll,
    HistoryPeriod.thisMonth => tr.historyPeriodMonth,
    HistoryPeriod.last90Days => tr.statsPresetDays('${90}'),
  };
}

class HistoryState {
  const HistoryState({
    this.loading = true,
    this.total = 0,
    this.items = const [],
    this.query = '',
    this.period = HistoryPeriod.all,
    this.type,
  });

  final bool loading;

  /// Finished outings before filters.
  final int total;

  /// After search and filters, newest first.
  final List<HistoryItem> items;
  final String query;
  final HistoryPeriod period;
  final OutingType? type;

  bool get hasFilters =>
      query.trim().isNotEmpty || period != HistoryPeriod.all || type != null;
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._outings, this._drinks, [this._tabs])
    : super(const HistoryState()) {
    _subs = [
      _outings.changes.listen((_) => load()),
      _drinks.changes.listen((_) => load()),
    ];
    load();
  }

  final OutingRepository _outings;
  final DrinkRepository _drinks;
  final TabRepository? _tabs;
  late final List<StreamSubscription<void>> _subs;

  String _query = '';
  HistoryPeriod _period = HistoryPeriod.all;
  OutingType? _type;

  void setQuery(String q) {
    _query = q;
    load();
  }

  void setPeriod(HistoryPeriod p) {
    _period = p;
    load();
  }

  void setType(OutingType? t) {
    _type = t;
    load();
  }

  void clearFilters() {
    _query = '';
    _period = HistoryPeriod.all;
    _type = null;
    load();
  }

  void load() {
    final ended = _outings.ended();
    final now = DateTime.now();
    final q = normalizeText(_query);

    bool inPeriod(Outing o) {
      switch (_period) {
        case HistoryPeriod.all:
          return true;
        case HistoryPeriod.thisMonth:
          return o.startedAt.year == now.year && o.startedAt.month == now.month;
        case HistoryPeriod.last90Days:
          return o.startedAt.isAfter(now.subtract(const Duration(days: 90)));
      }
    }

    final filtered = ended.where((o) {
      if (!inPeriod(o)) return false;
      if (_type != null && o.type != _type) return false;
      if (q.isNotEmpty) {
        // Place, drinks of the outing and the people who were there.
        final people = _tabs == null
            ? const <String>[]
            : [for (final p in _tabs.load(o.id).participants) p.displayName];
        final drinks = [for (final e in _drinks.entriesFor(o.id)) e.name];
        final name = searchKey(
          '${o.nickname ?? ''} ${o.address ?? ''} ${drinks.join(' ')} ${people.join(' ')}',
        );
        if (!searchKey(q).split(' ').every(name.contains)) return false;
      }
      return true;
    });

    emit(
      HistoryState(
        loading: false,
        total: ended.length,
        items: [
          for (final o in filtered)
            HistoryItem(o, OutingSummary.of(_drinks.entriesFor(o.id))),
        ],
        query: _query,
        period: _period,
        type: _type,
      ),
    );
  }

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
