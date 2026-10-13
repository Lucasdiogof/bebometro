import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_category.dart';
import 'label_parser.dart';
import 'ocr_models.dart';

/// A price found in the menu text, with the line it came from so the user can
/// check what it was attached to.
class MenuPrice {
  const MenuPrice(this.cents, this.snippet, {this.uncertain = false});

  final int cents;
  final String snippet;

  /// Written without cents or currency, or far from its item.
  final bool uncertain;

  Map<String, dynamic> toJson() =>
      {'c': cents, 's': snippet, if (uncertain) 'u': true};

  factory MenuPrice.fromJson(Map<String, dynamic> j) => MenuPrice(
        (j['c'] as num).toInt(),
        j['s'] as String? ?? '',
        uncertain: j['u'] as bool? ?? false,
      );
}

/// One menu item as read, before the user confirmed anything.
class MenuCandidate {
  const MenuCandidate({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.volumeMl,
    this.priceOptions = const [],
    this.priceCents,
    this.promo = false,
    this.ingredients = const [],
    this.snippets = const [],
    this.sourceIndex = 0,
    this.duplicate = false,
    this.discarded = false,
  });

  final String id;
  final String name;
  final String? description;
  final DrinkCategory? category;

  /// A size written in the menu; null when it does not say one.
  final int? volumeMl;

  /// Every price that may belong to this item.
  final List<MenuPrice> priceOptions;

  /// The advertised price once it is certain or the user chose it. Null while
  /// there is no price or more than one candidate.
  final int? priceCents;
  final bool promo;

  /// Ingredients the menu text names. Quantities are never inferred.
  final List<String> ingredients;
  final List<String> snippets;
  final int sourceIndex;
  final bool duplicate;
  final bool discarded;

  bool get needsPriceChoice => priceCents == null && priceOptions.isNotEmpty;

  MenuCandidate copyWith({
    String? name,
    String? Function()? description,
    DrinkCategory? Function()? category,
    int? Function()? volumeMl,
    int? Function()? priceCents,
    List<String>? ingredients,
    bool? duplicate,
    bool? discarded,
  }) =>
      MenuCandidate(
        id: id,
        name: name ?? this.name,
        description: description != null ? description() : this.description,
        category: category != null ? category() : this.category,
        volumeMl: volumeMl != null ? volumeMl() : this.volumeMl,
        priceOptions: priceOptions,
        priceCents: priceCents != null ? priceCents() : this.priceCents,
        promo: promo,
        ingredients: ingredients ?? this.ingredients,
        snippets: snippets,
        sourceIndex: sourceIndex,
        duplicate: duplicate ?? this.duplicate,
        discarded: discarded ?? this.discarded,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category?.code,
        'volume_ml': volumeMl,
        'price_options': [for (final p in priceOptions) p.toJson()],
        'price_cents': priceCents,
        'promo': promo,
        'ingredients': ingredients,
        'snippets': snippets,
        'source': sourceIndex,
        'duplicate': duplicate,
        'discarded': discarded,
      };

  factory MenuCandidate.fromJson(Map<String, dynamic> j) => MenuCandidate(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String?,
        category: j['category'] == null
            ? null
            : DrinkCategory.fromCode(j['category'] as String),
        volumeMl: (j['volume_ml'] as num?)?.toInt(),
        priceOptions: [
          for (final p in (j['price_options'] as List? ?? const []))
            MenuPrice.fromJson(Map<String, dynamic>.from(p as Map)),
        ],
        priceCents: (j['price_cents'] as num?)?.toInt(),
        promo: j['promo'] as bool? ?? false,
        ingredients: (j['ingredients'] as List?)?.cast<String>() ?? const [],
        snippets: (j['snippets'] as List?)?.cast<String>() ?? const [],
        sourceIndex: (j['source'] as num?)?.toInt() ?? 0,
        duplicate: j['duplicate'] as bool? ?? false,
        discarded: j['discarded'] as bool? ?? false,
      );
}

class MenuReading {
  const MenuReading(this.candidates, this.notes);

