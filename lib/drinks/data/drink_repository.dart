import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../core/data/local_store.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import '../domain/drink_entry.dart';
import '../domain/recipe.dart';
import 'catalog_source.dart';
import '../../l10n/l10n.dart';

class DrinkRepository {
  /// [bundled] is the catalog shipped with the app (see [CatalogLoader]).
  DrinkRepository(this._store, this._bundled) {
    _store.changes
        .where(
          (c) => c == LocalStore.drinkEntries || c == LocalStore.customDrinks,
        )
        .listen((_) => _changes.add(null));
  }

  final LocalStore _store;
  final List<CatalogItem> _bundled;
  final _changes = StreamController<void>.broadcast();
  static const _uuid = Uuid();
  static const _favoritesKey = 'favorites';

  String newId() => _uuid.v4();

  /// Stable id of the record created by a lock-screen command: replaying the
  /// same command (e.g. after a crash before it was acknowledged) saves the
  /// same row again instead of a second drink. Distinct taps have distinct
  /// command ids, so they stay distinct records.
  String entryIdForCommand(String commandId) =>
      _uuid.v5(Namespace.url.value, 'bebometro:lockscreen:$commandId');

  /// Emits whenever entries, custom drinks or favorites change.
  Stream<void> get changes => _changes.stream;

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

