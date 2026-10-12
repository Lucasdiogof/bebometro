import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_entry.dart';

/// Entries that are the same drink, size and sharing, shown as "3×".
class DrinkGroup {
  const DrinkGroup({
    required this.name,
    required this.count,
    required this.personalMl,
    required this.detail,
  });

  final String name;
  final int count;
  final int personalMl;
  final String detail;
}

class OutingSummary {
  const OutingSummary({
    required this.entryCount,
    required this.personalMl,
    required this.informedCents,
    required this.pricedCount,
    required this.unpricedCount,
    required this.groups,
    required this.alcoholicCount,
    required this.pureAlcoholGrams,
    required this.alcoholIncomplete,
  });

  /// Summary of the given (non-deleted) entries.
  factory OutingSummary.of(List<DrinkEntry> entries) {
    var personalMl = 0;
    var informed = 0;
    var priced = 0;
    var unpriced = 0;
    var alcoholic = 0;
    var incomplete = false;
    var pureMl = 0.0;
    final groups = <String, _GroupAcc>{};

    for (final e in entries) {
      personalMl += e.personalMl;
      if (e.hasPrice) {
        priced++;
        informed += e.effectivePaidCents;
      } else {
        unpriced++;
      }
      if (e.isAlcoholic) {
        alcoholic++;
        final pure = e.pureAlcoholMl;
        if (pure == null) {
          incomplete = true;
        } else {
          pureMl += pure;
        }
      }
      final key =
          '${e.name}|${e.presentation}|${e.containerMl}|${e.personalMl}|${e.isShared}';
      groups.putIfAbsent(key, () => _GroupAcc(e)).count++;
    }

    return OutingSummary(
      entryCount: entries.length,
      personalMl: personalMl,
      informedCents: informed,
      pricedCount: priced,
      unpricedCount: unpriced,
      groups: groups.values.map((g) => g.build()).toList()
        ..sort((a, b) => b.count.compareTo(a.count)),
      alcoholicCount: alcoholic,
      // Ethanol density is about 0.789 g/ml.
      pureAlcoholGrams: pureMl * 0.789,
      alcoholIncomplete: incomplete,
    );
  }

  final int entryCount;
  final int personalMl;
  final int informedCents;
  final int pricedCount;
  final int unpricedCount;
  final List<DrinkGroup> groups;
  final int alcoholicCount;
  final double pureAlcoholGrams;
  final bool alcoholIncomplete;

  /// E.g. "R$ 90,00 informados · 2 bebidas sem preço".
  String get financeLine {
    if (entryCount == 0) return 'Sem registros ainda';
    final unpricedText = unpricedCount == 0
        ? null
        : '$unpricedCount ${unpricedCount == 1 ? 'bebida sem preço' : 'bebidas sem preço'}';
    final informedText = pricedCount == 0
        ? 'Nenhum valor informado'
        : '${formatCents(informedCents)} informados';
    return [informedText, ?unpricedText].join(' · ');
  }
}

class _GroupAcc {
  _GroupAcc(this.sample);

  final DrinkEntry sample;
  int count = 0;

  DrinkGroup build() {
    final parts = <String>[
      if (sample.presentation != null) sample.presentation!,
      sample.isShared
          ? '${formatMl(sample.personalMl)} seus de ${formatMl(sample.containerMl)}'
          : formatMl(sample.containerMl),
    ];
    return DrinkGroup(
      name: sample.name,
      count: count,
      personalMl: sample.personalMl * count,
      detail: parts.join(' · '),
    );
  }
}
