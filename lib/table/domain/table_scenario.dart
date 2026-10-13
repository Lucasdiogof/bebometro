import 'package:flutter/material.dart';

import '../../outings/domain/outing.dart';

/// Visual setting of the outing table. Purely decorative: it never changes the
/// outing's place, type or records.
enum TableScenario {
  bar('bar', 'Bar/boteco', Icons.sports_bar_rounded),
  club('club', 'Balada', Icons.nightlife_rounded),
  barbecue('barbecue', 'Churrasco', Icons.outdoor_grill_rounded),
  home('home', 'Casa', Icons.home_rounded),
  beach('beach', 'Praia', Icons.beach_access_rounded),
  restaurant('restaurant', 'Restaurante', Icons.restaurant_rounded);

  const TableScenario(this.code, this.label, this.icon);

  final String code;
  final String label;
  final IconData icon;

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
