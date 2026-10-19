import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../drinks/data/drink_repository.dart';
import '../outings/data/outing_repository.dart';
import '../outings/domain/outing.dart';

class ActiveOutingState {
  const ActiveOutingState({this.outing, this.entryCount = 0});

  /// The running outing, if any.
  final Outing? outing;
  final int entryCount;
}

/// Feeds the discreet "rolê em andamento" bar shown over the main tabs.
class ActiveOutingCubit extends Cubit<ActiveOutingState> {
  ActiveOutingCubit(this._outings, this._drinks)
    : super(const ActiveOutingState()) {
    _subs = [
      _outings.changes.listen((_) => _load()),
      _drinks.changes.listen((_) => _load()),
    ];
    _load();
  }

  final OutingRepository _outings;
  final DrinkRepository _drinks;
  late final List<StreamSubscription<void>> _subs;

  void _load() {
    final outing = _outings.active;
    emit(
      ActiveOutingState(
        outing: outing,
        entryCount: outing == null
            ? 0
            : _drinks.entriesFor(outing.id).where((e) => e.isMine).length,
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
