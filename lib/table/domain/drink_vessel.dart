import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../l10n/l10n.dart';

/// The container drawn for a record. It is chosen from the data that exists
/// (the presentation label and the category). When the presentation is
/// unknown a generic vessel coherent with the category is used, never a
/// specific package.
enum VesselKind {
  can,
  longNeck,
  bottle,
  beerGlass,
  draftMug,
  shot,
  wineGlass,
  cocktailGlass,
  waterGlass,
  genericGlass;

  String get label => switch (this) {
        VesselKind.can => tr.vesselCan,
        VesselKind.longNeck => tr.vesselLongNeck,
        VesselKind.bottle => tr.vesselBottle,
        VesselKind.beerGlass => tr.vesselBeerGlass,
        VesselKind.draftMug => tr.vesselDraftMug,
        VesselKind.shot => tr.vesselShot,
        VesselKind.wineGlass => tr.vesselWineGlass,
        VesselKind.cocktailGlass => tr.vesselCocktailGlass,
        VesselKind.waterGlass => tr.vesselWaterGlass,
        VesselKind.genericGlass => tr.vesselGlass,
      };

  /// How long the purely decorative "emptying" takes. It is an illustration
  /// of the registered drink, not an estimate of how fast anyone drinks.
  Duration get emptyingTime {
    switch (this) {
      case VesselKind.shot:
        return const Duration(minutes: 4);
      case VesselKind.can:
      case VesselKind.longNeck:
        return const Duration(minutes: 30);
      case VesselKind.bottle:
        return const Duration(minutes: 40);
      default:
        return const Duration(minutes: 20);
    }
  }
}

VesselKind vesselKindFor(DrinkEntry e) {
  final label = (e.presentation ?? '').toLowerCase();
  if (label.startsWith('lata')) return VesselKind.can;
  if (label.startsWith('long neck')) return VesselKind.longNeck;
  if (label.startsWith('garrafa')) return VesselKind.bottle;
  if (label.startsWith('dose')) return VesselKind.shot;
  if (label.startsWith('taça')) return VesselKind.wineGlass;
  if (e.isMixed) return VesselKind.cocktailGlass;
  switch (e.category) {
    case DrinkCategory.beer:
      return VesselKind.beerGlass;
    case DrinkCategory.draft:
      return VesselKind.draftMug;
    case DrinkCategory.cocktail:
      return VesselKind.cocktailGlass;
    case DrinkCategory.spirit:
      return VesselKind.shot;
    case DrinkCategory.wine:
      return VesselKind.wineGlass;
    case DrinkCategory.water:
      return VesselKind.waterGlass;
    case DrinkCategory.nonAlcoholic:
      return VesselKind.genericGlass;
  }
}

Color liquidColorFor(DrinkEntry e) {
  switch (e.category) {
    case DrinkCategory.beer:
      return const Color(0xFFE8A317);
    case DrinkCategory.draft:
      return const Color(0xFFF2B53C);
    case DrinkCategory.cocktail:
      return const Color(0xFFE86A4B);
    case DrinkCategory.spirit:
      return const Color(0xFFB5651D);
    case DrinkCategory.wine:
      return const Color(0xFF7A1F2B);
    case DrinkCategory.water:
      return const Color(0xFF8FD3F0);
    case DrinkCategory.nonAlcoholic:
      return const Color(0xFF6FC2AE);
  }
}

/// Whether the vessel shows a foam head.
bool hasFoam(DrinkEntry e, VesselKind kind) =>
    (e.category == DrinkCategory.beer || e.category == DrinkCategory.draft) &&
    (kind == VesselKind.beerGlass || kind == VesselKind.draftMug);

/// Visual fill level (1 = full, 0 = empty) of a record's vessel at [now].
///
/// It is derived only from the time elapsed since the record's own time, so
/// it needs no background timer, survives restarts, and a record entered
/// retroactively is simply further along instead of starting again. It never
/// reads or changes volume, alcohol, price or any other record state.
///
/// A shared bottle only empties by the user's own portion; the rest stays,
/// because the picture must not suggest that the whole content was counted.
double vesselFill(DrinkEntry e, VesselKind kind, DateTime now) {
  final total = kind.emptyingTime.inSeconds;
  final elapsed = now.difference(e.consumedAt).inSeconds;
  final p = (elapsed / total).clamp(0.0, 1.0).toDouble();
  return 1 - p * (1 - _restingFill(e));
}

/// Level the vessel settles at once the animation is complete.
double _restingFill(DrinkEntry e) {
  final personal = e.personalMl;
  final container = e.containerMl;
  if (e.isShared && personal != null && container != null && container > 0) {
    return (1 - personal / container).clamp(0.0, 1.0).toDouble();
  }
  return 0;
}

/// Spoken description of a vessel (for screen readers and tooltips).
String vesselSemantics(DrinkEntry e, VesselKind kind, {int count = 1}) {
  final parts = <String>[
    count > 1 ? tr.tableSemanticsMany('$count', e.name) : e.name,
    kind.label,
    if (count == 1) formatTime(e.consumedAt),
    if (count == 1 && e.personalMl != null) formatMl(e.personalMl!),
    if (count == 1 && e.isShared && e.personalMl != null)
      tr.tableSemanticsSharedPart,
    if (count == 1 && e.priceKind == PriceKind.informed && e.paidCents != null)
      formatCents(e.paidCents!),
  ];
  return '${parts.join(', ')}. ${tr.tableSemanticsTap}';
}
