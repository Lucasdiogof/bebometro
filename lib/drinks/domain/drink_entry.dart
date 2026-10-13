import 'abv_source.dart';
import 'drink_category.dart';
import 'recipe.dart';

enum PriceKind {
  /// The user typed a value (in cents).
  informed('informed'),

  /// Free drink: R$ 0, distinct from "not informed".
  complimentary('complimentary'),

  /// The user did not say how much it cost.
  unknown('unknown');

  const PriceKind(this.code);

  final String code;

  static PriceKind fromCode(String code) => PriceKind.values
      .firstWhere((k) => k.code == code, orElse: () => PriceKind.unknown);
}

/// A serving the user declares to have consumed. It stores a copy of the
/// drink data so later catalog changes never rewrite history.
class DrinkEntry {
  const DrinkEntry({
    required this.id,
    required this.outingId,
    required this.consumedAt,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.containerMl,
    this.personalMl,
    this.brand,
    this.style,
    this.presentation,
    this.catalogItemId,
    this.abvPercent,
    this.abvSource,
    this.ingredients,
    this.composition,
    this.isShared = false,
    this.peopleCount = 1,
    this.leftoverMl = 0,
    this.priceKind = PriceKind.unknown,
    this.paidCents,
    this.billTotalCents,
    this.deletedAt,
  });

  final String id;
  final String outingId;
  final DateTime consumedAt;

  // Snapshot of the drink.
  final String name;
  final DrinkCategory category;
  final String? brand;
  final String? style;
  final String? presentation;
  final String? catalogItemId;
  final double? abvPercent;

  /// Where the ABV came from when it is not the catalog's own (label, menu,
  /// typed by the user). Null for ordinary records.
  final AbvSource? abvSource;
  final List<String>? ingredients;

  /// What went into a mixed drink, as registered. Null for simple drinks.
  final Composition? composition;

  /// Volume of the whole serving (a 600 ml bottle, a 400 ml tulip). Null =
  /// unknown (mixed drinks whose final volume was not informed). Never 0 as a
  /// stand-in for "unknown".
  final int? containerMl;

  final bool isShared;
  final int peopleCount;

  /// What the user declares to have drunk; null when not known.
  final int? personalMl;
  final int leftoverMl;

  // Payment is tracked separately from consumption.
  final PriceKind priceKind;
  final int? paidCents;
  final int? billTotalCents;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  bool get isMixed => composition != null;

  /// Unknown ABV on a drink that may contain alcohol still counts as alcoholic.
  bool get isAlcoholic {
    final comp = composition;
    if (comp != null) return comp.components.any((c) => c.alcoholic);
    return category.canBeAlcoholic && (abvPercent == null || abvPercent! > 0);
  }

  bool get hasPrice => priceKind != PriceKind.unknown;

  int get effectivePaidCents => priceKind == PriceKind.informed ? (paidCents ?? 0) : 0;

  /// Pure alcohol of this record, with what is missing, or null when the drink
  /// is not alcoholic. For mixed drinks it comes from the components; for
  /// simple drinks from the volume and the ABV.
  AlcoholEstimate? get alcohol {
    if (!isAlcoholic) return null;
    final comp = composition;
    if (comp != null) return estimateComponents(comp.components);
    final ml = personalMl;
    final abv = abvPercent;
    if (ml == null || abv == null) {
      return AlcoholEstimate(pureMl: 0, missing: [name]);
    }
    return AlcoholEstimate(pureMl: ml * abv / 100, missing: const []);
  }

  /// Copy for "Mais uma": same drink, composition (with the user's changes),
  /// size, ABV, sharing and price, but a new id and its own timestamp.
  DrinkEntry repeated({required String newId, required DateTime at}) =>
      DrinkEntry(
        id: newId,
        outingId: outingId,
        consumedAt: at,
        name: name,
        category: category,
        brand: brand,
        style: style,
        presentation: presentation,
        catalogItemId: catalogItemId,
        abvPercent: abvPercent,
        abvSource: abvSource,
        ingredients: ingredients,
        composition: composition,
        containerMl: containerMl,
        isShared: isShared,
        peopleCount: peopleCount,
        personalMl: personalMl,
        leftoverMl: leftoverMl,
        priceKind: priceKind,
        paidCents: paidCents,
        billTotalCents: billTotalCents,
        createdAt: at,
        updatedAt: at,
      );

