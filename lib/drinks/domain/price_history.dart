import 'drink_entry.dart';

/// What is needed to decide that two records are "the same drink in the same
/// size": product (or name), package volume, presentation and whether it was
/// shared. Customised recipes are never comparable.
class ComparableKey {
  const ComparableKey({
    required this.item,
    required this.containerMl,
    required this.presentation,
    required this.shared,
  });

  factory ComparableKey.of(DrinkEntry e) => ComparableKey(
        item: e.catalogItemId ?? 'name:${e.name}',
        containerMl: e.containerMl,
        presentation: e.presentation,
        shared: e.isShared,
      );

  final String item;
  final int? containerMl;
  final String? presentation;
  final bool shared;

  @override
  bool operator ==(Object other) =>
      other is ComparableKey &&
      other.item == item &&
      other.containerMl == containerMl &&
      other.presentation == presentation &&
      other.shared == shared;

  @override
  int get hashCode => Object.hash(item, containerMl, presentation, shared);
}

/// Only the user's own, informed prices of non-customised drinks count.
bool isPriceComparable(DrinkEntry e) =>
    e.priceKind == PriceKind.informed &&
    !(e.composition?.customized ?? false);

/// The price a record states for the whole serving: the package/bill total
/// when shared, the paid price otherwise. Null when there is none.
int? _packageCents(DrinkEntry e) => e.isShared ? e.billTotalCents : e.paidCents;

/// Last prices the user paid for the same drink, from their own history.
/// A paid share and a package total are kept apart and never swapped.
class PriceSuggestion {
  const PriceSuggestion({
    this.paidCents,
    this.paidAt,
    this.totalCents,
    this.totalAt,
  });

  /// What the user paid (the share when the drink is shared).
  final int? paidCents;
  final DateTime? paidAt;

  /// The package/bill total (shared drinks only).
  final int? totalCents;
  final DateTime? totalAt;

  bool get isEmpty => paidCents == null && totalCents == null;
}

/// Looks up the most recent comparable records among [candidates] (already
/// restricted to the same place or outing) for the given drink.
PriceSuggestion suggestPrice(List<DrinkEntry> candidates, ComparableKey key) {
  final same = [
    for (final e in candidates)
      if (isPriceComparable(e) && ComparableKey.of(e) == key) e,
  ]..sort((a, b) => b.consumedAt.compareTo(a.consumedAt));

  int? paid;
  DateTime? paidAt;
  int? total;
  DateTime? totalAt;
  for (final e in same) {
    if (paid == null && e.paidCents != null) {
      paid = e.paidCents;
      paidAt = e.consumedAt;
    }
    if (total == null && e.isShared && e.billTotalCents != null) {
      total = e.billTotalCents;
      totalAt = e.consumedAt;
    }
  }
  return PriceSuggestion(
    paidCents: paid,
    paidAt: paidAt,
    totalCents: total,
    totalAt: totalAt,
  );
}

/// "Seu histórico" at a place for one drink and size. Not a market average.
class PriceGroupStats {
  const PriceGroupStats({
    required this.label,
    required this.count,
    required this.lastCents,
    required this.lastAt,
    required this.minCents,
    required this.maxCents,
    required this.firstAt,
    required this.shared,
  });

  final String label;
  final int count;
  final int lastCents;
  final DateTime lastAt;
  final int minCents;
  final int maxCents;
  final DateTime firstAt;

  /// True when the prices are package totals of a shared drink.
  final bool shared;
}

/// Groups the user's informed prices by drink and size (never mixing sizes,
/// presentations, shared and individual, or customised recipes).
List<PriceGroupStats> priceStatsFor(List<DrinkEntry> entries) {
  final groups = <ComparableKey, List<DrinkEntry>>{};
  for (final e in entries) {
    if (!isPriceComparable(e) || _packageCents(e) == null) continue;
    groups.putIfAbsent(ComparableKey.of(e), () => []).add(e);
  }
  final result = <PriceGroupStats>[];
  for (final g in groups.values) {
    g.sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    final prices = [for (final e in g) _packageCents(e)!];
    final last = g.last;
    final size = last.presentation ??
        (last.containerMl == null ? null : '${last.containerMl} ml');
    result.add(PriceGroupStats(
      label: [last.name, ?size].join(' · '),
      count: g.length,
      lastCents: _packageCents(last)!,
      lastAt: last.consumedAt,
      minCents: prices.reduce((a, b) => a < b ? a : b),
      maxCents: prices.reduce((a, b) => a > b ? a : b),
      firstAt: g.first.consumedAt,
      shared: last.isShared,
    ));
  }
  result.sort((a, b) => b.count.compareTo(a.count));
  return result;
}
