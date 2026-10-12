import 'drink_category.dart';

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
    required this.containerMl,
    required this.personalMl,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.style,
    this.presentation,
    this.catalogItemId,
    this.abvPercent,
    this.ingredients,
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
  final List<String>? ingredients;

  /// Volume of the whole serving (a 600 ml bottle, a 400 ml tulip).
  final int containerMl;

  final bool isShared;
  final int peopleCount;

  /// What the user declares to have drunk.
  final int personalMl;
  final int leftoverMl;

  // Payment is tracked separately from consumption.
  final PriceKind priceKind;
  final int? paidCents;
  final int? billTotalCents;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  /// Unknown ABV on a drink that may contain alcohol still counts as alcoholic.
  bool get isAlcoholic =>
      category.canBeAlcoholic && (abvPercent == null || abvPercent! > 0);

  bool get hasPrice => priceKind != PriceKind.unknown;

  int get effectivePaidCents => priceKind == PriceKind.informed ? (paidCents ?? 0) : 0;

  /// Pure alcohol in millilitres, or null when the ABV is unknown.
  double? get pureAlcoholMl =>
      abvPercent == null ? null : personalMl * abvPercent! / 100;

  /// Copy for "Mais uma": same drink, size, ABV, sharing and price, but a new
  /// id and its own timestamp.
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
        ingredients: ingredients,
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
        ingredients: ingredients,
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
        ingredients: (json['ingredients'] as List?)?.cast<String>(),
        containerMl: (json['container_ml'] as num).toInt(),
        isShared: json['is_shared'] as bool? ?? false,
        peopleCount: (json['people_count'] as num?)?.toInt() ?? 1,
        personalMl: (json['personal_ml'] as num).toInt(),
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
