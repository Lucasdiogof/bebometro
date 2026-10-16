import 'dart:convert';

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

/// Where a record came from, when it was not typed in the app: today only a
/// lock-screen "Mais uma". [tappedAt] is the moment of the tap and never
/// changes, even when the person corrects the record's time later.
class EntryOrigin {
  const EntryOrigin.lockScreen({required this.commandId, required this.tappedAt})
      : kind = lockScreenKind;

  const EntryOrigin._(this.kind, this.commandId, this.tappedAt);

  static const lockScreenKind = 'lock_screen';

  /// Stored code ("lock_screen").
  final String kind;

  /// Stable id of the command that created the record.
  final String commandId;

  /// Original time of the tap (immutable).
  final DateTime tappedAt;

  bool get isLockScreen => kind == lockScreenKind;

  Map<String, dynamic> toJson() => {
        'entry_origin': kind,
        'origin_command_id': commandId,
        'origin_tapped_at': tappedAt.toUtc().toIso8601String(),
      };

  /// Null for records without an origin (manual and older records): nothing
  /// is ever guessed for them.
  static EntryOrigin? fromJson(Map<String, dynamic> j) {
    final kind = j['entry_origin'] as String?;
    final id = j['origin_command_id'] as String?;
    final at = j['origin_tapped_at'] as String?;
    if (kind == null || id == null || at == null) return null;
    final parsed = DateTime.tryParse(at);
    return parsed == null ? null : EntryOrigin._(kind, id, parsed.toLocal());
  }
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
    this.entryOrigin,
  });

  /// Lock-screen origin; null for records typed in the app and older ones.
  /// Kept by every correction (price, composition, portion, time).
  final EntryOrigin? entryOrigin;

  /// The person changed the time of a lock-screen record.
  bool get timeCorrected =>
      entryOrigin != null && !entryOrigin!.tappedAt.isAtSameMomentAs(consumedAt);

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

  /// Same drink as [o] in the same outing, for applying one price to several
  /// records. It compares the identity (catalog id or name), brand, category,
  /// presentation, container volume, sharing (people and the person's portion),
  /// ABV and the composition (a cocktail with other ingredients or amounts is NOT
  /// the same drink). Time, price and leftovers do not matter.
  bool isEquivalentTo(DrinkEntry o) =>
      o.id != id &&
      !o.isDeleted &&
      o.outingId == outingId &&
      _identity == o._identity &&
      category == o.category &&
      (brand ?? '') == (o.brand ?? '') &&
      (presentation ?? '') == (o.presentation ?? '') &&
      containerMl == o.containerMl &&
      isShared == o.isShared &&
      peopleCount == o.peopleCount &&
      personalMl == o.personalMl &&
      abvPercent == o.abvPercent &&
      jsonEncode(composition?.toJson()) == jsonEncode(o.composition?.toJson());

  String get _identity => catalogItemId ?? 'name:${name.trim().toLowerCase()}';

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
  /// [origin] is the origin of THIS new action (a lock-screen command), or
  /// null for a repeat done in the app: the source's origin is never copied.
  DrinkEntry repeated(
          {required String newId, required DateTime at, EntryOrigin? origin}) =>
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
        entryOrigin: origin,
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
        entryOrigin: entryOrigin,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: clearDeleted ? null : (deletedAt ?? this.deletedAt),
      );

  /// Same record with the bottle/jug total of a shared drink filled in or
  /// corrected. Consumption and what the user paid stay untouched.
  DrinkEntry copyWithBillTotal({
    required int? billTotalCents,
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
        priceKind: priceKind,
        paidCents: paidCents,
        billTotalCents: billTotalCents,
        createdAt: createdAt,
        entryOrigin: entryOrigin,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
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
        entryOrigin: entryOrigin,
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
        // Only lock-screen records carry these keys (same idea as above).
        if (entryOrigin != null) ...entryOrigin!.toJson(),
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
        entryOrigin: EntryOrigin.fromJson(json),
      );
}
