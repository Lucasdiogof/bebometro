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
    required this.sharedCount,
    required this.entries,
  });

  final DrinkCategory category;
  final int count;

  /// Of [count], the shared orders (not a unit of their own).
  final int sharedCount;
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
    required this.sharedCount,
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

  /// Orders shared with others (counted once in [entries]).
  final int sharedCount;

  /// Cost attributed to the owner, whoever drank it.
  final int informedCents;
  final int pricedCount;
  final int unpricedCount;
  final List<PlaceStat> places;
  final Map<FeedbackMood, int> moods;
  final int withoutMood;

  bool get isEmpty => outings.isEmpty && entries.isEmpty;
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
  // Personal statistics: the orders the owner took part in (never a guest's
  // alone); the cost is what the owner bears, whoever drank it.
  final all = [for (final o in outings) ...entriesOf(o.id)];
  final entries = [
    for (final e in all)
      if (e.isMine) e,
  ];

  final byCategory = <DrinkCategory, List<DrinkEntry>>{};
  var shared = 0;
  var informed = 0;
  var priced = 0;
  var unpriced = 0;
  for (final e in entries) {
    byCategory.putIfAbsent(e.category, () => []).add(e);
    if (e.isShared) shared++;
  }
  for (final e in all) {
    // Records the owner neither drank nor pays do not enter the owner's numbers.
    if (!e.isMine && !(e.payers?.containsKey(ownerPortionKey) ?? false)) {
      continue;
    }
    if (e.hasPrice) {
      priced++;
      informed += e.ownerCostCents ?? 0;
    } else {
      unpriced++;
    }
  }

  CategoryStat stat(DrinkCategory c, List<DrinkEntry> list) => CategoryStat(
    category: c,
    count: list.length,
    sharedCount: list.where((e) => e.isShared).length,
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
    sharedCount: shared,
    informedCents: informed,
    pricedCount: priced,
    unpricedCount: unpriced,
    places: places,
    moods: moods,
    withoutMood: withoutMood,
  );
}
