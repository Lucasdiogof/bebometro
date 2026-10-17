import 'package:flutter/material.dart';

import '../../outings/domain/outing.dart';
import '../../l10n/l10n.dart';

/// Visual setting of the outing table. Purely decorative: it never changes the
/// outing's place, type or records.
enum TableScenario {
  bar('bar', Icons.sports_bar_rounded),
  club('club', Icons.nightlife_rounded),
  barbecue('barbecue', Icons.outdoor_grill_rounded),
  home('home', Icons.home_rounded),
  beach('beach', Icons.beach_access_rounded),
  restaurant('restaurant', Icons.restaurant_rounded);

  const TableScenario(this.code, this.icon);

  /// Stored value; never translated.
  final String code;
  final IconData icon;

  String get label => switch (this) {
    TableScenario.bar => tr.scenarioBar,
    TableScenario.club => tr.scenarioClub,
    TableScenario.barbecue => tr.scenarioBarbecue,
    TableScenario.home => tr.scenarioHome,
    TableScenario.beach => tr.scenarioBeach,
    TableScenario.restaurant => tr.scenarioRestaurant,
  };

  static TableScenario? fromCode(String? code) {
    for (final s in TableScenario.values) {
      if (s.code == code) return s;
    }
    return null;
  }

  /// The scenario suggested by the outing type.
  static TableScenario suggestedFor(OutingType type) {
    switch (type) {
      case OutingType.bar:
        return TableScenario.bar;
      case OutingType.club:
        return TableScenario.club;
      case OutingType.barbecue:
        return TableScenario.barbecue;
      case OutingType.home:
        return TableScenario.home;
      case OutingType.restaurant:
        return TableScenario.restaurant;
      case OutingType.beach:
        return TableScenario.beach;
      case OutingType.other:
        return TableScenario.bar;
    }
  }
}
