import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';

/// What is stored on this device.
class SettingsState {
  const SettingsState({this.outings = 0, this.drinks = 0});

  final int outings;
  final int drinks;
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._outings, this._drinks) : super(const SettingsState()) {
    _subs = [
      _outings.changes.listen((_) => _load()),
      _drinks.changes.listen((_) => _load()),
    ];
    _load();
  }

  final OutingRepository _outings;
  final DrinkRepository _drinks;
  late final List<StreamSubscription<void>> _subs;

  void _load() => emit(SettingsState(
        outings: _outings.count(),
        drinks: _drinks.liveEntryCount(),
      ));

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
