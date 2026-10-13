import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_category.dart';
import 'ocr_models.dart';
import '../../l10n/l10n.dart';

/// What could be read from a label. Every field is optional: what was not
/// found stays null (unknown), and doubts are listed in [notes] instead of
/// being resolved silently.
class LabelReading {
  const LabelReading({
    this.name,
    this.volumeMl,
    this.abvPercent,
    this.ingredients,
    this.category,
    this.nameCandidates = const [],
    this.volumeCandidates = const [],
    this.abvCandidates = const [],
    this.notes = const [],
  });

  final String? name;

  /// Volume of the package ("350 ml"), never the nutrition-table serving.
  final int? volumeMl;
  final double? abvPercent;

  /// Only what the label declares under "Ingredientes".
  final List<String>? ingredients;
  final DrinkCategory? category;

  /// Other lines that may be the name or the brand, most prominent first.
  final List<String> nameCandidates;
  final List<int> volumeCandidates;
  final List<double> abvCandidates;
  final List<String> notes;
}

final _nutritionStart = RegExp(
    r'informacao nutricional|informacoes nutricionais|valor energetico|valores diarios|% ?vd|nutrition facts|nutritional information|nutrition information|informacion nutricional|daily value');
final _ingredientsWord = RegExp(r'ingredient(?:es|s)');
final _servingWord = RegExp(r'porcao|por 100|serving|per 100|racion');
final _volumeRx = RegExp(
  r'(?<![\d.,])(\d{1,4}(?:[.,]\d{1,3})?)\s*(ml|cl|lt|l|litros?)(?![a-zA-ZÀ-ú])',
  caseSensitive: false,
);
final _abvRx = RegExp(
  r'(\d{1,2}(?:[.,]\d{1,2})?)\s*(?:%|°|º)?\s*(vol|v/v|alc|gl|g\.l|abv)',
  caseSensitive: false,
);
final _abvPercentRx = RegExp(r'(\d{1,2}(?:[.,]\d{1,2})?)\s*%');
final _noiseRx = RegExp(
  r'ingredientes|ingredients|industria|cnpj|validade|lote|fabricad|conservar|alergic|contem|sac\b|www\.|http|@|\bval\b|\bfab\b|reciclav|retorn|consumo|beba com|venda proibida|proibid|menores|dirija|gravidas|nutricional|codigo|\bean\b|\bkcal\b|contains|best before|drink responsibly|manufactured|distributed|recycl|caducidad|consumir|contiene|beba con moderacion|elaborado|fabricado',
);
final _stopIngredients = RegExp(
  r'^(contem|nao contem|informa|industria|validade|lote|conservar|alergic|fabricad|sac|cnpj|venda|beba|valores|contains|may contain|allergen|best before|manufactured|distributed|nutrition|caducidad|contiene|puede contener|elaborado|fabricado)',
);

