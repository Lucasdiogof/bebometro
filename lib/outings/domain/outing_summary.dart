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

  /// Sum of the known volumes of the group; null when none is known.
  final int? personalMl;
  final String detail;
}

class OutingSummary {
  const OutingSummary({
    required this.entryCount,
    required this.personalMl,
    required this.unknownVolumeCount,
    required this.informedCents,
    required this.pricedCount,
    required this.unpricedCount,
    required this.groups,
    required this.alcoholicCount,
    required this.pureAlcoholGrams,
    required this.incompleteAlcoholCount,
  });

  /// Summary of the given (non-deleted) entries.
  factory OutingSummary.of(List<DrinkEntry> entries) {
    var personalMl = 0;
    var unknownVolume = 0;
    var informed = 0;
    var priced = 0;
    var unpriced = 0;
    var alcoholic = 0;
    var incomplete = 0;
    var pureMl = 0.0;
    final groups = <String, _GroupAcc>{};

    for (final e in entries) {
      final ml = e.personalMl;
      if (ml == null) {
        unknownVolume++;
      } else {
        personalMl += ml;
      }
      if (e.hasPrice) {
        priced++;
        informed += e.effectivePaidCents;
      } else {
        unpriced++;
      }
      final alcohol = e.alcohol;
      if (alcohol != null) {
        alcoholic++;
        pureMl += alcohol.pureMl;
        if (!alcohol.isComplete) incomplete++;
      }
      final key =
          '${e.name}|${e.presentation}|${e.containerMl}|${e.personalMl}|${e.isShared}|${e.composition?.customized}';
      groups.putIfAbsent(key, () => _GroupAcc(e)).count++;
    }

    return OutingSummary(
      entryCount: entries.length,
      personalMl: personalMl,
      unknownVolumeCount: unknownVolume,
      informedCents: informed,
      pricedCount: priced,
      unpricedCount: unpriced,
      groups: groups.values.map((g) => g.build()).toList()
        ..sort((a, b) => b.count.compareTo(a.count)),
      alcoholicCount: alcoholic,
      // Ethanol density is about 0.789 g/ml.
      pureAlcoholGrams: pureMl * 0.789,
      incompleteAlcoholCount: incomplete,
    );
  }

  final int entryCount;

  /// Sum of the volumes that are known.
  final int personalMl;

  /// Records whose volume is unknown (not counted, and not counted as zero).
  final int unknownVolumeCount;
  final int informedCents;
  final int pricedCount;
  final int unpricedCount;
  final List<DrinkGroup> groups;
  final int alcoholicCount;

  /// Pure alcohol from what could be computed.
  final double pureAlcoholGrams;

  /// Alcoholic records missing an ABV or an amount, so the total is a minimum.
  final int incompleteAlcoholCount;

  bool get alcoholIncomplete => incompleteAlcoholCount > 0;

  /// "Seu volume": the known sum, flagged when some records have no volume.
  String get volumeLabel {
    final known = formatMl(personalMl);
    if (unknownVolumeCount == 0) return known;
    return personalMl == 0
        ? 'desconhecido'
        : '$known (+$unknownVolumeCount sem volume)';
  }

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
    final personal = sample.personalMl;
    final container = sample.containerMl;
    final parts = <String>[
      if (sample.composition?.customized == true) 'receita ajustada',
      if (sample.presentation != null) sample.presentation!,
      if (personal == null)
        'volume desconhecido'
      else if (sample.isShared && container != null)
        '${formatMl(personal)} seus de ${formatMl(container)}'
      else
        formatMl(personal),
    ];
    return DrinkGroup(
      name: sample.name,
      count: count,
      personalMl: personal == null ? null : personal * count,
      detail: parts.join(' · '),
    );
  }
}
