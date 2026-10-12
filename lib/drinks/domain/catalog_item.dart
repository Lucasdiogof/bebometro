import 'drink_category.dart';

/// Where a catalog item's information comes from.
enum InfoOrigin {
  /// Generic reference item. Values are typical, not an official product label.
  generic('generic', 'Genérico'),

  /// Created by the user on this device/account.
  user('user', 'Criada por você'),

  /// Confirmed against an official source (reserved for future catalog data).
  verified('verified', 'Verificado');

  const InfoOrigin(this.code, this.label);

  final String code;
  final String label;
}

/// One way a product is served or sold (can, long neck, 400 ml tulip...).
class Presentation {
  const Presentation(this.label, this.volumeMl);

  final String label;
  final int volumeMl;
}

/// A product that can be logged. A single product carries several
/// presentations, so it is not duplicated for each size.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.presentations,
    this.brand,
    this.style,
    this.abvPercent,
    this.ingredients,
    this.origin = InfoOrigin.generic,
    this.note,
  });

  final String id;
  final String name;
  final String? brand;
  final DrinkCategory category;
  final String? style;
  final List<Presentation> presentations;

  /// Null means unknown, which is never the same as 0.
  final double? abvPercent;

  /// Null means unknown; an empty list is never used to mean "unknown".
  final List<String>? ingredients;
  final InfoOrigin origin;
  final String? note;

  bool get isCustom => id.startsWith(customPrefix);

  static const customPrefix = 'custom:';

  String get subtitle {
    final parts = <String>[
      if (brand != null && brand!.isNotEmpty) brand!,
      if (style != null && style!.isNotEmpty) style!,
    ];
    return parts.isEmpty ? category.label : parts.join(' · ');
  }
}
