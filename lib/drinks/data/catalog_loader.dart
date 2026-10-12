import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';

/// Reads the versioned catalog shipped with the app (`assets/catalog`).
///
/// Product ids are stable across versions: updating the file never touches
/// favourites, custom drinks or past records (which keep their own copy).
class CatalogLoader {
  const CatalogLoader._();

  static const assetPath = 'assets/catalog/catalog_v1.json';

  /// Returns an empty list when the file is missing or invalid, so the app
  /// still works with the generic items and the user's own drinks.
  static Future<List<CatalogItem>> load() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      return parse(raw);
    } catch (e) {
      if (kDebugMode) debugPrint('[catalog] could not load $assetPath: $e');
      return const [];
    }
  }

  static List<CatalogItem> parse(String raw) {
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

  static CatalogItem _product(Map<String, dynamic> j, String? consultedOn) {
    final source = j['source'] as Map<String, dynamic>?;
    return CatalogItem(
      id: j['id'] as String,
      name: j['name'] as String,
      brand: j['brand'] as String?,
      category: DrinkCategory.fromCode(_categoryCode(j['category'] as String)),
      style: j['style'] as String?,
      abvPercent: (j['abv'] as num?)?.toDouble(),
      ingredients: (j['ingredients'] as List?)?.cast<String>(),
      origin: InfoOrigin.verified,
      note: j['note'] as String?,
      aliases: ((j['aliases'] as List?) ?? const []).cast<String>(),
      source: source == null
          ? null
          : SourceRef(
              url: source['url'] as String,
              label: source['label'] as String,
              consultedOn: consultedOn,
            ),
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

  /// The JSON uses camelCase for "nonAlcoholic"; the app's code is snake_case.
  static String _categoryCode(String raw) =>
      raw == 'nonAlcoholic' ? DrinkCategory.nonAlcoholic.code : raw;
}
