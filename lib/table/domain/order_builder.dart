import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../tab/domain/tab_calc.dart';
import '../../tab/domain/tab_models.dart';

/// What an order is. Drinks become drink records (history, table, "Mais
/// uma"); food and other items become lines of the tab. The kind of a drink is
/// only "with alcohol" or "without": no ABV, volume or recipe is asked.
enum OrderKind {
  alcoholic,
  soft,
  food,
  other;

  bool get isDrink => this == alcoholic || this == soft;
}

/// What the "order" form collects. Pure data: no widget, no repository.
///
/// A person is a participant id of the outing's tab; the owner ("Você") is
/// [ownerId] and is stored as `null` / [ownerPortionKey] in the records.
///
/// Who consumed and who pays are two independent choices.
class OrderInput {
  const OrderInput({
    required this.name,
    required this.kind,
    required this.outingId,
    required this.ownerId,
    required this.at,
    this.quantity = 1,
    this.consumers = const [],
    this.units,
    this.payers = const [],
    this.payerCents,
    this.priceKind = PriceKind.unknown,
    this.priceCents,
    this.basis = PriceBasis.unit,
    this.category,
    this.brand,
    this.style,
    this.presentation,
    this.catalogItemId,
    this.containerMl,
    this.template,
    this.replaceProduct = false,
    this.existing = const [],
    this.existingExtra,
    this.fixedId,
    this.fixedAt,
    this.origin,
  });

  final String outingId;

  /// Name exactly as typed or as the catalog calls it.
  final String name;
  final OrderKind kind;

  /// Participant id of the account owner on this tab.
  final String ownerId;
  final DateTime at;

  /// Servings (units) ordered, at least 1.
  final int quantity;

  /// Participant ids that consumed it, in the order chosen.
  final List<String> consumers;

  /// With several consumers and several units: how many units each one had
  /// (must add up to [quantity]). Null = nobody said, so every unit is one
  /// shared order and nothing is invented per person.
  final Map<String, int>? units;

  /// Participant ids that pay, in the order chosen. Never decided by
  /// [consumers].
  final List<String> payers;

  /// Typed amount (cents) per payer for the whole order; null = equal split.
  /// Must add up to the total when the price is known.
  final Map<String, int>? payerCents;

  final PriceKind priceKind;

  /// The typed amount. With [PriceBasis.unit] it is per unit; with
  /// [PriceBasis.total] it is the price of the whole order and is spread over
  /// the units in whole cents.
  final int? priceCents;
  final PriceBasis basis;

  // Optional, from the catalog or an old record; never asked.
  final DrinkCategory? category;
  final String? brand;
  final String? style;
  final String? presentation;
  final String? catalogItemId;
  final int? containerMl;

  /// Editing: the record the order started from. Its hidden legacy data
  /// (recipe, ABV, ingredients) is carried over untouched when the name is
  /// the same, so editing never forces anybody through those fields.
  final DrinkEntry? template;

  /// Another catalog product was picked: the hidden data of [template] does
  /// not describe the new drink and is not carried over. A plain rename keeps
  /// it (history, recipe, ABV, size and origin stay stored, never shown).
  final bool replaceProduct;

  /// Editing: the records (oldest first) and the extra the order replaces.
  /// Their ids, times and origin are kept.
  final List<DrinkEntry> existing;
  final TabExtra? existingExtra;

  /// Review of a lock-screen tap: the one record gets this id (derived from
  /// the command, so it can never be saved twice), this time (the tap) and
  /// this origin.
  final String? fixedId;
  final DateTime? fixedAt;
  final EntryOrigin? origin;

  bool get isCustomPayers => payerCents != null && payers.length > 1;

  /// Cost of the whole order; null while the price is unknown.
  int? get totalCents {
    switch (priceKind) {
      case PriceKind.complimentary:
        return 0;
      case PriceKind.unknown:
        return null;
      case PriceKind.informed:
        final c = priceCents;
        if (c == null) return null;
        return basis == PriceBasis.unit ? c * quantity : c;
    }
  }
}

/// Field key -> problem. Empty = valid. Messages are keys (not text) so the
/// widget picks the localized words.
enum OrderProblem {
  nameMissing,
  nobodyConsumed,
  nobodyPays,
  priceMissing,
  unitsMismatch,
  payersSum,
}

/// What the builder produced.
class OrderResult {
  const OrderResult({this.entries = const [], this.extra});

  final List<DrinkEntry> entries;
  final TabExtra? extra;
}

class OrderBuilder {
  const OrderBuilder._();

  static const maxQuantity = 99;

