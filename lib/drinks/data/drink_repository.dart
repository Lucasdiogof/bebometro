import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../core/data/local_store.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import '../domain/drink_entry.dart';
import 'catalog_source.dart';

class DrinkRepository {
  DrinkRepository(this._store) {
    _store.changes
        .where(
          (c) => c == LocalStore.drinkEntries || c == LocalStore.customDrinks,
        )
        .listen((_) => _changes.add(null));
  }

  final LocalStore _store;
  final _changes = StreamController<void>.broadcast();
  static const _uuid = Uuid();
  static const _favoritesKey = 'favorites';

  String newId() => _uuid.v4();

  /// Emits whenever entries, custom drinks or favorites change.
  Stream<void> get changes => _changes.stream;

  // ---- Entries -----------------------------------------------------------

  /// Live (not deleted) entries of an outing, oldest first.
  List<DrinkEntry> entriesFor(String outingId) {
    return _store
        .all(LocalStore.drinkEntries)
        .where((j) => j['outing_id'] == outingId && j['deleted_at'] == null)
        .map(DrinkEntry.fromJson)
        .toList()
      ..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
  }

  /// Number of live (not deleted) drink records on this device.
  int liveEntryCount() => _store
      .all(LocalStore.drinkEntries)
      .where((j) => j['deleted_at'] == null)
      .length;

  DrinkEntry? entryById(String id) {
    final json = _store.get(LocalStore.drinkEntries, id);
    return json == null ? null : DrinkEntry.fromJson(json);
  }

  /// Latest alcoholic entry of the outing. Water and soft drinks never
  /// replace it, so "Mais uma" keeps working after a glass of water.
  DrinkEntry? lastAlcoholic(String outingId) {
    final list = entriesFor(outingId).where((e) => e.isAlcoholic).toList();
    return list.isEmpty ? null : list.last;
  }

  /// Saves an entry. Idempotent by id: repeating the call with the same id
  /// never creates a second row.
  Future<void> save(DrinkEntry entry) async {
    await _store.put(LocalStore.drinkEntries, entry.toJson());
  }

  Future<void> delete(String id) async {
    final entry = entryById(id);
    if (entry == null || entry.isDeleted) return;
    final now = DateTime.now();
    await save(entry.copyWith(deletedAt: now, updatedAt: now));
  }

  Future<void> restore(String id) async {
    final entry = entryById(id);
    if (entry == null || !entry.isDeleted) return;
    await save(entry.copyWith(clearDeleted: true, updatedAt: DateTime.now()));
  }

  // ---- Catalog -----------------------------------------------------------

  List<CatalogItem> customItems() => _store
      .all(LocalStore.customDrinks)
      .where((j) => j['deleted_at'] == null)
      .map(_customFromJson)
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  List<CatalogItem> catalog() => [...customItems(), ...CatalogSource.items];

  CatalogItem? itemById(String? id) {
    if (id == null) return null;
    for (final item in catalog()) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<CatalogItem> saveCustomDrink({
    required String name,
    required DrinkCategory category,
    required int volumeMl,
    String? brand,
    String? style,
    double? abvPercent,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Dê um nome para a bebida.');
    if (volumeMl <= 0) throw ArgumentError('Informe o volume em ml.');
    final now = DateTime.now().toUtc().toIso8601String();
    final id = _uuid.v4();
    String? clean(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final json = <String, dynamic>{
      'id': id,
      'name': trimmed,
      'category': category.code,
      'brand': clean(brand),
      'style': clean(style),
      'volume_ml': volumeMl,
      'abv_percent': abvPercent,
      'ingredients': null,
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
    };
    await _store.put(LocalStore.customDrinks, json);
    return _customFromJson(json);
  }

  CatalogItem _customFromJson(Map<String, dynamic> j) {
    final volume = (j['volume_ml'] as num).toInt();
    return CatalogItem(
      id: '${CatalogItem.customPrefix}${j['id']}',
      name: j['name'] as String,
      brand: j['brand'] as String?,
      style: j['style'] as String?,
      category: DrinkCategory.fromCode(j['category'] as String),
      abvPercent: (j['abv_percent'] as num?)?.toDouble(),
      ingredients: (j['ingredients'] as List?)?.cast<String>(),
      origin: InfoOrigin.user,
      presentations: [Presentation('$volume ml', volume)],
    );
  }

  // ---- Favorites & recents (kept per device) -------------------------------

  Set<String> favorites() => _store.getStringSet(_favoritesKey);

  Future<void> toggleFavorite(String itemId) async {
    final set = favorites();
    if (!set.remove(itemId)) set.add(itemId);
    await _store.setStringSet(_favoritesKey, set);
    _changes.add(null);
  }

  /// Item ids from the most recent entries, newest first, without repeats.
  List<String> recentItemIds({int limit = 12}) {
    final entries = _store
        .all(LocalStore.drinkEntries)
        .where((j) => j['deleted_at'] == null && j['catalog_item_id'] != null)
        .map(DrinkEntry.fromJson)
        .toList()
      ..sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
    final seen = <String>{};
    for (final e in entries) {
      seen.add(e.catalogItemId!);
      if (seen.length >= limit) break;
    }
    return seen.toList();
  }
}