  final List<MenuCandidate> candidates;
  final List<String> notes;
}

class _Tok {
  const _Tok(this.start, this.end, this.cents, this.certain);

  final int start;
  final int end;
  final int cents;
  final bool certain;
}

final _priceDecimalRx =
    RegExp(r'(?:R\$\s*)?(\d{1,3}(?:\.\d{3})*|\d+)[.,](\d{2})(?![\d])');
final _priceRsIntRx = RegExp(r'R\$\s*(\d{1,4})(?![\d.,])');
final _volTokenRx = RegExp(
  r'(?<![\d.,])(\d{1,4}(?:[.,]\d{1,3})?)\s*(ml|cl|lt|l|litros?)(?![a-zA-ZÀ-ú])',
  caseSensitive: false,
);
final _promoRx = RegExp(
    r'promo|2x1|leve \d|pague|combo|happy|oferta|desconto|balde|jarra|rodada');

List<_Tok> _pricesIn(String text) {
  final out = <_Tok>[];
  for (final m in _priceDecimalRx.allMatches(text)) {
    final after = text.substring(m.end);
    if (RegExp(r'^\s*(%|ml\b|cl\b|l\b|lt\b|litro)', caseSensitive: false)
        .hasMatch(after)) {
      continue; // an ABV or a volume, not a price
    }
    final whole = m.group(1)!.replaceAll('.', '');
    final cents = int.parse(whole) * 100 + int.parse(m.group(2)!);
    out.add(_Tok(m.start, m.end, cents, true));
  }
  for (final m in _priceRsIntRx.allMatches(text)) {
    if (out.any((t) => m.start >= t.start && m.start < t.end)) continue;
    out.add(_Tok(m.start, m.end, int.parse(m.group(1)!) * 100, true));
  }
  out.sort((a, b) => a.start.compareTo(b.start));
  return out;
}