  static Set<OrderProblem> problems(OrderInput i) {
    final out = <OrderProblem>{};
    if (i.name.trim().isEmpty) out.add(OrderProblem.nameMissing);
    if (i.consumers.isEmpty) out.add(OrderProblem.nobodyConsumed);
    if (i.payers.isEmpty) out.add(OrderProblem.nobodyPays);
    final u = i.units;
    if (u != null && u.values.fold(0, (a, b) => a + b) != i.quantity) {
      out.add(OrderProblem.unitsMismatch);
    }
    if (i.priceKind == PriceKind.informed && i.priceCents == null) {
      out.add(OrderProblem.priceMissing);
    }
    final typed = i.payerCents;
    if (i.isCustomPayers) {
      var sum = 0;
      for (final id in i.payers) {
        sum += typed![id] ?? 0;
      }
      final total = i.totalCents;
      // Without a known total there is nothing to add up to: the typed
      // amounts are kept as proportions.
      if (total != null && i.priceKind == PriceKind.informed && sum != total) {
        out.add(OrderProblem.payersSum);
      }
    }
    return out;
  }

  /// What each payer bears of the whole order, in cents (null = price not
  /// known yet). Whole cents, adding up to the total.
  static Map<String, int>? payerAmounts(OrderInput i) {
    final total = i.totalCents;
    if (total == null || i.payers.isEmpty) return null;
    if (i.isCustomPayers) {
      return {for (final id in i.payers) id: i.payerCents![id] ?? 0};
    }
    final parts = TabCalculator.allocate(
      total,
      List<int>.filled(i.payers.length, 1),
    );
    return {for (var k = 0; k < i.payers.length; k++) i.payers[k]: parts[k]};
  }

  static String? _consumerOf(String id, String ownerId) =>
      id == ownerId ? null : id;

  static String _key(String id, String ownerId) =>
      id == ownerId ? ownerPortionKey : id;

  /// The records or the extra of the order. Throws [ArgumentError] if it has
  /// problems, so a half-valid order never reaches the store.
  static OrderResult build(OrderInput i, {required String Function() newId}) {
    final p = problems(i);
    if (p.isNotEmpty) throw ArgumentError('invalid order: $p');
    return i.kind.isDrink
        ? OrderResult(entries: _drinks(i, newId))
        : OrderResult(extra: _extra(i, newId));
  }

  static List<int?> _unitPrices(OrderInput i) {
    final n = i.quantity;
    switch (i.priceKind) {
      case PriceKind.unknown:
        return List<int?>.filled(n, null);
      case PriceKind.complimentary:
        return List<int?>.filled(n, 0);
      case PriceKind.informed:
        final cents = i.priceCents!;
        if (i.basis == PriceBasis.unit) return List<int?>.filled(n, cents);
        return TabCalculator.allocate(
          cents,
          List<int>.filled(n, 1),
        ).cast<int?>();
    }
  }

  /// Weights of the cost split of each unit. Equal = 1 each. Typed amounts
  /// are cut unit by unit from what each payer still owes, so the units add
  /// up to exactly what each payer typed (no stray cent).
  static List<Map<String, int>> _payerWeights(
    OrderInput i,
    List<int?> prices,
    String Function(String) keyOf,
  ) {
    if (!i.isCustomPayers) {
      return List.generate(
        prices.length,
        (_) => {for (final id in i.payers) keyOf(id): 1},
      );
    }
    final left = {for (final id in i.payers) id: i.payerCents![id] ?? 0};
    final out = <Map<String, int>>[];
    for (final price in prices) {
      final typed = {for (final e in left.entries) e.key: e.value};
      if (price == null || price <= 0 || i.priceKind != PriceKind.informed) {
        out.add({
          for (final e in typed.entries)
            if (e.value > 0) keyOf(e.key): e.value,
        });
        continue;
      }
      final ids = typed.keys.toList();
      final parts = TabCalculator.allocate(price, [
        for (final id in ids) typed[id]!,
      ]);
      final unit = <String, int>{};
      for (var k = 0; k < ids.length; k++) {
        left[ids[k]] = left[ids[k]]! - parts[k];
        if (parts[k] > 0) unit[keyOf(ids[k])] = parts[k];
      }
      out.add(unit);
    }
    return out;
  }

  static DrinkCategory _categoryOf(OrderInput i) =>
      i.category ??
      (i.kind == OrderKind.soft
          ? DrinkCategory.nonAlcoholic
          : DrinkCategory.cocktail);

  /// The record the order was opened from still describes the drink: always,
  /// except when another product was picked.
  static DrinkEntry? _kept(OrderInput i) =>
      i.replaceProduct ? null : i.template;

