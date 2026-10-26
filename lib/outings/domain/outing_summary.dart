import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../l10n/l10n.dart';
import '../../drinks/domain/presentation_label.dart';

/// Entries that are the same order (name, size and sharing), shown as "3×".
class DrinkGroup {
  const DrinkGroup({
    required this.name,
    required this.count,
    required this.shared,
    required this.detail,
  });

  final String name;
  final int count;

  /// The records of the group are shared orders.
  final bool shared;
  final String detail;
}

/// What the person did at the outing: orders, shared orders and the cost
/// attributed to them. No volume, ABV or alcohol is counted here.
class OutingSummary {
  const OutingSummary({
    required this.entryCount,
    required this.sharedCount,
    required this.informedCents,
    required this.pricedCount,
    required this.unpricedCount,
    required this.groups,
    required this.alcoholicCount,
  });

  /// Summary of the given (non-deleted) entries. By default it is the owner's
  /// own view: the orders the owner took part in ([DrinkEntry.isMine]) and the
  /// cost the owner bears, whoever drank it ([DrinkEntry.ownerCostCents]). A
  /// guest's drink paid by somebody else never inflates it. Pass
  /// `mineOnly: false` for the whole table (what each order costs the table).
  factory OutingSummary.of(List<DrinkEntry> all, {bool mineOnly = true}) {
    // Orders that count: the ones the owner took part in, or pays for.
    final entries = mineOnly
        ? [
            for (final e in all)
              if (e.isMine || (e.payers?.containsKey(ownerPortionKey) ?? false))
                e,
          ]
        : all;
    var shared = 0;
    var informed = 0;
    var priced = 0;
    var unpriced = 0;
    var alcoholic = 0;
    final groups = <String, _GroupAcc>{};

    for (final e in entries) {
      if (mineOnly ? e.isMine : true) {
        if (e.isShared) shared++;
        if (e.isAlcoholic) alcoholic++;
      }
      if (e.hasPrice) {
        priced++;
        informed += mineOnly
            ? (e.ownerCostCents ?? 0)
            : (e.totalCostCents ?? 0);
      } else {
        unpriced++;
      }
      if (mineOnly && !e.isMine) continue;
      final key = '${e.name}|${e.presentation}|${e.isShared}';
      groups.putIfAbsent(key, () => _GroupAcc(e)).count++;
    }

    return OutingSummary(
      entryCount: mineOnly
          ? entries.where((e) => e.isMine).length
          : entries.length,
      sharedCount: shared,
      informedCents: informed,
      pricedCount: priced,
      unpricedCount: unpriced,
      groups: groups.values.map((g) => g.build()).toList()
        ..sort((a, b) => b.count.compareTo(a.count)),
      alcoholicCount: alcoholic,
    );
  }

  /// Orders (records) the person took part in.
  final int entryCount;

  /// Of those, the shared ones (the person has no unit of their own there).
  final int sharedCount;

  /// Records the person had by themselves.
  int get individualCount => entryCount - sharedCount;

  /// Cost attributed to the person (what they bear), in cents.
  final int informedCents;
  final int pricedCount;
  final int unpricedCount;
  final List<DrinkGroup> groups;

  /// Orders with alcohol (only a count, for the table scenery).
  final int alcoholicCount;

  /// E.g. "R$ 90,00 informados · 2 bebidas sem preço".
  String get financeLine {
    if (entryCount == 0 && pricedCount == 0) return tr.financeNoRecords;
    final unpricedText = unpricedCount == 0
        ? null
        : tr.financeUnpriced(unpricedCount);
    final informedText = pricedCount == 0
        ? tr.financeNoValue
        : tr.financeInformed(formatCents(informedCents));
    return [informedText, ?unpricedText].join(' · ');
  }
}

class _GroupAcc {
  _GroupAcc(this.sample);

  final DrinkEntry sample;
  int count = 0;

  DrinkGroup build() {
    final parts = <String>[
      if (sample.presentation != null)
        localizePresentation(sample.presentation!),
      if (sample.isShared) tr.tabShared,
    ];
    return DrinkGroup(
      name: sample.name,
      count: count,
      shared: sample.isShared,
      detail: parts.join(' · '),
    );
  }
}
