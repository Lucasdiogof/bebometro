import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/formatters.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';

class CatalogState {
  const CatalogState({
    this.query = '',
    this.category,
    this.items = const [],
    this.recents = const [],
    this.favoriteItems = const [],
    this.favorites = const {},
  });

  final String query;
  final DrinkCategory? category;

  /// Results for the current search and category.
  final List<CatalogItem> items;

  /// Shortcuts shown above the full list when nothing is being searched.
  final List<CatalogItem> recents;
  final List<CatalogItem> favoriteItems;
  final Set<String> favorites;

  bool get isFiltering => query.trim().isNotEmpty || category != null;
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

  void setQuery(String q) {
    _query = q;
    _refresh();
  }

  void setCategory(DrinkCategory? c) {
    _category = c;
    _refresh();
  }

  Future<void> toggleFavorite(String id) => _drinks.toggleFavorite(id);

  void _refresh() {
    final favorites = _drinks.favorites();
    final all = _drinks.catalog();
    final byId = {for (final i in all) i.id: i};

    final recents = [
      for (final id in _drinks.recentItemIds(limit: 6)) ?byId[id],
    ];
    final favoriteItems = all.where((i) => favorites.contains(i.id)).toList();

    var items = all;
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
      items: items,
      recents: recents,
      favoriteItems: favoriteItems,
      favorites: favorites,
    ));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