  static List<DrinkEntry> _drinks(OrderInput i, String Function() newId) {
    final prices = _unitPrices(i);
    final weights = _payerWeights(i, prices, (id) => _key(id, i.ownerId));
    final t = _kept(i);
    final category = t?.category ?? _categoryOf(i);
    // A drink that was alcoholic by kind stays so; "without alcohol" must not
    // keep a category that may contain alcohol.
    final kindCategory = i.kind == OrderKind.soft && category.canBeAlcoholic
        ? DrinkCategory.nonAlcoholic
        : (i.kind == OrderKind.alcoholic && !category.canBeAlcoholic
              ? DrinkCategory.cocktail
              : category);

    // Who each unit is for: one person, or everybody of a shared unit.
    final owners = <List<String>>[];
    if (i.consumers.length == 1) {
      owners.addAll(List.generate(i.quantity, (_) => [i.consumers.first]));
    } else if (i.units != null) {
      for (final id in i.consumers) {
        for (var k = 0; k < (i.units![id] ?? 0); k++) {
          owners.add([id]);
        }
      }
    } else {
      owners.addAll(List.generate(i.quantity, (_) => [...i.consumers]));
    }

    final out = <DrinkEntry>[];
    for (var n = 0; n < owners.length; n++) {
      final old = n < i.existing.length ? i.existing[n] : null;
      final first = n == 0;
      final at =
          (first ? i.fixedAt : null) ??
          old?.consumedAt ??
          i.at.add(Duration(milliseconds: n));
      final who = owners[n];
      final price = prices[n];
      final shared = who.length > 1;
      final w = weights[n];
      int? ownerShare;
      if (shared && price != null) {
        final order = w.keys.toList();
        final parts = TabCalculator.allocate(price, [
          for (final k in order) w[k]!,
        ]);
        final k = order.indexOf(ownerPortionKey);
        ownerShare = k < 0 ? 0 : parts[k];
      }
      out.add(
        DrinkEntry(
          id: (first ? i.fixedId : null) ?? old?.id ?? newId(),
          outingId: i.outingId,
          consumedAt: at,
          name: i.name.trim(),
          category: kindCategory,
          createdAt: old?.createdAt ?? at,
          updatedAt: DateTime.now().isAfter(at) ? DateTime.now() : at,
          brand: t?.brand ?? i.brand,
          style: t?.style ?? i.style,
          presentation: t?.presentation ?? i.presentation,
          catalogItemId: t?.catalogItemId ?? i.catalogItemId,
          abvPercent: t?.abvPercent,
          abvSource: t?.abvSource,
          ingredients: t?.ingredients,
          composition: t?.composition,
          containerMl: t?.containerMl ?? i.containerMl,
          isShared: shared,
          peopleCount: who.length,
          personalMl: shared ? null : (t?.containerMl ?? i.containerMl),
          priceKind: i.priceKind,
          paidCents: shared
              ? switch (i.priceKind) {
                  PriceKind.informed => ownerShare ?? 0,
                  PriceKind.complimentary => 0,
                  PriceKind.unknown => null,
                }
              : price,
          billTotalCents: shared && i.priceKind == PriceKind.informed
              ? price
              : null,
          consumerId: shared ? null : _consumerOf(who.first, i.ownerId),
          portions: shared
              ? {for (final id in who) _key(id, i.ownerId): null}
              : null,
          payers: w.isEmpty ? null : w,
          entryOrigin: (first ? i.origin : null) ?? old?.entryOrigin,
        ),
      );
    }
    return out;
  }

  static TabExtra _extra(OrderInput i, String Function() newId) {
    // The line is one: the payers' weights are the typed amounts, or equal.
    final weights = i.isCustomPayers
        ? {
            for (final id in i.payers)
              if ((i.payerCents![id] ?? 0) > 0) id: i.payerCents![id]!,
          }
        : {for (final id in i.payers) id: 1};
    final category = i.kind == OrderKind.food
        ? ExtraCategory.food
        : (i.existingExtra?.category ?? ExtraCategory.other);
    final old = i.existingExtra;
    return TabExtra(
      id: old?.id ?? newId(),
      description: i.name.trim(),
      category: category,
      createdAt: old?.createdAt ?? i.at,
      quantity: i.quantity,
      priceKind: i.priceKind,
      basis: i.basis,
      cents: i.priceKind == PriceKind.informed ? i.priceCents : null,
      service: old?.service ?? category.defaultService,
      assign: weights.isEmpty ? null : weights,
      consumers: [...i.consumers],
    );
  }
}
