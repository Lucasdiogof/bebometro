import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/formatters.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';

enum CatalogFilter { all, favorites, recents }

class CatalogState {
  const CatalogState({
    this.query = '',
    this.category,
    this.filter = CatalogFilter.all,
    this.items = const [],
    this.favorites = const {},
  });

  final String query;
  final DrinkCategory? category;
  final CatalogFilter filter;
  final List<CatalogItem> items;
  final Set<String> favorites;
}

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._drinks) : super(const CatalogState()) {
    _sub = _drinks.changes.listen((_) => _refresh());
    _refresh();
  }

  final DrinkRepository _drinks;
  late final StreamSubscription<void> _sub;

  String _query = '';
  DrinkCategory? _category;
  CatalogFilter _filter = CatalogFilter.all;

  void setQuery(String q) {
    _query = q;
    _refresh();
  }

  void setCategory(DrinkCategory? c) {
    _category = c;
    _refresh();
  }

  void setFilter(CatalogFilter f) {
    _filter = f;
    _refresh();
  }

  Future<void> toggleFavorite(String id) => _drinks.toggleFavorite(id);

  void _refresh() {
    final favorites = _drinks.favorites();
    var items = _drinks.catalog();

    if (_filter == CatalogFilter.favorites) {
      items = items.where((i) => favorites.contains(i.id)).toList();
    } else if (_filter == CatalogFilter.recents) {
      final recent = _drinks.recentItemIds();
      final byId = {for (final i in items) i.id: i};
      items = [for (final id in recent) ?byId[id]];
    }

    if (_category != null) {
      items = items.where((i) => i.category == _category).toList();
    }

    final q = normalizeText(_query);
    if (q.isNotEmpty) {
      items = items.where((i) {
        final haystack = normalizeText(
          '${i.name} ${i.brand ?? ''} ${i.style ?? ''} ${i.category.label}',
        );
        return q.split(' ').every(haystack.contains);
      }).toList();
    }

    emit(CatalogState(
      query: _query,
      category: _category,
      filter: _filter,
      items: items,
      favorites: favorites,
    ));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
