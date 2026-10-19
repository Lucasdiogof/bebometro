import '../../drinks/domain/abv_source.dart';
import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/domain/recipe.dart';
import '../../tab/domain/tab_calc.dart';
import '../../tab/domain/tab_models.dart';

/// What the "new order" form collects. Pure data: no widget, no repository.
///
/// A person is a participant id of the outing's tab; the owner ("Você") is
/// [ownerId] and is stored as `null` / [ownerPortionKey] in the records.
class OrderInput {
  const OrderInput({
    required this.name,
    required this.category,
    required this.outingId,
    required this.ownerId,
    required this.at,
    this.units = const {},
    this.shared = false,
    this.portions = const {},
    this.bottles = 1,
    this.leftoverMl = 0,
    this.priceKind = PriceKind.unknown,
    this.priceCents,
    this.basis = PriceBasis.unit,
    this.containerMl,
    this.abvPercent,
    this.abvSource,
    this.brand,
    this.style,
    this.presentation,
    this.catalogItemId,
    this.composition,
  });

  final String outingId;

  /// Name exactly as typed or as the catalog calls it.
  final String name;
  final DrinkCategory category;

  /// Participant id of the account owner on this tab.
  final String ownerId;
  final DateTime at;

  /// Individual orders: participant id -> number of servings (each one is its
  /// own record, so "Mais uma", undo and price correction keep working).
  final Map<String, int> units;

  /// A bottle/jug shared by [portions] (participant id -> ml drunk; null ml is
  /// unknown, never zero). Several bottles are several records.
  final bool shared;
  final Map<String, int?> portions;
  final int bottles;
  final int leftoverMl;

  final PriceKind priceKind;

  /// The typed amount. With [PriceBasis.unit] it is per serving/bottle; with
  /// [PriceBasis.total] it is the price of the whole order (a promotion) and is
  /// spread over the servings in whole cents.
  final int? priceCents;
  final PriceBasis basis;

  final int? containerMl;
  final double? abvPercent;
  final AbvSource? abvSource;
  final String? brand;
  final String? style;
  final String? presentation;
  final String? catalogItemId;
  final Composition? composition;

  /// Servings in this order (bottles when shared).
  int get servingCount =>
      shared ? bottles : units.values.fold(0, (a, b) => a + b);
}

/// Field key -> problem. Empty = valid. Messages are keys (not text) so the
/// widget picks the localized words.
enum OrderProblem {
  nameMissing,
  nobodyPicked,
  sharersNeeded,
  portionsOverBottle,
  priceMissing,
  volumeInvalid,
  abvInvalid,
}

class OrderBuilder {
  const OrderBuilder._();

  static const maxPerPerson = 99;

  static Set<OrderProblem> problems(OrderInput i) {
    final out = <OrderProblem>{};
    if (i.name.trim().isEmpty) out.add(OrderProblem.nameMissing);
    if (i.shared) {
      if (i.portions.length < 2) out.add(OrderProblem.sharersNeeded);
      final c = i.containerMl;
      if (c != null) {
        var known = i.leftoverMl;
        for (final v in i.portions.values) {
          known += v ?? 0;
        }
        if (known > c) out.add(OrderProblem.portionsOverBottle);
      }
    } else if (i.servingCount <= 0) {
      out.add(OrderProblem.nobodyPicked);
    }
    if (i.priceKind == PriceKind.informed && i.priceCents == null) {
      out.add(OrderProblem.priceMissing);
    }
    final c = i.containerMl;
    if (c != null && (c <= 0 || c > 20000)) out.add(OrderProblem.volumeInvalid);
    final a = i.abvPercent;
    if (a != null && (a < 0 || a > 100)) out.add(OrderProblem.abvInvalid);
    return out;
  }

  /// Estimated, explicitly equal volume per sharer ("Dividir volume
  /// igualmente"): what is left of the bottle after the leftover, split among
  /// everyone. Null when the bottle size is unknown.
  static Map<String, int?> equalPortions(
    List<String> ids,
    int? containerMl,
    int leftoverMl,
  ) {
    if (ids.isEmpty) return const {};
    if (containerMl == null) return {for (final id in ids) id: null};
    final left = (containerMl - leftoverMl).clamp(0, containerMl).toInt();
    final each = left ~/ ids.length;
    return {for (final id in ids) id: each};
  }

