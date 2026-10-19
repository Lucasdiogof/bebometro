import 'catalog_item.dart';
import 'drink_category.dart';

/// Typical sizes offered when a product has no documented presentations.
/// Labels are plain volumes on purpose: a "600 ml" suggestion must not read
/// like a package the product is documented to come in.
/// These are conveniences for registering (and doses for spirits), not
/// claims about the product or about what any bar serves.
List<Presentation> commonSizesFor(DrinkCategory category) {
  switch (category) {
    case DrinkCategory.beer:
    case DrinkCategory.nonAlcoholic:
      return const [
        Presentation(
          '350 ml',
          350,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
        Presentation(
          '355 ml',
          355,
          kind: PresentationKind.longNeck,
          isSuggestion: true,
        ),
        Presentation(
          '473 ml',
          473,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
        Presentation(
          '600 ml',
          600,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ];
    case DrinkCategory.draft:
      // Served glasses, not packages: editable suggestions, never an official
      // size of the brand.
      return const [
        Presentation(
          'Copo 200 ml',
          200,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
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
        Presentation(
          'Caneca 500 ml',
          500,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
      ];
    case DrinkCategory.cocktail:
      return const [
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
      ];
    case DrinkCategory.spirit:
      return const [
        Presentation(
          'Dose 30 ml',
          30,
          kind: PresentationKind.shot,
          isSuggestion: true,
        ),
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
      ];
    case DrinkCategory.readyToDrink:
      return const [
        Presentation(
          '269 ml',
          269,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
        Presentation(
          '275 ml',
          275,
          kind: PresentationKind.longNeck,
          isSuggestion: true,
        ),
        Presentation(
          '350 ml',
          350,
          kind: PresentationKind.can,
          isSuggestion: true,
        ),
      ];
    case DrinkCategory.wine:
      return const [
        Presentation(
          'Taça 100 ml',
          100,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Taça 125 ml',
          125,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          'Taça 150 ml',
          150,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          '750 ml',
          750,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ];
    case DrinkCategory.water:
      return const [
        Presentation(
          'Copo 300 ml',
          300,
          kind: PresentationKind.glass,
          isSuggestion: true,
        ),
        Presentation(
          '500 ml',
          500,
          kind: PresentationKind.bottle,
          isSuggestion: true,
        ),
      ];
  }
}
