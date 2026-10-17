import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import '../domain/recipe.dart';

/// Small bundled starter catalog. Everything here is a generic reference item:
/// ABV values are typical figures, not official brand data, and unknown
/// information is left null instead of being invented.
class CatalogSource {
  const CatalogSource._();

  static const waterItemId = 'generic-agua-sem-gas';
  static const _typical = 'Teor típico do tipo de bebida. Confirme no rótulo.';
  static const _typicalI18n = {
    'en': 'Typical ABV for this kind of drink. Check the label.',
    'es': 'Graduación típica de este tipo de bebida. Confirma en la etiqueta.',
  };

  static const items = <CatalogItem>[
    CatalogItem(
      id: 'generic-cerveja-pilsen',
      name: 'Cerveja Pilsen/Lager',
      nameI18n: {'en': 'Pilsner/Lager beer', 'es': 'Cerveza Pilsen/Lager'},
      aliases: [
        'beer',
        'pilsner',
        'lager',
        'cerveza',
        'cerveja',
        'pilsen',
        'cerveja comum',
      ],
      category: DrinkCategory.beer,
      style: 'Pilsen/Lager',
      abvPercent: 4.8,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Lata 350 ml',
          350,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
        Presentation(
          'Lata 473 ml',
          473,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
        Presentation(
          'Long neck 355 ml',
          355,
          kind: PresentationKind.longNeck,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 600 ml',
          600,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-cerveja-ipa',
      name: 'Cerveja IPA',
      nameI18n: {'en': 'IPA beer', 'es': 'Cerveza IPA'},
      aliases: ['india pale ale', 'ipa beer', 'cerveza ipa'],
      category: DrinkCategory.beer,
      style: 'IPA',
      abvPercent: 6.5,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Lata 350 ml',
          350,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
        Presentation(
          'Lata 473 ml',
          473,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 500 ml',
          500,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-cerveja-trigo',
      name: 'Cerveja de trigo',
      nameI18n: {'en': 'Wheat beer', 'es': 'Cerveza de trigo'},
      aliases: ['weissbier', 'weizen', 'trigo', 'wheat', 'witbier'],
      category: DrinkCategory.beer,
      style: 'Weiss',
      abvPercent: 5.0,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Long neck 355 ml',
          355,
          kind: PresentationKind.longNeck,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 500 ml',
          500,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-chopp-claro',
      name: 'Chopp claro',
      nameI18n: {'en': 'Light draft beer', 'es': 'Cerveza de barril clara'},
      aliases: [
        'chope claro',
        'draft',
        'draught',
        'tap beer',
        'chopp',
        'barril',
        'caña',
      ],
      category: DrinkCategory.draft,
      style: 'Pilsen/Lager',
      abvPercent: 4.8,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Tulipa 300 ml',
          300,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Copo 400 ml',
          400,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Caneca 500 ml',
          500,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Tulipa 1 L',
          1000,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-chopp-escuro',
      name: 'Chopp escuro',
      nameI18n: {'en': 'Dark draft beer', 'es': 'Cerveza de barril oscura'},
      aliases: ['chope escuro', 'dark draft', 'cerveza negra', 'stout draft'],
      category: DrinkCategory.draft,
      style: 'Escura',
      abvPercent: 5.0,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Tulipa 300 ml',
          300,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Copo 400 ml',
          400,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Caneca 500 ml',
          500,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
      ],
    ),
    // ABV unknown for drinks: depends on the recipe and the bar.
    CatalogItem(
      id: 'generic-drink-outro',
      name: 'Drink (genérico)',
      nameI18n: {'en': 'Cocktail (generic)', 'es': 'Cóctel (genérico)'},
      aliases: ['cocktail', 'coctel', 'cóctel', 'drink'],
      noteI18n: {
        'en': 'Ingredients and ABV unknown.',
        'es': 'Ingredientes y graduación desconocidos.',
      },
      category: DrinkCategory.cocktail,
      note: 'Ingredientes e teor desconhecidos.',
      presentations: [
        Presentation(
          'Copo 300 ml',
          300,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Copo 400 ml',
          400,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'recipe:custom-blank',
      name: 'Drink personalizado',
      nameI18n: {'en': 'Custom cocktail', 'es': 'Cóctel personalizado'},
      aliases: [
        'cocktail',
        'coctel',
        'cóctel',
        'custom',
        'personalizado',
        'my own',
      ],
      noteI18n: {
        'en':
            'Build the composition: the ingredients, amounts and ABV you know.',
        'es':
            'Arma la composición: los ingredientes, cantidades y graduaciones que conozcas.',
      },
      category: DrinkCategory.cocktail,
      presentations: [],
      note:
          'Monte a composição: ingredientes, quantidades e teores que você souber.',
      recipe: Recipe(
        id: 'recipe:custom-blank',
        name: 'Drink personalizado',
        components: [],
      ),
    ),
    CatalogItem(
      id: 'generic-cachaca',
      name: 'Cachaça',
      aliases: [
        'pinga',
        'aguardente',
        'cana',
        'sugarcane spirit',
        'aguardiente de caña',
      ],
      category: DrinkCategory.spirit,
      abvPercent: 40,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Dose 50 ml',
          50,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
        Presentation(
          'Dose dupla 100 ml',
          100,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-vodka',
      name: 'Vodka',
      aliases: ['vodca'],
      category: DrinkCategory.spirit,
      abvPercent: 40,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Dose 50 ml',
          50,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
        Presentation(
          'Dose dupla 100 ml',
          100,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-whisky',
      name: 'Whisky',
      aliases: ['whiskey', 'scotch', 'bourbon', 'uísque', 'uisque'],
      category: DrinkCategory.spirit,
      abvPercent: 40,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Dose 50 ml',
          50,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
        Presentation(
          'Dose dupla 100 ml',
          100,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-gin',
      name: 'Gin',
      nameI18n: {'es': 'Ginebra'},
      aliases: ['ginebra', 'genebra'],
      category: DrinkCategory.spirit,
      abvPercent: 40,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Dose 50 ml',
          50,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
        Presentation(
          'Dose dupla 100 ml',
          100,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-vinho-tinto',
      name: 'Vinho tinto',
      nameI18n: {'en': 'Red wine', 'es': 'Vino tinto'},
      aliases: ['wine', 'vino', 'vinho', 'red wine', 'tinto'],
      category: DrinkCategory.wine,
      abvPercent: 12.5,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Taça 150 ml',
          150,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Taça 200 ml',
          200,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 750 ml',
          750,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-vinho-branco',
      name: 'Vinho branco',
      nameI18n: {'en': 'White wine', 'es': 'Vino blanco'},
      aliases: ['wine', 'vino', 'vinho', 'white wine', 'branco'],
      category: DrinkCategory.wine,
      abvPercent: 12.0,
      note: _typical,
      noteI18n: _typicalI18n,
      presentations: [
        Presentation(
          'Taça 150 ml',
          150,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Taça 200 ml',
          200,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 750 ml',
          750,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-refrigerante',
      name: 'Refrigerante',
      nameI18n: {'en': 'Soft drink', 'es': 'Refresco'},
      aliases: [
        'soda',
        'cola',
        'guaraná',
        'guarana',
        'coca',
        'gaseosa',
        'refresco',
      ],
      category: DrinkCategory.nonAlcoholic,
      presentations: [
        Presentation(
          'Lata 350 ml',
          350,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 600 ml',
          600,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
        Presentation(
          'Copo 300 ml',
          300,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-suco',
      name: 'Suco',
      nameI18n: {'en': 'Juice', 'es': 'Jugo'},
      aliases: ['zumo', 'juice', 'suco'],
      category: DrinkCategory.nonAlcoholic,
      presentations: [
        Presentation(
          'Copo 300 ml',
          300,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Copo 500 ml',
          500,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-cerveja-sem-alcool',
      name: 'Cerveja sem álcool',
      nameI18n: {'en': 'Non-alcoholic beer', 'es': 'Cerveza sin alcohol'},
      aliases: [
        'zero',
        '0,0',
        'sem alcool',
        'alcohol free',
        'sin alcohol',
        'non alcoholic beer',
      ],
      category: DrinkCategory.nonAlcoholic,
      presentations: [
        Presentation(
          'Long neck 355 ml',
          355,
          kind: PresentationKind.longNeck,
          isSuggestion: true,
        ),
        Presentation(
          'Lata 350 ml',
          350,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: waterItemId,
      name: 'Água sem gás',
      nameI18n: {'en': 'Still water', 'es': 'Agua sin gas'},
      aliases: ['water', 'agua', 'still water', 'mineral'],
      category: DrinkCategory.water,
      presentations: [
        Presentation(
          'Copo 300 ml',
          300,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 500 ml',
          500,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 1 L',
          1000,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ],
    ),
    CatalogItem(
      id: 'generic-agua-com-gas',
      name: 'Água com gás',
      nameI18n: {'en': 'Sparkling water', 'es': 'Agua con gas'},
      aliases: ['soda water', 'sparkling', 'agua con gas', 'mineral com gas'],
      category: DrinkCategory.water,
      presentations: [
        Presentation(
          'Copo 300 ml',
          300,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Garrafa 500 ml',
          500,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ],
    ),
  ];

  static CatalogItem get water => items.firstWhere((i) => i.id == waterItemId);
}
