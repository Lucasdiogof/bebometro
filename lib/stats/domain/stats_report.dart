import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../outings/domain/outing.dart';
import '../../l10n/l10n.dart';

/// A period of days (start inclusive, end exclusive), in local time.
class StatsRange {
  const StatsRange(this.start, this.end);

  factory StatsRange.lastDays(int days, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final end = today.add(const Duration(days: 1));
    return StatsRange(end.subtract(Duration(days: days)), end);
  }

  /// [first] and [last] are calendar days, both included.
  factory StatsRange.custom(DateTime first, DateTime last) => StatsRange(
    DateTime(first.year, first.month, first.day),
    DateTime(last.year, last.month, last.day).add(const Duration(days: 1)),
  );

  final DateTime start;
  final DateTime end;

  int get days => end.difference(start).inDays;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);

  /// The period right before this one, with the same duration.
  StatsRange get previous =>
      StatsRange(start.subtract(Duration(days: days)), start);
}

/// What was counted in one category, keeping unknown apart from zero.
class CategoryStat {
  const CategoryStat({
    required this.category,
    required this.count,
    required this.knownMl,
    required this.unknownVolumeCount,
    required this.entries,
  });

  final DrinkCategory category;
  final int count;

  /// Sum of the volumes that are known.
  final int knownMl;
  final int unknownVolumeCount;
  final List<DrinkEntry> entries;
}

class PlaceStat {
  const PlaceStat({required this.placeId, this.name, required this.visits});

  /// Null = outings without a saved place (never merged by similar names).
  final String? placeId;

  /// Name of the saved place, when it is known.
  final String? name;
  final int visits;

  /// Text shown for the place, in the language on screen.
  String get label => placeId == null
      ? tr.statsNoSavedPlace
      : (name ?? tr.statsSavedPlaceFallback);
}

/// Honest personal statistics for a period. No score, ranking or limit: only
/// what was registered, with the gaps stated.
class StatsReport {
  const StatsReport({
    required this.range,
    required this.outings,
    required this.entries,
    required this.alcoholic,
    required this.nonAlcoholic,
    required this.alcoholicMl,
    required this.nonAlcoholicMl,
    required this.unknownVolumeCount,
    required this.pureAlcoholGrams,
    required this.incompleteAlcoholCount,
    required this.informedCents,
    required this.pricedCount,
    required this.unpricedCount,
    required this.places,
    required this.moods,
    required this.withoutMood,
  });

  final StatsRange range;
  final List<Outing> outings;
  final List<DrinkEntry> entries;

  /// Per category, split in alcoholic drinks and water/non-alcoholic ones.
  final List<CategoryStat> alcoholic;
  final List<CategoryStat> nonAlcoholic;
  final int alcoholicMl;
  final int nonAlcoholicMl;
  final int unknownVolumeCount;
  final double pureAlcoholGrams;
  final int incompleteAlcoholCount;
  final int informedCents;
  final int pricedCount;
  final int unpricedCount;
  final List<PlaceStat> places;
  final Map<FeedbackMood, int> moods;
  final int withoutMood;

  bool get isEmpty => outings.isEmpty && entries.isEmpty;
  bool get alcoholIncomplete => incompleteAlcoholCount > 0;
}

/// Builds the report from finished/running outings that started in [range]
/// and their records. [placeName] gives the current name of a saved place.
StatsReport buildStats({
  required StatsRange range,
  required List<Outing> allOutings,
  required List<DrinkEntry> Function(String outingId) entriesOf,
  required String? Function(String placeId) placeName,
}) {
  final outings = [
    for (final o in allOutings)
      if (range.contains(o.startedAt)) o,
  ];
  final entries = [for (final o in outings) ...entriesOf(o.id)];

  final byCategory = <DrinkCategory, List<DrinkEntry>>{};
  var alcoholicMl = 0;
  var nonAlcoholicMl = 0;
  var unknownVolume = 0;
  var pure = 0.0;
  var incomplete = 0;
  var informed = 0;
  var priced = 0;
  var unpriced = 0;
  for (final e in entries) {
    byCategory.putIfAbsent(e.category, () => []).add(e);
    final ml = e.personalMl;
    if (ml == null) {
      unknownVolume++;
    } else if (e.isAlcoholic) {
      alcoholicMl += ml;
    } else {
      nonAlcoholicMl += ml;
    }
    final alcohol = e.alcohol;
    if (alcohol != null) {
      pure += alcohol.pureMl;
      if (!alcohol.isComplete) incomplete++;
    }
    if (e.hasPrice) {
      priced++;
      informed += e.effectivePaidCents;
    } else {
      unpriced++;
    }
  }

  CategoryStat stat(DrinkCategory c, List<DrinkEntry> list) => CategoryStat(
    category: c,
    count: list.length,
    knownMl: list.fold(0, (s, e) => s + (e.personalMl ?? 0)),
    unknownVolumeCount: list.where((e) => e.personalMl == null).length,
    entries: list,
  );

  // A category can hold both: e.g. an unknown-ABV beer counts as alcoholic,
  // a "cerveja sem álcool" is its own category.
  final alcoholic = <CategoryStat>[];
  final nonAlcoholic = <CategoryStat>[];
  for (final c in DrinkCategory.values) {
    final list = byCategory[c];
    if (list == null) continue;
    final a = [
      for (final e in list)
        if (e.isAlcoholic) e,
    ];
    final n = [
      for (final e in list)
        if (!e.isAlcoholic) e,
    ];
    if (a.isNotEmpty) alcoholic.add(stat(c, a));
    if (n.isNotEmpty) nonAlcoholic.add(stat(c, n));
  }
  alcoholic.sort((a, b) => b.count.compareTo(a.count));
  nonAlcoholic.sort((a, b) => b.count.compareTo(a.count));

  // Places: only by saved-place id.
  final visits = <String?, int>{};
  for (final o in outings) {
    visits[o.placeId] = (visits[o.placeId] ?? 0) + 1;
  }
  final places = [
    for (final e in visits.entries)
      PlaceStat(
        placeId: e.key,
        name: e.key == null ? null : placeName(e.key!),
        visits: e.value,
      ),
  ]..sort((a, b) => b.visits.compareTo(a.visits));

  final moods = <FeedbackMood, int>{};
  var withoutMood = 0;
  for (final o in outings) {
    if (o.isActive) continue;
    final m = o.feedbackMood;
    if (m == null) {
      withoutMood++;
    } else {
      moods[m] = (moods[m] ?? 0) + 1;
    }
  }

  return StatsReport(
    range: range,
    outings: outings,
    entries: entries,
    alcoholic: alcoholic,
    nonAlcoholic: nonAlcoholic,
    alcoholicMl: alcoholicMl,
    nonAlcoholicMl: nonAlcoholicMl,
    unknownVolumeCount: unknownVolume,
    pureAlcoholGrams: pure * 0.789,
    incompleteAlcoholCount: incomplete,
    informedCents: informed,
    pricedCount: priced,
    unpricedCount: unpriced,
    places: places,
    moods: moods,
    withoutMood: withoutMood,
  );
}
