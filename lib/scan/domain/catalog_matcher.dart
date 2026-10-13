import '../../core/utils/formatters.dart';
import '../../drinks/domain/catalog_item.dart';
import '../../drinks/domain/drink_category.dart';
import '../../l10n/l10n.dart';

/// What was read or typed, to be compared with the catalog.
class MatchQuery {
  const MatchQuery({
    required this.name,
    this.brand,
    this.volumeMl,
    this.abvPercent,
    this.category,
    this.ingredients = const [],
  });

  final String name;
  final String? brand;
  final int? volumeMl;
  final double? abvPercent;
  final DrinkCategory? category;

  /// Ingredients named by the source; they only help to rank recipes.
  final List<String> ingredients;
}

/// One thing that is the same or differs between the query and a product.
class MatchNote {
  const MatchNote(this.text, {this.difference = false});

  final String text;

  /// True when the product differs from what the user has: shown in warning
  /// style so a similar name is never taken for the same product.
  final bool difference;
}

/// A catalog product that looks like the query. Similarity is only used to
/// order the list; it is never shown as a percentage and never links by
/// itself.
class CatalogMatch {
  const CatalogMatch(this.item, this.notes, this.rank);

  final CatalogItem item;
  final List<MatchNote> notes;
  final double rank;
}

List<String> _tokens(String text) => normalizeText(text)
    .split(RegExp(r'[^a-z0-9]+'))
    .where((t) => t.length >= 3)
    .toList();

/// Up to [limit] products that share words with the query, best first.
List<CatalogMatch> matchCatalog(
  List<CatalogItem> catalog,
  MatchQuery query, {
  int limit = 5,
}) {
  final tokens = _tokens('${query.brand ?? ''} ${query.name}').toSet();
  if (tokens.isEmpty) return const [];
  final matches = <CatalogMatch>[];
  for (final item in catalog) {
    final text = item.searchText;
    final hit = tokens.where(text.contains).length;
    if (hit == 0) continue;
    var rank = hit / tokens.length;
    if (rank < 0.5) continue;
    final brand = query.brand;
    if (brand != null &&
        item.brand != null &&
        normalizeText(brand) == normalizeText(item.brand!)) {
      rank += 0.25;
    }
    final recipe = item.recipe;
    if (recipe != null && query.ingredients.isNotEmpty) {
      final names = recipe.components.map((c) => normalizeText(c.name)).toList();
      var shared = 0;
      for (final ing in query.ingredients) {
        final n = normalizeText(ing);
        if (n.length >= 3 && names.any((r) => r.contains(n) || n.contains(r))) {
          shared++;
        }
      }
      rank += (shared * 0.1).clamp(0.0, 0.3).toDouble();
    }
    if (query.category != null && query.category == item.category) {
      rank += 0.1;
    }
    matches.add(CatalogMatch(item, _notesFor(item, query), rank));
  }
  matches.sort((a, b) => b.rank.compareTo(a.rank));
  return matches.take(limit).toList();
}

List<MatchNote> _notesFor(CatalogItem item, MatchQuery q) {
  final notes = <MatchNote>[];
  if (q.category != null && q.category != item.category) {
    notes.add(MatchNote(tr.matchOtherCategory(item.category.label),
        difference: true));
  }
  final volume = q.volumeMl;
  final documented = item.documentedPresentations;
  if (volume != null && documented.isNotEmpty) {
    if (documented.any((p) => p.volumeMl == volume)) {
      notes.add(MatchNote(tr.matchSameSize(formatMl(volume))));
    } else {
      notes.add(MatchNote(
          tr.matchOtherSize(
              documented.map((p) => formatMl(p.volumeMl)).join(', ')),
          difference: true));
    }
  }
  final abv = q.abvPercent;
  if (abv != null) {
    if (item.abvPercent != null) {
      if ((item.abvPercent! - abv).abs() < 0.05) {
        notes.add(MatchNote(tr.matchSameAbv(formatAbv(abv))));
      } else {
        notes.add(MatchNote(
            tr.matchOtherAbv(formatAbv(item.abvPercent!), formatAbv(abv)),
            difference: true));
      }
    } else if (item.abvVariants.isNotEmpty) {
      notes.add(MatchNote(tr.matchAbvVaries, difference: true));
    } else {
      notes.add(MatchNote(tr.matchNoAbv));
    }
  }
  final brand = q.brand;
  if (brand != null &&
      item.brand != null &&
      normalizeText(brand) != normalizeText(item.brand!)) {
    notes.add(MatchNote(tr.matchOtherBrand(item.brand!), difference: true));
  }
  if (item.isRecipe) {
    notes.add(MatchNote(tr.matchRecipe, difference: true));
  }
  notes.add(MatchNote(tr.matchSimilar, difference: true));
  return notes;
}