LabelReading parseLabel(OcrResult ocr) {
  final lines = [
    for (final l in ocr.lines)
      if (l.text.trim().isNotEmpty) l,
  ];
  final notes = <String>[];

  // Everything from the nutrition table on is ignored for volume and ABV: its
  // serving size and % daily values are not the package or the alcohol.
  var cut = lines.length;
  for (var i = 0; i < lines.length; i++) {
    if (_nutritionStart.hasMatch(normalizeText(lines[i].text))) {
      cut = i;
      break;
    }
  }
  final body = lines.sublist(0, cut);

  final volumes = <int>[];
  final abvs = <double>[];
  for (final line in body) {
    final text = line.text;
    final lower = normalizeText(text);
    if (!_servingWord.hasMatch(lower)) {
      for (final m in _volumeRx.allMatches(text)) {
        final value = parseDecimal(m.group(1)!);
        if (value == null) continue;
        final unit = m.group(2)!.toLowerCase();
        final ml = unit == 'ml'
            ? value
            : unit == 'cl'
                ? value * 10
                : value * 1000;
        final rounded = ml.round();
        if (rounded >= 10 && rounded <= 20000 && !volumes.contains(rounded)) {
          volumes.add(rounded);
        }
      }
    }
    var found = false;
    for (final m in _abvRx.allMatches(text)) {
      final v = parseDecimal(m.group(1)!);
      if (v != null && v >= 0 && v <= 100) {
        found = true;
        if (!abvs.contains(v)) abvs.add(v);
      }
    }
    // A bare "4,5%" counts only on a line that talks about alcohol.
    if (!found && RegExp(r'alc|teor|abv|gradua').hasMatch(lower)) {
      for (final m in _abvPercentRx.allMatches(text)) {
        final v = parseDecimal(m.group(1)!);
        if (v != null && v >= 0 && v <= 100 && !abvs.contains(v)) abvs.add(v);
      }
    }
  }

  int? volume;
  if (volumes.length == 1) {
    volume = volumes.first;
  } else if (volumes.length > 1) {
    notes.add(tr.parseManyVolumes(volumes.map(formatMl).join(', ')));
  }
  double? abv;
  if (abvs.length == 1) {
    abv = abvs.first;
  } else if (abvs.length > 1) {
    notes.add(tr.parseManyAbvs(abvs.map(formatAbv).join(', ')));
  }

  // Declared ingredients only.
  List<String>? ingredients;
  for (var i = 0; i < lines.length; i++) {
    final lower = normalizeText(lines[i].text);
    final found = _ingredientsWord.firstMatch(lower);
    if (found == null) continue;
    final raw = lines[i].text;
    final start = found.end.clamp(0, raw.length);
    final buffer = StringBuffer(raw.substring(start));
    for (var j = i + 1; j < lines.length && j <= i + 4; j++) {
      final next = normalizeText(lines[j].text);
      if (_stopIngredients.hasMatch(next)) break;
      buffer
        ..write(' ')
        ..write(lines[j].text);
    }
    final items = buffer
        .toString()
        .replaceFirst(RegExp(r'^[\s:.\-]+'), '')
        .split(RegExp(r'[,;]|\s(?:e|and|y)\s'))
        .map((s) => s.trim().replaceAll(RegExp(r'[.\s]+$'), ''))
        .where((s) => s.length > 1 && s.length < 80)
        .toList();
    if (items.isNotEmpty) ingredients = items;
    break;
  }

  // Name candidates: prominent lines that are not volume, ABV or boilerplate.
  final candidates = <OcrLine>[];
  for (final line in body) {
    final t = line.text.trim();
    final lower = normalizeText(t);
    if (t.length < 3 || t.length > 60) continue;
    if (_noiseRx.hasMatch(lower)) continue;
    if (_volumeRx.hasMatch(t) || _abvRx.hasMatch(t)) continue;
    final letters = t.replaceAll(RegExp(r'[^A-Za-zÀ-ú]'), '').length;
    if (letters < t.replaceAll(' ', '').length * 0.6) continue;
    candidates.add(line);
  }
  if (candidates.any((l) => l.hasBox)) {
    candidates.sort((a, b) => b.height.compareTo(a.height));
  }
  final nameCandidates = <String>[];
  for (final c in candidates) {
    final t = c.text.trim();
    if (!nameCandidates.contains(t)) nameCandidates.add(t);
    if (nameCandidates.length >= 6) break;
  }

  final all = normalizeText(lines.map((l) => l.text).join(' '));
  if (nameCandidates.length > 1) {
    notes.add(tr.parseCheckName);
  }

  return LabelReading(
    name: nameCandidates.isEmpty ? null : nameCandidates.first,
    volumeMl: volume,
    abvPercent: abv,
    ingredients: ingredients,
    category: guessCategory(all),
    nameCandidates: nameCandidates,
    volumeCandidates: volumes,
    abvCandidates: abvs,
    notes: notes,
  );
}

/// Package volumes (in ml) written in [text], without repeats.
List<int> volumesInText(String text) {
  final out = <int>[];
  for (final m in _volumeRx.allMatches(text)) {
    final value = parseDecimal(m.group(1)!);
    if (value == null) continue;
    final unit = m.group(2)!.toLowerCase();
    final ml = unit == 'ml'
        ? value
        : unit == 'cl'
            ? value * 10
            : value * 1000;
    final rounded = ml.round();
    if (rounded >= 10 && rounded <= 20000 && !out.contains(rounded)) {
      out.add(rounded);
    }
  }
  return out;
}

/// A category only when the text states it; null means "not identified".
DrinkCategory? guessCategory(String text) {
  final normalized = normalizeText(text);
  bool has(String pattern) => RegExp(pattern).hasMatch(normalized);
  if (has(r'chopp|chope')) return DrinkCategory.draft;
  if (has(r'cerveja|cerveza|beer|pilsen|lager|\bipa\b|stout|weiss|witbier')) {
    return DrinkCategory.beer;
  }
  if (has(r'vinho|vino|wine|espumante|prosecco|cabernet|merlot|malbec')) {
    return DrinkCategory.wine;
  }
  if (has(r'caipirinha|caipiroska|mojito|margarita|negroni|gin tonica|drink|drinque|sour|spritz|moscow|cosmopolitan|cocktail|coctel')) {
    return DrinkCategory.cocktail;
  }
  if (has(r'vodka|\bgin\b|ginebra|whisk|\brum\b|\bron\b|cachaca|tequila|licor|liqueur|conhaque|brandy|aguardente|dose')) {
    return DrinkCategory.spirit;
  }
  if (has(r'agua mineral|agua sem gas|agua com gas|agua sin gas|mineral water|sparkling water')) return DrinkCategory.water;
  if (has(r'refrigerante|refresco|gaseosa|soda|suco|jugo|juice|guarana|energetico|sem alcool|sin alcohol|alcohol free')) {
    return DrinkCategory.nonAlcoholic;
  }
  return null;
}
