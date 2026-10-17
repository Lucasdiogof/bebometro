import '../../core/utils/formatters.dart';
import '../../l10n/l10n.dart';

/// Presentation labels are saved in a canonical form (pt-BR wording and
/// number format, e.g. "Lata 350 ml", "Garrafa 1.000 ml") so the saved text,
/// the chips that compare with it and the vessel detection never depend on
/// the language. This file only translates the canonical text for display.
final _presentationText = RegExp(
  r'^(Lata|Long neck|Garrafa|Copo|Caneca|Tulipa|Taça|Dose dupla|Dose) ([\d.]+) (ml|L)$',
);
final _plainVolume = RegExp(r'^([\d.]+) ml$');

/// Shows a saved presentation label ("Lata 350 ml", "350 ml") in the
/// language on screen. Text that is not one of the known forms (a brand's own
/// name for the pack, something typed) is returned as it is.
String localizePresentation(String stored) {
  final plain = _plainVolume.firstMatch(stored);
  if (plain != null) {
    return formatMl(int.parse(plain.group(1)!.replaceAll('.', '')));
  }
  final m = _presentationText.firstMatch(stored);
  if (m == null) return stored;
  final word = switch (m.group(1)!) {
    'Lata' => tr.presCan,
    'Long neck' => tr.kindLongNeck,
    'Garrafa' => tr.presBottle,
    'Copo' => tr.presGlass,
    'Caneca' => tr.presMug,
    'Tulipa' => tr.presTulip,
    'Taça' => tr.presWineGlass,
    'Dose dupla' => tr.presDoubleShot,
    _ => tr.presShot,
  };
  final raw = m.group(2)!;
  final volume = m.group(3) == 'L'
      ? tr.unitLiters(formatNumber(double.parse(raw.replaceAll(',', '.'))))
      : formatMl(int.parse(raw.replaceAll('.', '')));
  return '$word $volume';
}
