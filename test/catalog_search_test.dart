import 'dart:io';

import 'package:bebometro/core/utils/formatters.dart';
import 'package:bebometro/drinks/data/catalog_loader.dart';
import 'package:bebometro/drinks/data/catalog_source.dart';
import 'package:bebometro/drinks/domain/catalog_item.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:flutter_test/flutter_test.dart';

List<CatalogItem> _all() => [
      ...CatalogLoader.parseProducts(
          File('assets/catalog/catalog_v1.json').readAsStringSync()),
      ...CatalogLoader.parseRecipes(
          File('assets/catalog/recipes_v1.json').readAsStringSync()),
      ...CatalogSource.items,
    ];

List<CatalogItem> _search(String q) {
  final tokens = searchKey(q).split(' ').where((t) => t.isNotEmpty).toList();
  return [
    for (final i in _all())
      if (tokens.every(i.searchText.contains)) i,
  ];
}

void main() {
  test('chop, chopp and chope are the same word', () {
    expect(searchKey('Chopp Heineken'), searchKey('chope heineken'));
    expect(searchKey('CHOP heineken'), 'chop heineken');
    expect(searchKey('chopstick'), 'chopstick');
  });

  test('the whole shipped catalog parses (nothing is silently dropped)', () {
    final products = CatalogLoader.parseProducts(
        File('assets/catalog/catalog_v1.json').readAsStringSync());
    expect(products.length, 306);
    expect(products.where((p) => p.category == DrinkCategory.cocktail).length,
        91);
  });

  test('"chopp heineken" finds the served draft, and the draft form is its own item', () {
    final hits = _search('chopp heineken');
    expect(hits.any((i) => i.id == 'heineken-lager-chope'), isTrue);
    final draft = hits.firstWhere((i) => i.id == 'heineken-lager-chope');
    expect(draft.category, DrinkCategory.draft);
    // Nothing is inherited from the bottled beer.
    expect(draft.abvPercent, isNull);
    expect(draft.documentedPresentations, isEmpty);
  });

  test('"chopp brahma" keeps the can/bottle Chopp apart from the served drafts', () {
    final hits = _search('chopp brahma');
    final ids = hits.map((i) => i.id).toSet();
    expect(ids, containsAll(['brahma-claro-chope', 'brahma-black-chope', 'brahma-escuro-chope', 'brahma-chopp']));
    expect(hits.firstWhere((i) => i.id == 'brahma-chopp').category, DrinkCategory.beer);
  });

  test('Spritzgerald is its own drink with unknown composition, never Fitzgerald or Spritz', () {
    final sg = _search('spritzgerald');
    expect(sg.map((i) => i.id), ['drink-spritzgerald']);
    expect(sg.single.recipe, isNull);
    expect(sg.single.abvPercent, isNull);
    expect(sg.single.ingredients, isNull);
    final fg = _search('fitzgerald').map((i) => i.id).toList();
    expect(fg, contains('drink-fitzgerald'));
    expect(fg, isNot(contains('drink-spritzgerald')));
    expect(_search('aperol spritz').map((i) => i.id), isNot(contains('drink-spritzgerald')));
  });

  test('wine searches reach a generic item; unknown names reach no item (manual add)', () {
    expect(_search('vinho tinto').any((i) => i.id == 'generic-vinho-tinto'), isTrue);
    expect(_search('zzzxqwy'), isEmpty);
  });

  test('only sourced values were filled: no ABV or size without a source', () {
    final p = {for (final i in _all()) i.id: i};
    expect(p['amstel-ultra']!.abvPercent, 4);
    expect(p['amstel-lager']!.abvPercent, isNull);
    expect(p['lagunitas-ipa']!.abvPercent, 6.2);
    expect(p['lagunitas-american-ipa-chope']!.abvPercent, isNull);
    expect(p['colombina-romaria']!.abvPercent, 9);
    expect(p['praya-lager']!.documentedPresentations.map((x) => x.volumeMl), [330]);
    expect(p['praya-receita-classica']!.documentedPresentations.map((x) => x.volumeMl).toSet(), {355, 269, 600});
    for (final i in _all().where((i) => i.category == DrinkCategory.wine && !i.id.startsWith('generic-'))) {
      expect(i.abvPercent, isNull, reason: i.id);
    }
  });
}
