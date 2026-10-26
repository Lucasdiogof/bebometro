/// The recreational level shown by the Bafômetro. It is a toy index, not a
/// measurement of anything about the body.
///
/// Rule (the only one): `level = n / (n + 4)`, where `n` is how many
/// alcoholic individual orders the person has in that outing.
///
/// - Only orders that are the person's own count. Shared orders are never
///   added: nobody said how much each one had, so they are not whole doses.
/// - Orders without alcohol, food and extras do not count.
/// - The curve only rises with more orders and never reaches 1. There are no
///   thresholds, bands, units or limits, and nothing here is a physiological
///   formula or a clinical cut-off.
/// - Blowing (its strength or length) is only the interaction that reveals the
///   level: it never changes it.
/// - It reads records; it never changes an order, a statistic or a payment.
class PartyMeter {
  const PartyMeter._();

  /// Orders at which the meter is at half (the "n + 4" of the rule).
  static const halfAt = 4;

  /// 0 (no alcoholic order of their own) up to just below 1.
  static double level(int alcoholicOrders) {
    final n = alcoholicOrders < 0 ? 0 : alcoholicOrders;
    return n / (n + halfAt);
  }
}

/// A person who can blow: the participant id and the name to show.
class BafoPerson {
  const BafoPerson({
    required this.id,
    required this.name,
    required this.alcoholicOrders,
  });

  final String id;
  final String name;

  /// Own (not shared) orders with alcohol in the outing.
  final int alcoholicOrders;

  double get level => PartyMeter.level(alcoholicOrders);
}

/// Who the Bafômetro offers: the people of the running outing or, without
/// one, of the last outing that was not deleted.
class BafoRoster {
  const BafoRoster(this.people);

  static const empty = BafoRoster([]);

  final List<BafoPerson> people;

  bool get isEmpty => people.isEmpty;
}