  static String? _consumerOf(String id, String ownerId) =>
      id == ownerId ? null : id;

  static String _portionKey(String id, String ownerId) =>
      id == ownerId ? ownerPortionKey : id;

  /// The records of the order. Throws [ArgumentError] if it has problems, so a
  /// half-valid order never reaches the store.
  static List<DrinkEntry> build(
    OrderInput i, {
    required String Function() newId,
  }) {
    final p = problems(i);
    if (p.isNotEmpty) throw ArgumentError('invalid order: $p');
    return i.shared ? _shared(i, newId) : _individual(i, newId);
  }

  static List<int?> _unitPrices(OrderInput i, int servings) {
    switch (i.priceKind) {
      case PriceKind.unknown:
        return List<int?>.filled(servings, null);
      case PriceKind.complimentary:
        return List<int?>.filled(servings, 0);
      case PriceKind.informed:
        final cents = i.priceCents!;
        if (i.basis == PriceBasis.unit) {
          return List<int?>.filled(servings, cents);
        }
        return TabCalculator.allocate(
          cents,
          List<int>.filled(servings, 1),
        ).cast<int?>();
    }
  }

  static List<DrinkEntry> _individual(OrderInput i, String Function() newId) {
    final total = i.servingCount;
    final prices = _unitPrices(i, total);
    final out = <DrinkEntry>[];
    var n = 0;
    // Keep the typed order of the people so the result is deterministic.
    for (final kv in i.units.entries) {
      for (var k = 0; k < kv.value; k++) {
        final at = i.at.add(Duration(milliseconds: n));
        final price = prices[n];
        n++;
        out.add(
          DrinkEntry(
            id: newId(),
            outingId: i.outingId,
            consumedAt: at,
            name: i.name.trim(),
            category: i.category,
            createdAt: at,
            updatedAt: at,
            brand: i.brand,
            style: i.style,
            presentation: i.presentation,
            catalogItemId: i.catalogItemId,
            abvPercent: i.composition != null ? null : i.abvPercent,
            abvSource: i.composition != null ? null : i.abvSource,
            composition: i.composition,
            containerMl: i.containerMl,
            personalMl: i.containerMl,
            priceKind: i.priceKind,
            paidCents: price,
            consumerId: _consumerOf(kv.key, i.ownerId),
          ),
        );
      }
    }
    return out;
  }

  static List<DrinkEntry> _shared(OrderInput i, String Function() newId) {
    final ids = i.portions.keys.toList();
    final prices = _unitPrices(i, i.bottles);
    final ownerIn = ids.contains(i.ownerId);
    final out = <DrinkEntry>[];
    for (var b = 0; b < i.bottles; b++) {
      final at = i.at.add(Duration(milliseconds: b));
      final bill = prices[b];
      int? ownerShare;
      if (ownerIn && bill != null) {
        final parts = TabCalculator.allocate(
          bill,
          List<int>.filled(ids.length, 1),
        );
        ownerShare = parts[ids.indexOf(i.ownerId)];
      }
      out.add(
        DrinkEntry(
          id: newId(),
          outingId: i.outingId,
          consumedAt: at,
          name: i.name.trim(),
          category: i.category,
          createdAt: at,
          updatedAt: at,
          brand: i.brand,
          style: i.style,
          presentation: i.presentation,
          catalogItemId: i.catalogItemId,
          abvPercent: i.composition != null ? null : i.abvPercent,
          abvSource: i.composition != null ? null : i.abvSource,
          composition: i.composition,
          containerMl: i.containerMl,
          isShared: true,
          peopleCount: ids.length,
          personalMl: ownerIn ? i.portions[i.ownerId] : null,
          leftoverMl: i.leftoverMl,
          priceKind: i.priceKind,
          paidCents: switch (i.priceKind) {
            PriceKind.informed => ownerShare ?? 0,
            PriceKind.complimentary => 0,
            PriceKind.unknown => null,
          },
          billTotalCents: i.priceKind == PriceKind.informed ? bill : null,
          portions: {
            for (final id in ids) _portionKey(id, i.ownerId): i.portions[id],
          },
        ),
      );
    }
    return out;
  }
}
