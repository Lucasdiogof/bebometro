import 'package:intl/intl.dart';

const _locale = 'pt_BR';

final _money = NumberFormat.currency(locale: _locale, symbol: r'R$');
final _integer = NumberFormat.decimalPattern(_locale);

String formatCents(int cents) => _money.format(cents / 100).replaceAll(' ', ' ');

String formatMl(int ml) => '${_integer.format(ml)} ml';

String formatGrams(double grams) =>
    '${NumberFormat('#,##0.#', _locale).format(grams)} g';

String formatAbv(double abv) =>
    '${NumberFormat('#,##0.0#', _locale).format(abv)}%';

String formatDuration(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours == 0) return '${minutes}min';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
}

String formatTime(DateTime dt) => DateFormat.Hm(_locale).format(dt);

String formatDate(DateTime dt) => DateFormat("d 'de' MMM", _locale).format(dt);

String formatDateTime(DateTime dt) =>
    DateFormat("d/MM 'às' HH:mm", _locale).format(dt);

String formatWeekdayDate(DateTime dt) {
  final text = DateFormat("EEEE, d 'de' MMMM", _locale).format(dt);
  return text[0].toUpperCase() + text.substring(1);
}

/// Parses "15", "15,5", "15.50" or "R$ 15,00" into cents. Null when invalid.
int? parseCents(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^0-9,.]'), '');
  if (cleaned.isEmpty) return null;
  final value = _parseNumber(cleaned);
  if (value == null) return null;
  return (value * 100).round();
}

int? parseInteger(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) return null;
  return int.tryParse(cleaned);
}

double? parseDecimal(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^0-9,.]'), '');
  if (cleaned.isEmpty) return null;
  return _parseNumber(cleaned);
}

double? _parseNumber(String cleaned) {
  var text = cleaned;
  final lastComma = text.lastIndexOf(',');
  final lastDot = text.lastIndexOf('.');
  if (lastComma >= 0 && lastDot >= 0) {
    // Both present: the right-most one is the decimal separator.
    if (lastComma > lastDot) {
      text = text.replaceAll('.', '').replaceAll(',', '.');
    } else {
      text = text.replaceAll(',', '');
    }
  } else if (lastComma >= 0) {
    text = text.replaceAll(',', '.');
  }
  return double.tryParse(text);
}

String centsToInput(int cents) {
  final reais = cents ~/ 100;
  final rest = cents % 100;
  return rest == 0 ? '$reais' : '$reais,${rest.toString().padLeft(2, '0')}';
}

String decimalToInput(double value) {
  final text = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
  return text.replaceAll('.', ',');
}

const _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c',
};

/// Lower-cases and strips accents so searches match "cachaça" with "cachaca".
String normalizeText(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_accents[ch] ?? ch);
  }
  return buffer.toString().trim();
}
