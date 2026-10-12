import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/formatters.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';

/// Filters that can be combined with the text search.
class CatalogFilters {
  const CatalogFilters({
    this.category,
    this.brand,
    this.styleGroup,
    this.kind,
    this.nonAlcoholic = false,
  });

  final DrinkCategory? category;
  final String? brand;
  final String? styleGroup;
  final PresentationKind? kind;

  /// Only drinks without alcohol (non-alcoholic products and water).
  final bool nonAlcoholic;

  bool get isEmpty =>
      category == null &&
      brand == null &&
      styleGroup == null &&
      kind == null &&
      !nonAlcoholic;

  /// Filters other than the category row (shown in the filter sheet).
  int get advancedCount =>
      (brand != null ? 1 : 0) +
      (styleGroup != null ? 1 : 0) +
      (kind != null ? 1 : 0) +
      (nonAlcoholic ? 1 : 0);

  CatalogFilters copyWith({
    DrinkCategory? category,
    String? brand,
    String? styleGroup,
    PresentationKind? kind,
    bool? nonAlcoholic,
    bool clearCategory = false,
    bool clearBrand = false,
    bool clearStyle = false,
    bool clearKind = false,
  }) =>
      CatalogFilters(
        category: clearCategory ? null : (category ?? this.category),
        brand: clearBrand ? null : (brand ?? this.brand),
        styleGroup: clearStyle ? null : (styleGroup ?? this.styleGroup),
        kind: clearKind ? null : (kind ?? this.kind),
        nonAlcoholic: nonAlcoholic ?? this.nonAlcoholic,
      );
}

class CatalogState {
  const CatalogState({
    this.query = '',
    this.filters = const CatalogFilters(),
    this.items = const [],
    this.recents = const [],
    this.favoriteItems = const [],
    this.favorites = const {},
    this.brands = const [],
    this.styleGroups = const [],
    this.kinds = const [],
  });

  final String query;
  final CatalogFilters filters;

  /// Results for the current search and filters, one entry per product.
  final List<CatalogItem> items;

  /// Shortcuts shown above the full list when nothing is being searched.
  final List<CatalogItem> recents;
  final List<CatalogItem> favoriteItems;
  final Set<String> favorites;

  // Options offered by the filter sheet.
  final List<String> brands;
  final List<String> styleGroups;
  final List<PresentationKind> kinds;

  bool get isFiltering => query.trim().isNotEmpty || !filters.isEmpty;
}

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._drinks) : super(const CatalogState()) {
    _sub = _drinks.changes.listen((_) => _refresh());
    _refresh();
  }

  final DrinkRepository _drinks;
  late final StreamSubscription<void> _sub;

  String _query = '';
  CatalogFilters _filters = const CatalogFilters();

  void setQuery(String q) {
    _query = q;
    _refresh();
  }

  void setCategory(DrinkCategory? c) {
    _filters = c == null
        ? _filters.copyWith(clearCategory: true)
        : _filters.copyWith(category: c);
    _refresh();
  }

  void setBrand(String? v) {
    _filters = v == null
        ? _filters.copyWith(clearBrand: true)
        : _filters.copyWith(brand: v);
    _refresh();
  }

  void setStyleGroup(String? v) {
    _filters = v == null
        ? _filters.copyWith(clearStyle: true)
        : _filters.copyWith(styleGroup: v);
    _refresh();
  }

  void setKind(PresentationKind? v) {
    _filters = v == null
        ? _filters.copyWith(clearKind: true)
        : _filters.copyWith(kind: v);
    _refresh();
  }

  void setNonAlcoholic(bool v) {
    _filters = _filters.copyWith(nonAlcoholic: v);
    _refresh();
  }

  /// Removes every filter; the text search is kept.
  void clearFilters() {
    _filters = const CatalogFilters();
    _refresh();
  }

  Future<void> toggleFavorite(String id) => _drinks.toggleFavorite(id);

  Future<void> deleteCustom(String id) => _drinks.deleteCustomDrink(id);

  bool _matches(CatalogItem i, CatalogFilters f, List<String> tokens) {
    if (f.category != null && i.category != f.category) return false;
    if (f.brand != null && i.brand != f.brand) return false;
    if (f.styleGroup != null && i.styleGroup != f.styleGroup) return false;
    if (f.kind != null && !i.presentations.any((p) => p.kind == f.kind)) {
      return false;
    }
    if (f.nonAlcoholic &&
        i.category != DrinkCategory.nonAlcoholic &&
        i.category != DrinkCategory.water) {
      return false;
    }
    if (tokens.isNotEmpty) {
      final text = i.searchText;
      if (!tokens.every(text.contains)) return false;
    }
    return true;
  }

  void _refresh() {
    final favorites = _drinks.favorites();
    final all = _drinks.catalog();
    final byId = {for (final i in all) i.id: i};

    final tokens =
        normalizeText(_query).split(' ').where((t) => t.isNotEmpty).toList();
    final items = all.where((i) => _matches(i, _filters, tokens)).toList()
      ..sort((a, b) {
        if (a.isCustom != b.isCustom) return a.isCustom ? -1 : 1;
        return normalizeText(a.displayName)
            .compareTo(normalizeText(b.displayName));
      });

    const preferredStyles = [
      'Lager/Pilsen',
      'IPA',
      'Pale Ale',
      'Weiss',
      'Witbier',
      'Stout/Porter',
    ];
    final styleGroups = {
      for (final i in all)
        if (i.styleGroup != null) i.styleGroup!,
    }.toList()
      ..sort((a, b) {
        final ia = preferredStyles.indexOf(a);
        final ib = preferredStyles.indexOf(b);
        if (ia != ib) {
          return (ia < 0 ? 999 : ia).compareTo(ib < 0 ? 999 : ib);
        }
        return a.compareTo(b);
      });

    emit(CatalogState(
      query: _query,
      filters: _filters,
      items: items,
      recents: [
        for (final id in _drinks.recentItemIds(limit: 6)) ?byId[id],
      ],
      favoriteItems: all.where((i) => favorites.contains(i.id)).toList(),
      favorites: favorites,
      brands: ({
        for (final i in all)
          if (i.brand != null && i.brand!.isNotEmpty) i.brand!,
      }.toList()
        ..sort((a, b) => normalizeText(a).compareTo(normalizeText(b)))),
      styleGroups: styleGroups,
      kinds: [
        for (final k in PresentationKind.values)
          if (all.any((i) => i.presentations.any((p) => p.kind == k))) k,
      ],
    ));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
