import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import '../domain/recipe.dart';

/// Reads the versioned catalog shipped with the app (`assets/catalog`):
/// products (beers, spirits...) and reference recipes.
///
/// Ids are stable across versions: updating the files never touches
/// favourites, custom drinks or past records (which keep their own copy).
class CatalogLoader {
  const CatalogLoader._();

  static const productsAsset = 'assets/catalog/catalog_v1.json';
  static const recipesAsset = 'assets/catalog/recipes_v1.json';

  /// Returns what could be read; a missing or invalid file just means fewer
  /// items, so the app still works with generics and the user's own drinks.
  static Future<List<CatalogItem>> load() async {
    final items = <CatalogItem>[];
    for (final entry in {
      productsAsset: parseProducts,
      recipesAsset: parseRecipes,
    }.entries) {
      try {
        items.addAll(entry.value(await rootBundle.loadString(entry.key)));
      } catch (e) {
        if (kDebugMode) debugPrint('[catalog] could not load ${entry.key}: $e');
      }
    }
    return items;
  }

  static List<CatalogItem> parseProducts(String raw) {
    final doc = jsonDecode(raw) as Map<String, dynamic>;
    final consultedOn = doc['consultedOn'] as String?;
    final items = <CatalogItem>[];
    for (final entry in (doc['products'] as List)) {
      final json = entry as Map<String, dynamic>;
      try {
        items.add(_product(json, consultedOn));
      } catch (e) {
        // One malformed product must not hide the rest of the catalog.
        if (kDebugMode) debugPrint('[catalog] skipped ${json['id']}: $e');
      }
    }
    return items;
  }

  static List<CatalogItem> parseRecipes(String raw) {
    final doc = jsonDecode(raw) as Map<String, dynamic>;
    final consultedOn = doc['consultedOn'] as String?;
    final items = <CatalogItem>[];
    for (final entry in (doc['recipes'] as List)) {
      final json = entry as Map<String, dynamic>;
      try {
        items.add(_recipe(json, consultedOn));
      } catch (e) {
        if (kDebugMode) debugPrint('[catalog] skipped recipe ${json['id']}: $e');
      }
    }
    return items;
  }

  static SourceRef? _source(Map<String, dynamic>? s, String? consultedOn,
          [Map<String, String> labelI18n = const {}]) =>
      s == null
          ? null
          : SourceRef(
              url: s['url'] as String,
              label: s['label'] as String,
              consultedOn: consultedOn,
              labelI18n: labelI18n,
            );

  // ---- Editorial translations ("i18n" next to each product or recipe) ------
  //
  // The files are written in Portuguese. `i18n` holds, per language code, the
  // editorial texts that were translated (notes, source names, recipe methods
  // and ingredient names) and extra search names. Manufacturer-declared
  // ingredient lists and product names are not translated.

  static Map<String, Map<String, dynamic>> _i18n(Map<String, dynamic> j) => {
        for (final e in ((j['i18n'] as Map?) ?? const {}).entries)
          e.key as String: Map<String, dynamic>.from(e.value as Map),
      };

  /// One text field of every language that has it.
  static Map<String, String> _texts(
          Map<String, Map<String, dynamic>> i18n, String field) =>
      {
        for (final e in i18n.entries)
          if (e.value[field] is String) e.key: e.value[field] as String,
      };

  static List<String> _extraAliases(Map<String, Map<String, dynamic>> i18n) => [
        for (final t in i18n.values)
          ...((t['aliases'] as List?) ?? const []).cast<String>(),
      ];