  /// Every live (not deleted) record on the device, oldest first.
  List<DrinkEntry> allEntries() =>
      _store
          .all(LocalStore.drinkEntries)
          .where((j) => j['deleted_at'] == null)
          .map(DrinkEntry.fromJson)
          .toList()
        ..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));

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

  /// What the lock-screen "Mais uma" may repeat on its own: the latest
  /// alcoholic INDIVIDUAL order of the owner. A guest's order and a shared
  /// bottle stay in the app, where the person is chosen explicitly.
  DrinkEntry? lastPersonalIndividual(String outingId) {
    final list = entriesFor(
      outingId,
    ).where((e) => e.isAlcoholic && isPersonalIndividual(e)).toList();
    return list.isEmpty ? null : list.last;
  }

  /// Latest alcoholic record that matches [where] (for "Mais uma para Ana").
  DrinkEntry? lastAlcoholicWhere(
    String outingId,
    bool Function(DrinkEntry) where,
  ) {
    final list = entriesFor(
      outingId,
    ).where((e) => e.isAlcoholic && where(e)).toList();
    return list.isEmpty ? null : list.last;
  }

  /// An individual (not shared) order that belongs to the owner.
  static bool isPersonalIndividual(DrinkEntry e) =>
      e.consumerId == null && e.portions == null && !e.isShared;

  /// Saves an entry. Idempotent by id: repeating the call with the same id
  /// never creates a second row.
  Future<void> save(DrinkEntry entry) async {
    await _store.put(LocalStore.drinkEntries, entry.toJson());
  }

  /// Saves several records one after the other (an order of many servings).
  /// Each id is saved on its own, idempotently, so a retry never duplicates.
  Future<void> saveAll(List<DrinkEntry> entries) async {
    for (final e in entries) {
      await save(e);
    }
  }

  /// Gives an individual record to another person (null = the owner). Price,
  /// time, composition and the lock-screen origin stay untouched. A shared
  /// bottle is not reassigned this way (its portions are edited as portions).
  Future<void> reassign(String id, {required String? consumerId}) async {
    final entry = entryById(id);
    if (entry == null || entry.isDeleted || entry.portions != null) return;
    await save(
      entry.copyWithAttribution(
        consumerId: consumerId,
        portions: null,
        personalMl: entry.personalMl,
        peopleCount: entry.peopleCount,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Other records of the same outing that are the same drink as [entry]
  /// (see [DrinkEntry.isEquivalentTo]).
  List<DrinkEntry> equivalentsOf(DrinkEntry entry) => [
    for (final e in entriesFor(entry.outingId))
      if (entry.isEquivalentTo(e)) e,
  ];

  /// Applies payments to several records at once (batch price fix). Each
  /// record is saved on its own, so a failure never loses the ones before it.
  Future<void> applyPrices(
    Map<String, ({PriceKind kind, int? paidCents})> updates,
  ) async {
    final now = DateTime.now();
    for (final e in updates.entries) {
      final entry = entryById(e.key);
      if (entry == null || entry.isDeleted) continue;
      await save(
        entry.copyWithPrice(
          kind: e.value.kind,
          paidCents: e.value.paidCents,
          updatedAt: now,
        ),
      );
    }
  }

  /// Fills in the bottle/jug total of a shared, priced record (from the tab).
  Future<void> setBillTotal(String id, int? cents) async {
    final entry = entryById(id);
    if (entry == null || entry.isDeleted || !entry.isShared) return;
    await save(
      entry.copyWithBillTotal(billTotalCents: cents, updatedAt: DateTime.now()),
    );
  }

  /// [at] stamps the tombstone (see [restoreDeletedAt]).
  Future<void> delete(String id, {DateTime? at}) async {
    final entry = entryById(id);
    if (entry == null || entry.isDeleted) return;
    final now = at ?? DateTime.now();
    await save(entry.copyWith(deletedAt: now, updatedAt: now));
  }

  /// Restores [id] only if it was deleted at exactly [at]; a record deleted
  /// earlier (or by another action) stays deleted.
  Future<bool> restoreDeletedAt(String id, DateTime at) async {
    final entry = entryById(id);
    final stamp = entry?.deletedAt;
    if (entry == null || stamp == null || !stamp.isAtSameMomentAs(at)) {
      return false;
    }
    await save(entry.copyWith(clearDeleted: true, updatedAt: DateTime.now()));
    return true;
  }

  Future<void> restore(String id) async {
    final entry = entryById(id);
    if (entry == null || !entry.isDeleted) return;
    await save(entry.copyWith(clearDeleted: true, updatedAt: DateTime.now()));
  }

  List<CatalogItem> customItems() =>
      _store
          .all(LocalStore.customDrinks)
          .where((j) => j['deleted_at'] == null)
          .map(_customFromJson)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  /// The user's own drinks first, then the bundled products, then generics.
  List<CatalogItem> catalog() => [
    ...customItems(),
    ..._bundled,
    ...CatalogSource.items,
  ];

  CatalogItem? itemById(String? id) {
    if (id == null) return null;
    for (final item in catalog()) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Creates a personal drink, or updates it when [itemId] (the catalog id of
  /// an existing custom drink) is given. Records already made with the drink
  /// keep their own copy of the old data.
  Future<CatalogItem> saveCustomDrink({
    String? itemId,
    required String name,
    required DrinkCategory category,
    required int volumeMl,
    String? brand,
    String? style,
    double? abvPercent,
    List<String>? ingredients,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError(tr.repoDrinkName);
    if (volumeMl <= 0) throw ArgumentError(tr.repoDrinkVolume);
    if (abvPercent != null && (abvPercent < 0 || abvPercent > 100)) {
      throw ArgumentError(tr.repoAbvRange);
    }
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final rawId = itemId == null
        ? _uuid.v4()
        : itemId.substring(CatalogItem.customPrefix.length);
    final existing = _store.get(LocalStore.customDrinks, rawId);
    String? clean(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    final cleanIngredients = [
      for (final i in ingredients ?? const <String>[])
        if (i.trim().isNotEmpty) i.trim(),
    ];
    final json = <String, dynamic>{
      'id': rawId,
      'name': trimmed,
      'category': category.code,
      'brand': clean(brand),
      'style': clean(style),
      'volume_ml': volumeMl,
      'abv_percent': abvPercent,
      'ingredients': cleanIngredients.isEmpty ? null : cleanIngredients,
      'created_at': existing?['created_at'] ?? nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };
    await _store.put(LocalStore.customDrinks, json);
    return _customFromJson(json);
  }

  /// Makes an editable copy of a personal drink or recipe (also used to turn
  /// a reference recipe into the user's own version).
  Future<CatalogItem> duplicateCustom(CatalogItem item, {String? name}) async {
    final copyName = name ?? tr.repoCopyName(item.name);
    final recipe = item.recipe;
    if (recipe != null) {
      return saveCustomRecipe(name: copyName, components: recipe.components);
    }
    final volume = item.presentations.isEmpty
        ? 1
        : item.presentations.first.volumeMl;
    return saveCustomDrink(
      name: copyName,
      category: item.category,
      volumeMl: volume,
      brand: item.brand,
      style: item.style,
      abvPercent: item.abvPercent,
      ingredients: item.ingredients,
    );
  }

  /// Hides a personal drink from the catalog. Past records are untouched.
  Future<void> deleteCustomDrink(String itemId) async {
    final rawId = itemId.substring(CatalogItem.customPrefix.length);
    final json = _store.get(LocalStore.customDrinks, rawId);
    if (json == null) return;
    await _store.put(LocalStore.customDrinks, {
      ...json,
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Saves the user's own reusable recipe (a mixed drink with components).
  /// Passing [itemId] of an existing one updates it; records already made keep
  /// their own snapshot of the composition.
  Future<CatalogItem> saveCustomRecipe({
    String? itemId,
    required String name,
    required List<EntryComponent> components,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError(tr.repoRecipeName);
    if (components.isEmpty) {
      throw ArgumentError(tr.repoRecipeIngredient);
    }
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final rawId = itemId == null
        ? _uuid.v4()
        : itemId.substring(CatalogItem.customPrefix.length);
    final existing = _store.get(LocalStore.customDrinks, rawId);
    final json = <String, dynamic>{
      'id': rawId,
      'name': trimmed,
      'category': DrinkCategory.cocktail.code,
      'brand': null,
      'style': null,
      // A recipe has no single volume; unknown stays null (never 0).
      'volume_ml': null,
      'abv_percent': null,
      'ingredients': null,
      'components': [for (final c in components) c.toJson()],
      'created_at': existing?['created_at'] ?? nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };
    await _store.put(LocalStore.customDrinks, json);
    return _customFromJson(json);
  }

  CatalogItem _customFromJson(Map<String, dynamic> j) {
    final rawComponents = j['components'] as List?;
    if (rawComponents != null) {
      final id = '${CatalogItem.customPrefix}${j['id']}';
      return CatalogItem(
        id: id,
        name: j['name'] as String,
        category: DrinkCategory.cocktail,
        presentations: const [],
        origin: InfoOrigin.user,
        recipe: Recipe(
          id: id,
          name: j['name'] as String,
          components: [
            for (final c in rawComponents)
              EntryComponent.fromJson(Map<String, dynamic>.from(c as Map)),
          ],
        ),
      );
    }
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

  Set<String> favorites() => _store.getStringSet(_favoritesKey);

  Future<void> toggleFavorite(String itemId) async {
    final set = favorites();
    if (!set.remove(itemId)) set.add(itemId);
    await _store.setStringSet(_favoritesKey, set);
    _changes.add(null);
  }

  /// Item ids from the most recent entries, newest first, without repeats.
  List<String> recentItemIds({int limit = 12}) {
    final entries =
        _store
            .all(LocalStore.drinkEntries)
            .where(
              (j) =>
                  j['deleted_at'] == null &&
                  j['catalog_item_id'] != null &&
                  // Items that exist only inside one outing are never "recent".
                  !(j['catalog_item_id'] as String).startsWith(
                    CatalogItem.outingPrefix,
                  ),
            )
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
