import '../../tab/domain/tab_calc.dart';
import 'drink_entry.dart';

/// What happens to the volume a removed person drank. Never silent: the person
/// editing the bottle picks one.
enum VolumeFate { toLeftover, toPerson }

/// What happens to the cost share of a removed person.
enum MoneyFate { spreadOnOthers, toPerson }

/// Who takes part in an already registered shared bottle and how.
///
/// Volume (ml drunk) and money (share of the bill) are kept apart: adding or
/// removing someone changes one without redistributing the other. Keys are
/// portion keys ([ownerPortionKey] for the owner, a participant id otherwise).
class BottlePeople {
  const BottlePeople({
    required this.portions,
    required this.weights,
    this.leftoverMl = 0,
  });

  /// Key -> ml drunk (null = unknown, never zero). Insertion order is kept.
  final Map<String, int?> portions;

  /// Key -> weight of the cost split (0 or absent = pays nothing of it).
  final Map<String, int> weights;
  final int leftoverMl;

  /// A bottle may end with a single person (the others left it).
  static const minPeople = 1;

  /// Everyone of the bottle splits the cost equally (the default of a bottle
  /// that was never adjusted).
  factory BottlePeople.equal(Map<String, int?> portions, {int leftoverMl = 0}) =>
      BottlePeople(
        portions: Map.of(portions),
        weights: {for (final k in portions.keys) k: 1},
        leftoverMl: leftoverMl,
      );

  List<String> get keys => portions.keys.toList();

  bool has(String key) => portions.containsKey(key);

  int weightOf(String key) => weights[key] ?? 0;

  int get knownMl => portions.values.fold(0, (a, b) => a + (b ?? 0));

  /// The known portions plus the leftover cannot pass the bottle.
  bool isOverBottle(int? containerMl) =>
      containerMl != null && knownMl + leftoverMl > containerMl;

  bool get hasPayer => weights.entries.any((e) => has(e.key) && e.value > 0);

  BottlePeople copyWith({
    Map<String, int?>? portions,
    Map<String, int>? weights,
    int? leftoverMl,
  }) => BottlePeople(
    portions: portions ?? this.portions,
    weights: weights ?? this.weights,
    leftoverMl: leftoverMl ?? this.leftoverMl,
  );

  /// Adds someone with unknown volume and a regular share of the cost. The
  /// volume of the others is not touched.
  BottlePeople add(String key) {
    if (has(key)) return this;
    return copyWith(
      portions: {...portions, key: null},
      weights: {...weights, key: 1},
    );
  }

  /// Corrects one person's volume (null = unknown).
  BottlePeople withPortion(String key, int? ml) {
    if (!has(key)) return this;
    return copyWith(portions: {...portions, key: ml});
  }

  BottlePeople withWeight(String key, int weight) {
    if (!has(key)) return this;
    return copyWith(weights: {...weights, key: weight < 0 ? 0 : weight});
  }

  bool get canRemoveAny => portions.length > minPeople;

  /// Volume that must be settled before [key] can leave.
  int volumeToSettle(String key) => portions[key] ?? 0;

  /// Cost share that must be settled before [key] can leave.
  int weightToSettle(String key) => weightOf(key);

  bool needsResolution(String key) =>
      volumeToSettle(key) > 0 || weightToSettle(key) > 0;

  /// Removes [key]. The volume and the cost share it had must be placed on
  /// purpose: [volume]/[volumeTo] and [money]/[moneyTo]. Throws
  /// [ArgumentError] when something is left unresolved, so nothing is dropped
  /// by accident.
  BottlePeople remove(
    String key, {
    VolumeFate? volume,
    String? volumeTo,
    MoneyFate? money,
    String? moneyTo,
  }) {
    if (!has(key)) return this;
    if (!canRemoveAny) {
      throw ArgumentError('a bottle keeps at least $minPeople person');
    }
    var nextPortions = Map<String, int?>.of(portions)..remove(key);
    var nextWeights = Map<String, int>.of(weights)..remove(key);
    var nextLeftover = leftoverMl;

    final ml = volumeToSettle(key);
    if (ml > 0) {
      switch (volume) {
        case VolumeFate.toLeftover:
          nextLeftover += ml;
        case VolumeFate.toPerson:
          if (volumeTo == null || volumeTo == key || !nextPortions.containsKey(volumeTo)) {
            throw ArgumentError('volume needs another person of the bottle');
          }
          nextPortions[volumeTo] = (nextPortions[volumeTo] ?? 0) + ml;
        case null:
          throw ArgumentError('volume of the removed person is unresolved');
      }
    }

    final w = weightToSettle(key);
    if (w > 0) {
      switch (money) {
        case MoneyFate.spreadOnOthers:
          break;
        case MoneyFate.toPerson:
          if (moneyTo == null || moneyTo == key || !nextPortions.containsKey(moneyTo)) {
            throw ArgumentError('cost needs another person of the bottle');
          }
          nextWeights[moneyTo] = (nextWeights[moneyTo] ?? 0) + w;
        case null:
          throw ArgumentError('cost share of the removed person is unresolved');
      }
    }

    final next = BottlePeople(
      portions: nextPortions,
      weights: nextWeights,
      leftoverMl: nextLeftover,
    );
    if (w > 0 && !next.hasPayer) {
      throw ArgumentError('someone must keep paying for the bottle');
    }
    return next;
  }

  /// Cents of [totalCents] per key, by weight, in whole cents (sums exactly to
  /// the total while someone has a weight).
  Map<String, int> costShares(int totalCents) {
    final ks = [for (final k in keys) if (weightOf(k) > 0) k];
    final parts = TabCalculator.allocate(totalCents, [for (final k in ks) weightOf(k)]);
    return {for (var i = 0; i < ks.length; i++) ks[i]: parts[i]};
  }

  /// The weights as stored in the tab link, keyed by participant id. Null
  /// means "everyone of the bottle equally", which is what a bottle never
  /// adjusted already does.
  Map<String, int>? toLinkAssign(String? ownerId) {
    final first = portions.isEmpty ? 0 : weightOf(portions.keys.first);
    final everyoneEqual =
        first > 0 &&
        portions.keys.every((k) => weightOf(k) == first) &&
        weights.keys.every(has);
    if (everyoneEqual) return null;
    return {
      for (final k in keys)
        if (weightOf(k) > 0)
          (k == ownerPortionKey ? (ownerId ?? k) : k): weightOf(k),
    };
  }

  /// Starting point for the editor of [entry]: volumes from the record, cost
  /// weights from the tab link ([assign], keyed by participant id) or equal.
  factory BottlePeople.fromEntry(
    DrinkEntry entry, {
    Map<String, int>? assign,
    String? ownerId,
  }) {
    final portions = Map<String, int?>.of(entry.portions ?? const {});
    if (assign == null) {
      return BottlePeople.equal(portions, leftoverMl: entry.leftoverMl);
    }
    int w(String key) =>
        assign[key == ownerPortionKey ? (ownerId ?? key) : key] ?? 0;
    return BottlePeople(
      portions: portions,
      weights: {for (final k in portions.keys) k: w(k)},
      leftoverMl: entry.leftoverMl,
    );
  }
}
