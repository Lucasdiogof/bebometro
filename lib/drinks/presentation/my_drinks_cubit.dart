import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../outings/data/outing_repository.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';

class MyDrinksState {
  const MyDrinksState({this.items = const [], this.activeOutingId});

  /// The user's own drinks and recipes.
  final List<CatalogItem> items;

  /// Where "Registrar" can add a drink; null when no outing is running.
  final String? activeOutingId;
}

class MyDrinksCubit extends Cubit<MyDrinksState> {
  MyDrinksCubit(this._drinks, this._outings) : super(const MyDrinksState()) {
    _subs = [
      _drinks.changes.listen((_) => _load()),
      _outings.changes.listen((_) => _load()),
    ];
    _load();
  }

  final DrinkRepository _drinks;
  final OutingRepository _outings;
  late final List<StreamSubscription<void>> _subs;

  void _load() => emit(
    MyDrinksState(
      items: _drinks.customItems(),
      activeOutingId: _outings.active?.id,
    ),
  );

  Future<void> duplicate(CatalogItem item) => _drinks.duplicateCustom(item);

  Future<void> delete(CatalogItem item) => _drinks.deleteCustomDrink(item.id);

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