/// The line with prices, volumes and the currency sign taken out.
String _textOnly(String text, List<_Tok> prices) {
  var rest = text;
  for (final t in prices.reversed) {
    rest = rest.replaceRange(t.start, t.end, ' ');
  }
  rest = rest.replaceAll(_volTokenRx, ' ').replaceAll(r'R$', ' ');
  rest = rest.replaceAll(RegExp(r'[.·…_\-–—|:/]{2,}'), ' ');
  return rest.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _hasLetters(String t) =>
    RegExp(r'[A-Za-zÀ-ú]{2,}').hasMatch(t);

bool _looksLikeDescription(String text) {
  final t = text.trim();
  if (t.isEmpty) return false;
  if (t.contains(',') || t.startsWith('(')) return true;
  final first = t[0];
  if (first == first.toLowerCase() && first != first.toUpperCase()) return true;
  if (t.split(RegExp(r'\s+')).length >= 5) return true;
  return RegExp(r'^(com|de|e|ou|feito|servid|acompanh)\b',
          caseSensitive: false)
      .hasMatch(normalizeText(t));
}

const _spiritWords = [
  'cachaca', 'vodka', 'gin', 'rum', 'whisky', 'whiskey', 'tequila',
  'licor', 'campari', 'aperol', 'vermute', 'espumante', 'prosecco',
  'cerveja', 'vinho', 'conhaque', 'sake', 'saque', 'amaretto', 'bourbon',
];

bool _alcoholicWord(String ingredient) {
  final n = normalizeText(ingredient);
  return _spiritWords.any((w) => RegExp('\\b$w').hasMatch(n));
}

/// Ingredients the description names, as written. Needs at least two items
/// to be taken as a list; a single phrase is just a description.
List<String> ingredientsFromDescription(String? description) {
  if (description == null) return const [];
  var text = description.trim();
  text = text.replaceAll(RegExp(r'^[(\[]|[)\]]$'), '');
  text = text.replaceFirst(
      RegExp(r'^(feito|preparado|servido)?\s*com\s+', caseSensitive: false), '');
  final parts = text
      .split(RegExp(r'[,;]|\se\s|\s\+\s'))
      .map((s) => s.trim().replaceAll(RegExp(r'[.\s]+$'), ''))
      .where((s) => s.length >= 2 && s.length <= 40)
      .toList();
  return parts.length >= 2 ? parts : const [];
}

/// Whether an ingredient name suggests alcohol; the user can flip it.
bool ingredientLooksAlcoholic(String name) => _alcoholicWord(name);

class _Item {
  _Item(this.name, this.bottom, this.height);

  String name;
  String? description;
  final snippets = <String>[];
  final prices = <MenuPrice>[];
  final sizePrices = <({int volumeMl, MenuPrice price})>[];
  int? volumeMl;
  bool promo = false;
  double bottom;
  double height;
}

MenuReading parseMenu(OcrResult ocr, {int sourceIndex = 0}) {
  final lines = [
    for (final l in ocr.lines)
      if (l.text.trim().isNotEmpty) l,
  ];
  final notes = <String>[];
  final columns = _splitColumns(lines);
  if (columns.length > 1) {
    notes.add('O cardápio parece ter ${columns.length} colunas. Confira se '
        'cada preço ficou no item certo.');
  }

  final items = <_Item>[];
  var orphanPrices = 0;

  for (final column in columns) {
    _Item? current;
    var pendingPromo = false;

    void flush() {
      if (current != null) items.add(current!);
      current = null;
    }

    for (final line in column) {
      final text = line.text.trim();
      final lower = normalizeText(text);
      final prices = _pricesIn(text);
      final standaloneInt =
          prices.isEmpty && RegExp(r'^\d{1,3}$').hasMatch(text);
      final volumes = [
        for (final m in _volTokenRx.allMatches(text)) m,
      ];
      final rest = _textOnly(text, prices);
      final isPromo = _promoRx.hasMatch(lower);

      if (!_hasLetters(rest)) {
        // A line of numbers: prices, sizes or both.
        if (current == null) {
          if (prices.isNotEmpty || standaloneInt) orphanPrices++;
          continue;
        }
        final item = current!;
        item.snippets.add(text);
        if (isPromo) item.promo = true;
        final far = line.hasBox &&
            item.height > 0 &&
            (line.top - item.bottom) > item.height * 2.2;
        if (standaloneInt) {
          item.prices.add(MenuPrice(int.parse(text) * 100, text, uncertain: true));
        } else if (volumes.isNotEmpty && prices.length == volumes.length) {
          for (var i = 0; i < prices.length; i++) {
            final vm = volumesInText(volumes[i].group(0)!);
            if (vm.isEmpty) continue;
            item.sizePrices.add((
              volumeMl: vm.first,
              price: MenuPrice(prices[i].cents, text, uncertain: far),
            ));
          }
        } else {
          if (volumes.length == 1) {
            item.volumeMl = volumesInText(volumes.first.group(0)!).firstOrNull;
          }
          for (final p in prices) {
            item.prices.add(MenuPrice(p.cents, text, uncertain: far));
          }
        }
        item.bottom = line.bottom;
        continue;
      }

      // A line with words.
      if (current != null) {
        final item = current!;
        if (item.prices.isNotEmpty || item.sizePrices.isNotEmpty) {
          flush();
        } else if (!_looksLikeDescription(rest)) {
          flush();
        } else {
          item.description =
              item.description == null ? rest : '${item.description} $rest';
          item.snippets.add(text);
          if (isPromo) item.promo = true;
          for (final p in prices) {
            item.prices.add(MenuPrice(p.cents, text));
          }
          item.bottom = line.bottom;
          continue;
        }
      }
      final item = _Item(rest, line.bottom, line.height);
      item.snippets.add(text);
      item.promo = isPromo || pendingPromo;
      pendingPromo = false;
      if (volumes.length == 1) {
        item.volumeMl = volumesInText(volumes.first.group(0)!).firstOrNull;
      }
      if (volumes.length > 1 && prices.length == volumes.length) {
        for (var i = 0; i < prices.length; i++) {
          final vm = volumesInText(volumes[i].group(0)!);
          if (vm.isNotEmpty) {
            item.sizePrices
                .add((volumeMl: vm.first, price: MenuPrice(prices[i].cents, text)));
          }
        }
      } else {
        for (final p in prices) {
          item.prices.add(MenuPrice(p.cents, text));
        }
      }
      current = item;
    }
    flush();
  }

  if (orphanPrices > 0) {
    notes.add('$orphanPrices preço(s) sem item claro foram ignorados. '
        'Adicione o item manualmente se precisar.');
  }

  final candidates = <MenuCandidate>[];
  var n = 0;
  MenuCandidate build(_Item item, {int? volumeMl, List<MenuPrice>? options}) {
    final opts = options ?? item.prices;
    final certain = opts.length == 1 && !opts.first.uncertain && !item.promo;
    final ingredients = ingredientsFromDescription(item.description);
    final category = guessCategory(item.name) ??
        (ingredients.length >= 2 && ingredients.any(_alcoholicWord)
            ? DrinkCategory.cocktail
            : guessCategory(item.description ?? ''));
    return MenuCandidate(
      id: '$sourceIndex:${n++}',
      name: item.name,
      description: item.description,
      category: category,
      volumeMl: volumeMl,
      priceOptions: opts,
      priceCents: certain ? opts.first.cents : null,
      promo: item.promo,
      ingredients: ingredients,
      snippets: item.snippets,
      sourceIndex: sourceIndex,
    );
  }

  for (final item in items) {
    if (item.name.trim().length < 2) continue;
    if (item.sizePrices.isNotEmpty) {
      for (final sp in item.sizePrices) {
        candidates.add(build(item, volumeMl: sp.volumeMl, options: [sp.price]));
      }
    } else {
      candidates.add(build(item, volumeMl: item.volumeMl));
    }
  }
  if (candidates.isEmpty) {
    notes.add('Nenhum item foi identificado. Cole ou digite o texto, ou '
        'adicione os itens manualmente.');
  }
  return MenuReading(candidates, notes);
}

/// Splits lines into columns when the page clearly has two (lines well to the
/// left and well to the right, few crossing the middle). Without geometry the
/// text is a single column.
List<List<OcrLine>> _splitColumns(List<OcrLine> lines) {
  if (lines.isEmpty || !lines.every((l) => l.hasBox)) {
    return [_readingOrder(lines, false)];
  }
  final width = lines.map((l) => l.right).reduce((a, b) => a > b ? a : b);
  if (width <= 0) return [_readingOrder(lines, true)];
  final mid = width / 2;
  final left = <OcrLine>[];
  final right = <OcrLine>[];
  var crossing = 0;
  for (final l in lines) {
    if (l.left < mid * 0.9 && l.right > mid * 1.1) {
      crossing++;
    } else if (l.centerX < mid) {
      left.add(l);
    } else {
      right.add(l);
    }
  }
  final twoColumns = left.length >= 3 &&
      right.length >= 3 &&
      crossing <= lines.length * 0.25;
  if (!twoColumns) return [_readingOrder(lines, true)];
  return [_readingOrder(left, true), _readingOrder(right, true)];
}

List<OcrLine> _readingOrder(List<OcrLine> lines, bool byTop) {
  if (!byTop) return List.of(lines);
  return List.of(lines)..sort((a, b) => a.top.compareTo(b.top));
}

/// Flags candidates already present (same name, size and price) so images that
/// overlap do not create the same item twice. Nothing is removed.
List<MenuCandidate> markDuplicates(
  List<MenuCandidate> existing,
  List<MenuCandidate> incoming,
) {
  String key(MenuCandidate c) =>
      '${normalizeText(c.name)}|${c.volumeMl}|${c.priceCents}';
  final seen = {for (final c in existing) key(c)};
  final out = <MenuCandidate>[];
  for (final c in incoming) {
    final k = key(c);
    if (seen.contains(k)) {
      out.add(c.copyWith(duplicate: true, discarded: true));
    } else {
      seen.add(k);
      out.add(c);
    }
  }
  return out;
}
