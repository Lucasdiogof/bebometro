import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';

// Every format follows the language on screen ([trLocaleTag]); none of them
// changes stored values. Money is always Brazilian reais (BRL), in cents: a
// different language never converts or relabels the currency.

String formatCents(int cents) => NumberFormat.currency(
      locale: trLocaleTag,
      name: 'BRL',
      symbol: r'R$',
      decimalDigits: 2,
    ).format(cents / 100).replaceAll(' ', ' ');

String formatNumber(num value) =>
    NumberFormat.decimalPattern(trLocaleTag).format(value);

String formatMl(int ml) => tr.unitMl(formatNumber(ml));

String formatGrams(double grams) =>
    tr.unitGrams(NumberFormat('#,##0.#', trLocaleTag).format(grams));

String formatAbv(double abv) =>
    '${NumberFormat('#,##0.0#', trLocaleTag).format(abv)}%';

String formatPercent(double fraction) =>
    NumberFormat.percentPattern(trLocaleTag).format(fraction);

String formatDuration(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours == 0) return tr.durationMinutes(minutes);
  if (minutes == 0) return tr.durationHours(hours);
  return tr.durationHoursMinutes(hours, minutes.toString().padLeft(2, '0'));
}

String formatTime(DateTime dt) => DateFormat.Hm(trLocaleTag).format(dt);

/// "13 de out.", "Oct 13", "13 oct".
String formatDate(DateTime dt) => DateFormat.MMMd(trLocaleTag).format(dt);

String formatMonthYear(DateTime dt) =>
    _capitalized(DateFormat.yMMMM(trLocaleTag).format(dt));

String formatDateTime(DateTime dt) => tr.dateAtTime(
    DateFormat.Md(trLocaleTag).format(dt), DateFormat.Hm(trLocaleTag).format(dt));

String formatWeekdayDate(DateTime dt) =>
    _capitalized(DateFormat.MMMMEEEEd(trLocaleTag).format(dt));

String _capitalized(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

// ---------------------------------------------------------------- parsing
//
// One parser for every numeric field. Accepted: digits with ONE decimal mark,
// comma or dot ("15", "15,5", "15.50"), optionally with thousands groups when
// both marks appear ("1.500,00", "1,500.00"). A lone mark followed by exactly
// three digits ("1.500", "1,500") is ambiguous (thousand or decimal?) and is
// refused, so the field asks for a correction instead of guessing.

/// Why a numeric text was refused.
enum NumberInputProblem { invalid, ambiguous }

class _Parsed {
  const _Parsed(this.value, this.problem);
  final double? value;
  final NumberInputProblem? problem;
}

_Parsed _parse(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^0-9,.]'), '');
  if (cleaned.isEmpty) return const _Parsed(null, NumberInputProblem.invalid);
  final lastComma = cleaned.lastIndexOf(',');
  final lastDot = cleaned.lastIndexOf('.');
  String text;
  if (lastComma >= 0 && lastDot >= 0) {
    final decimal = lastComma > lastDot ? ',' : '.';
    final group = decimal == ',' ? '.' : ',';
    final cut = cleaned.lastIndexOf(decimal);
    final intPart = cleaned.substring(0, cut);
    if (intPart.contains(decimal) ||
        !RegExp(r'^\d{1,3}(' + RegExp.escape(group) + r'\d{3})*$').hasMatch(intPart)) {
      return const _Parsed(null, NumberInputProblem.invalid);
    }
    text = '${intPart.replaceAll(group, '')}.${cleaned.substring(cut + 1)}';
  } else if (lastComma >= 0 || lastDot >= 0) {
    final mark = lastComma >= 0 ? ',' : '.';
    final parts = cleaned.split(mark);
    if (parts.length > 2) {
      // "1.500.000": only valid as thousands groups.
      if (!RegExp(r'^\d{1,3}(' + RegExp.escape(mark) + r'\d{3})+$').hasMatch(cleaned)) {
        return const _Parsed(null, NumberInputProblem.invalid);
      }
      text = parts.join();
    } else if (parts[1].length == 3 && parts[0].isNotEmpty) {
      return const _Parsed(null, NumberInputProblem.ambiguous);
    } else {
      text = '${parts[0].isEmpty ? '0' : parts[0]}.${parts[1]}';
    }
  } else {
    text = cleaned;
  }
  final v = double.tryParse(text);
  return v == null
      ? const _Parsed(null, NumberInputProblem.invalid)
      : _Parsed(v, null);
}

/// Cents from "15", "15,5", "15.50" or "R\$ 15,00". Null when empty, invalid
/// or ambiguous (see [numberInputError]).
int? parseCents(String input) {
  final p = _parse(input);
  return p.value == null ? null : (p.value! * 100).round();
}

int? parseInteger(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) return null;
  return int.tryParse(cleaned);
}

double? parseDecimal(String input) => _parse(input).value;

/// Localized error for a non-empty numeric field, or null when it is fine.
String? numberInputError(String input) {
  if (input.trim().isEmpty) return null;
  return switch (_parse(input).problem) {
    NumberInputProblem.ambiguous => tr.numberAmbiguous,
    NumberInputProblem.invalid => tr.numberInvalid,
    null => null,
  };
}

String get _decimalMark =>
    NumberFormat.decimalPattern(trLocaleTag).symbols.DECIMAL_SEP;

/// Prefills a money field in the format of the language on screen.
String centsToInput(int cents) {
  final reais = cents ~/ 100;
  final rest = cents % 100;
  return rest == 0
      ? '$reais'
      : '$reais$_decimalMark${rest.toString().padLeft(2, '0')}';
}

String decimalToInput(double value) {
  final text = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
  return text.replaceAll('.', _decimalMark);
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