  static CatalogItem _product(Map<String, dynamic> j, String? consultedOn) {
    final abvSource = _source(j['abvSource'] as Map<String, dynamic>?,
        consultedOn, _texts(_i18n(j), 'abvSourceLabel'));
    final i18n = _i18n(j);
    final secondaryProduct = j['evidence'] == 'secondary';
    final origin = secondaryProduct
        ? InfoOrigin.secondary
        : (j['abvEvidence'] == 'secondary'
            ? InfoOrigin.mixed
            : InfoOrigin.verified);
    return CatalogItem(
      id: j['id'] as String,
      name: j['name'] as String,
      brand: j['brand'] as String?,
      category: DrinkCategory.fromCode(_categoryCode(j['category'] as String)),
      style: j['style'] as String?,
      abvPercent: (j['abv'] as num?)?.toDouble(),
      abvVariants: [
        for (final (i, v) in ((j['abvVariants'] as List?) ?? const []).indexed)
          AbvVariant(
            ((v as Map)['value'] as num).toDouble(),
            v['scope'] as String,
            scopeI18n: {
              for (final e in i18n.entries)
                if (((e.value['abvVariants'] as List?) ?? const []).length > i)
                  e.key: e.value['abvVariants'][i] as String,
            },
          ),
      ],
      abvSource: abvSource,
      ingredients: (j['ingredients'] as List?)?.cast<String>(),
      origin: origin,
      note: j['note'] as String?,
      noteI18n: _texts(i18n, 'note'),
      aliases: [
        ...((j['aliases'] as List?) ?? const []).cast<String>(),
        ..._extraAliases(i18n),
      ],
      roles: ((j['roles'] as List?) ?? const []).cast<String>(),
      source: _source(j['source'] as Map<String, dynamic>?, consultedOn,
          _texts(i18n, 'sourceLabel')),
      presentations: [
        for (final p in ((j['presentations'] as List?) ?? const []))
          Presentation.of(
            PresentationKind.fromCode((p as Map)['kind'] as String?),
            (p['ml'] as num).toInt(),
            label: p['label'] as String?,
          ),
      ],
    );
  }

  static CatalogItem _recipe(Map<String, dynamic> j, String? consultedOn) {
    final id = 'recipe:${j['id']}';
    final i18n = _i18n(j);
    final source = _source(j['source'] as Map<String, dynamic>?, consultedOn,
        _texts(i18n, 'sourceLabel'));
    final components = [
      for (final c in (j['components'] as List)) _component(c as Map<String, dynamic>),
    ];
    final method = j['method'] as String?;
    final garnish = j['garnish'] as String?;
    return CatalogItem(
      id: id,
      name: j['name'] as String,
      category: DrinkCategory.cocktail,
      presentations: const [],
      origin: InfoOrigin.recipe,
      note: j['note'] as String?,
      noteI18n: _texts(i18n, 'note'),
      aliases: [
        ...((j['aliases'] as List?) ?? const []).cast<String>(),
        ..._extraAliases(i18n),
      ],
      source: source,
      recipe: Recipe(
        id: id,
        name: j['name'] as String,
        components: components,
        source: source,
        method: method,
        garnish: garnish,
        note: j['note'] as String?,
        translations: {
          for (final e in i18n.entries)
            e.key: RecipeTexts(
              method: e.value['method'] as String?,
              garnish: e.value['garnish'] as String?,
              note: e.value['note'] as String?,
              componentNames: [
                for (final c in ((e.value['components'] as List?) ?? const []))
                  (c as Map)['name'] as String?,
              ],
              componentTexts: [
                for (final c in ((e.value['components'] as List?) ?? const []))
                  (c as Map)['text'] as String?,
              ],
            ),
        },
      ),
    );
  }

  /// Maps the unit of a reference recipe to [RecipeUnit] without converting
  /// anything: the original wording stays in `amountText` whenever the unit
  /// is not one the app models.
  static EntryComponent _component(Map<String, dynamic> c) {
    final raw = c['unit'] as String? ?? 'ml';
    final amount = (c['amount'] as num?)?.toDouble();
    final text = c['text'] as String?;
    RecipeUnit unit;
    double? value = amount;
    String? amountText = text;
    switch (raw) {
      case 'ml':
        unit = RecipeUnit.ml;
        amountText = null;
      case 'tsp':
        unit = RecipeUnit.tsp;
      case 'unit':
        unit = RecipeUnit.unit;
      case 'drops':
        unit = RecipeUnit.drop;
      default:
        // barspoon, wedge, pcs (sprigs), dash, splash, topup: kept as written.
        unit = RecipeUnit.other;
        value = null;
        amountText = text ?? _fallbackText(raw);
    }
    return EntryComponent(
      name: c['name'] as String,
      role: c['role'] as String?,
      alcoholic: c['alcoholic'] as bool? ?? false,
      amount: value,
      unit: unit,
      amountText: amountText,
      optional: c['optional'] as bool? ?? false,
    );
  }

  static String _fallbackText(String unit) {
    switch (unit) {
      case 'dash':
        return 'algumas gotas';
      case 'splash':
        return 'um toque';
      case 'topup':
        return 'completar';
      default:
        return unit;
    }
  }

  /// The JSON uses camelCase for "nonAlcoholic"; the app's code is snake_case.
  static String _categoryCode(String raw) =>
      raw == 'nonAlcoholic' ? DrinkCategory.nonAlcoholic.code : raw;
}
