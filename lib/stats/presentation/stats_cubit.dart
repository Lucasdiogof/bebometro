import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../places/data/place_repository.dart';
import '../domain/stats_report.dart';

/// Quick periods; null days means a custom range.
enum StatsPreset {
  days7(7, '7 dias'),
  days30(30, '30 dias'),
  days90(90, '90 dias'),
  custom(null, 'Personalizado');

  const StatsPreset(this.days, this.label);

  final int? days;
  final String label;
}

class StatsState {
  const StatsState({
    this.preset = StatsPreset.days30,
    this.range,
    this.report,
    this.previous,
  });

  final StatsPreset preset;
  final StatsRange? range;
  final StatsReport? report;

  /// Same-length period right before; used only when it has data.
  final StatsReport? previous;

  /// A comparison is only shown when the earlier period has outings.
  bool get hasComparison => previous != null && previous!.outings.isNotEmpty;
}

class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._outings, this._drinks, this._places)
      : super(const StatsState()) {
    _subs = [
      _outings.changes.listen((_) => _load()),
      _drinks.changes.listen((_) => _load()),
      _places.changes.listen((_) => _load()),
    ];
    _preset = StatsPreset.days30;
    _load();
  }

  final OutingRepository _outings;
  final DrinkRepository _drinks;
  final PlaceRepository _places;
  late final List<StreamSubscription<void>> _subs;

  late StatsPreset _preset;
  StatsRange? _custom;

  void setPreset(StatsPreset p) {
    if (p == StatsPreset.custom && _custom == null) return;
    _preset = p;
    _load();
  }

  void setCustom(DateTime first, DateTime last) {
    _custom = StatsRange.custom(first, last);
    _preset = StatsPreset.custom;
    _load();
  }

  StatsReport _report(StatsRange range) => buildStats(
        range: range,
        allOutings: _outings.all(),
        entriesOf: _drinks.entriesFor,
        placeName: (id) => _places.byId(id)?.displayName,
      );

  void _load() {
    final range = _preset == StatsPreset.custom
        ? _custom!
        : StatsRange.lastDays(_preset.days!, DateTime.now());
    emit(StatsState(
      preset: _preset,
      range: range,
      report: _report(range),
      previous: _report(range.previous),
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
