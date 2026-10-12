import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';

class HistoryItem {
  const HistoryItem(this.outing, this.summary);

  final Outing outing;
  final OutingSummary summary;
}

class HistoryState {
  const HistoryState({this.loading = true, this.items = const []});

  final bool loading;
  final List<HistoryItem> items;
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._outings, this._drinks) : super(const HistoryState()) {
    _subs = [
      _outings.changes.listen((_) => load()),
      _drinks.changes.listen((_) => load()),
    ];
    load();
  }

  final OutingRepository _outings;
  final DrinkRepository _drinks;
  late final List<StreamSubscription<void>> _subs;

  void load() {
    emit(HistoryState(
      loading: false,
      items: [
        for (final o in _outings.ended())
          HistoryItem(o, OutingSummary.of(_drinks.entriesFor(o.id))),
      ],
    ));
  }

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
