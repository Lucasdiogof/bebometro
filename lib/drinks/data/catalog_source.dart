import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';

/// Small bundled starter catalog. Everything here is a generic reference item:
/// ABV values are typical figures, not official brand data, and unknown
/// information is left null instead of being invented.
class CatalogSource {
  const CatalogSource._();

  static const waterItemId = 'generic-agua-sem-gas';
  static const _typical = 'Teor típico do tipo de bebida. Confirme no rótulo.';

  static const items = <CatalogItem>[
    // Cerveja
    CatalogItem(
      id: 'generic-cerveja-pilsen',
      name: 'Cerveja Pilsen/Lager',
      category: DrinkCategory.beer,
      style: 'Pilsen/Lager',
      abvPercent: 4.8,
      note: _typical,
      presentations: [
        Presentation('Lata 350 ml', 350, kind: PresentationKind.can),
        Presentation('Lata 473 ml', 473, kind: PresentationKind.can),
        Presentation('Long neck 355 ml', 355, kind: PresentationKind.longNeck),
        Presentation('Garrafa 600 ml', 600, kind: PresentationKind.bottle),
      ],
    ),
    CatalogItem(
      id: 'generic-cerveja-ipa',
      name: 'Cerveja IPA',
      category: DrinkCategory.beer,
      style: 'IPA',
      abvPercent: 6.5,
      note: _typical,
      presentations: [
        Presentation('Lata 350 ml', 350, kind: PresentationKind.can),
        Presentation('Lata 473 ml', 473, kind: PresentationKind.can),
        Presentation('Garrafa 500 ml', 500, kind: PresentationKind.bottle),
      ],
    ),
    CatalogItem(
      id: 'generic-cerveja-trigo',
      name: 'Cerveja de trigo',
      category: DrinkCategory.beer,
      style: 'Weiss',
      abvPercent: 5.0,
      note: _typical,
      presentations: [
        Presentation('Long neck 355 ml', 355, kind: PresentationKind.longNeck),
        Presentation('Garrafa 500 ml', 500, kind: PresentationKind.bottle),
      ],
    ),
    // Chopp
    CatalogItem(
      id: 'generic-chopp-claro',
      name: 'Chopp claro',
      category: DrinkCategory.draft,
      style: 'Pilsen/Lager',
      abvPercent: 4.8,
      note: _typical,
      presentations: [
        Presentation('Tulipa 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Copo 400 ml', 400, kind: PresentationKind.glass),
        Presentation('Caneca 500 ml', 500, kind: PresentationKind.glass),
        Presentation('Tulipa 1 L', 1000, kind: PresentationKind.glass),
      ],
    ),
    CatalogItem(
      id: 'generic-chopp-escuro',
      name: 'Chopp escuro',
      category: DrinkCategory.draft,
      style: 'Escura',
      abvPercent: 5.0,
      note: _typical,
      presentations: [
        Presentation('Tulipa 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Copo 400 ml', 400, kind: PresentationKind.glass),
        Presentation('Caneca 500 ml', 500, kind: PresentationKind.glass),
      ],
    ),
    // Drinks (ABV unknown: depends on the recipe and the bar)
    CatalogItem(
      id: 'generic-caipirinha',
      name: 'Caipirinha',
      category: DrinkCategory.cocktail,
      ingredients: ['Cachaça', 'Limão', 'Açúcar', 'Gelo'],
      note: 'Receita comum. Teor depende do bar: informe se souber.',
      presentations: [
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Copo 400 ml', 400, kind: PresentationKind.glass),
      ],
    ),
    CatalogItem(
      id: 'generic-gin-tonica',
      name: 'Gin tônica',
      category: DrinkCategory.cocktail,
      ingredients: ['Gin', 'Água tônica', 'Gelo'],
      note: 'Receita comum. Teor depende do bar: informe se souber.',
      presentations: [
        Presentation('Taça 400 ml', 400, kind: PresentationKind.glass),
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
      ],
    ),
    CatalogItem(
      id: 'generic-drink-outro',
      name: 'Drink (genérico)',
      category: DrinkCategory.cocktail,
      note: 'Ingredientes e teor desconhecidos.',
      presentations: [
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Copo 400 ml', 400, kind: PresentationKind.glass),
      ],
    ),
    // Destilados
    CatalogItem(
      id: 'generic-cachaca',
      name: 'Cachaça',
      category: DrinkCategory.spirit,
      abvPercent: 40,
      note: _typical,
      presentations: [
        Presentation('Dose 50 ml', 50, kind: PresentationKind.shot),
        Presentation('Dose dupla 100 ml', 100, kind: PresentationKind.shot),
      ],
    ),
    CatalogItem(
      id: 'generic-vodka',
      name: 'Vodka',
      category: DrinkCategory.spirit,
      abvPercent: 40,
      note: _typical,
      presentations: [
        Presentation('Dose 50 ml', 50, kind: PresentationKind.shot),
        Presentation('Dose dupla 100 ml', 100, kind: PresentationKind.shot),
      ],
    ),
    CatalogItem(
      id: 'generic-whisky',
      name: 'Whisky',
      category: DrinkCategory.spirit,
      abvPercent: 40,
      note: _typical,
      presentations: [
        Presentation('Dose 50 ml', 50, kind: PresentationKind.shot),
        Presentation('Dose dupla 100 ml', 100, kind: PresentationKind.shot),
      ],
    ),
    CatalogItem(
      id: 'generic-gin',
      name: 'Gin',
      category: DrinkCategory.spirit,
      abvPercent: 40,
      note: _typical,
      presentations: [
        Presentation('Dose 50 ml', 50, kind: PresentationKind.shot),
        Presentation('Dose dupla 100 ml', 100, kind: PresentationKind.shot),
      ],
    ),
    // Vinho
    CatalogItem(
      id: 'generic-vinho-tinto',
      name: 'Vinho tinto',
      category: DrinkCategory.wine,
      abvPercent: 12.5,
      note: _typical,
      presentations: [
        Presentation('Taça 150 ml', 150, kind: PresentationKind.glass),
        Presentation('Taça 200 ml', 200, kind: PresentationKind.glass),
        Presentation('Garrafa 750 ml', 750, kind: PresentationKind.bottle),
      ],
    ),
    CatalogItem(
      id: 'generic-vinho-branco',
      name: 'Vinho branco',
      category: DrinkCategory.wine,
      abvPercent: 12.0,
      note: _typical,
      presentations: [
        Presentation('Taça 150 ml', 150, kind: PresentationKind.glass),
        Presentation('Taça 200 ml', 200, kind: PresentationKind.glass),
        Presentation('Garrafa 750 ml', 750, kind: PresentationKind.bottle),
      ],
    ),
    // Sem álcool
    CatalogItem(
      id: 'generic-refrigerante',
      name: 'Refrigerante',
      category: DrinkCategory.nonAlcoholic,
      presentations: [
        Presentation('Lata 350 ml', 350, kind: PresentationKind.can),
        Presentation('Garrafa 600 ml', 600, kind: PresentationKind.bottle),
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
      ],
    ),
    CatalogItem(
      id: 'generic-suco',
      name: 'Suco',
      category: DrinkCategory.nonAlcoholic,
      presentations: [
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Copo 500 ml', 500, kind: PresentationKind.glass),
      ],
    ),
    CatalogItem(
      id: 'generic-cerveja-sem-alcool',
      name: 'Cerveja sem álcool',
      category: DrinkCategory.nonAlcoholic,
      presentations: [
        Presentation('Long neck 355 ml', 355, kind: PresentationKind.longNeck),
        Presentation('Lata 350 ml', 350, kind: PresentationKind.can),
      ],
    ),
    // Água
    CatalogItem(
      id: waterItemId,
      name: 'Água sem gás',
      category: DrinkCategory.water,
      presentations: [
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Garrafa 500 ml', 500, kind: PresentationKind.bottle),
        Presentation('Garrafa 1 L', 1000, kind: PresentationKind.bottle),
      ],
    ),
    CatalogItem(
      id: 'generic-agua-com-gas',
      name: 'Água com gás',
      category: DrinkCategory.water,
      presentations: [
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Garrafa 500 ml', 500, kind: PresentationKind.bottle),
      ],
    ),
  ];

  static CatalogItem get water => items.firstWhere((i) => i.id == waterItemId);
}