  DrinkEntry copyWith({DateTime? deletedAt, bool clearDeleted = false, DateTime? updatedAt}) =>
      DrinkEntry(
        id: id,
        outingId: outingId,
        consumedAt: consumedAt,
        name: name,
        category: category,
        brand: brand,
        style: style,
        presentation: presentation,
        catalogItemId: catalogItemId,
        abvPercent: abvPercent,
        abvSource: abvSource,
        ingredients: ingredients,
        composition: composition,
        containerMl: containerMl,
        isShared: isShared,
        peopleCount: peopleCount,
        personalMl: personalMl,
        leftoverMl: leftoverMl,
        priceKind: priceKind,
        paidCents: paidCents,
        billTotalCents: billTotalCents,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: clearDeleted ? null : (deletedAt ?? this.deletedAt),
      );

  /// Same record with a new payment. Consumption (volumes) is untouched, and
  /// for shared drinks only what the user paid changes, never the bill total.
  DrinkEntry copyWithPrice({
    required PriceKind kind,
    int? paidCents,
    required DateTime updatedAt,
  }) =>
      DrinkEntry(
        id: id,
        outingId: outingId,
        consumedAt: consumedAt,
        name: name,
        category: category,
        brand: brand,
        style: style,
        presentation: presentation,
        catalogItemId: catalogItemId,
        abvPercent: abvPercent,
        abvSource: abvSource,
        ingredients: ingredients,
        composition: composition,
        containerMl: containerMl,
        isShared: isShared,
        peopleCount: peopleCount,
        personalMl: personalMl,
        leftoverMl: leftoverMl,
        priceKind: kind,
        paidCents: kind == PriceKind.informed
            ? paidCents
            : (kind == PriceKind.complimentary ? 0 : null),
        billTotalCents: kind == PriceKind.informed ? billTotalCents : null,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'outing_id': outingId,
        'consumed_at': consumedAt.toUtc().toIso8601String(),
        'name': name,
        'category': category.code,
        'brand': brand,
        'style': style,
        'presentation': presentation,
        'catalog_item_id': catalogItemId,
        'abv_percent': abvPercent,
        'ingredients': ingredients,
        'container_ml': containerMl,
        'is_shared': isShared,
        'people_count': peopleCount,
        'personal_ml': personalMl,
        'leftover_ml': leftoverMl,
        'price_kind': priceKind.code,
        'paid_cents': paidCents,
        'bill_total_cents': billTotalCents,
        'price_source': hasPrice ? 'user' : null,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
        // Only present for mixed drinks, so simple drinks keep syncing to a
        // database that does not have the column yet.
        if (composition != null) 'composition': composition!.toJson(),
        // Same idea: only present when set, so older databases keep working.
        if (abvSource != null) 'abv_source': abvSource!.code,
      };

  factory DrinkEntry.fromJson(Map<String, dynamic> json) => DrinkEntry(
        id: json['id'] as String,
        outingId: json['outing_id'] as String,
        consumedAt: DateTime.parse(json['consumed_at'] as String).toLocal(),
        name: json['name'] as String,
        category: DrinkCategory.fromCode(json['category'] as String),
        brand: json['brand'] as String?,
        style: json['style'] as String?,
        presentation: json['presentation'] as String?,
        catalogItemId: json['catalog_item_id'] as String?,
        abvPercent: (json['abv_percent'] as num?)?.toDouble(),
        abvSource: AbvSource.fromCode(json['abv_source'] as String?),
        ingredients: (json['ingredients'] as List?)?.cast<String>(),
        composition: json['composition'] == null
            ? null
            : Composition.fromJson(
                Map<String, dynamic>.from(json['composition'] as Map)),
        containerMl: (json['container_ml'] as num?)?.toInt(),
        isShared: json['is_shared'] as bool? ?? false,
        peopleCount: (json['people_count'] as num?)?.toInt() ?? 1,
        personalMl: (json['personal_ml'] as num?)?.toInt(),
        leftoverMl: (json['leftover_ml'] as num?)?.toInt() ?? 0,
        priceKind: PriceKind.fromCode(json['price_kind'] as String? ?? 'unknown'),
        paidCents: (json['paid_cents'] as num?)?.toInt(),
        billTotalCents: (json['bill_total_cents'] as num?)?.toInt(),
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
        deletedAt: json['deleted_at'] == null
            ? null
            : DateTime.parse(json['deleted_at'] as String).toLocal(),
      );
}
