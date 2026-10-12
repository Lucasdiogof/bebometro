import 'catalog_item.dart';
import 'drink_category.dart';

/// Typical serving sizes offered when a product has no verified presentations.
/// These are conveniences for registering, not claims about the product.
List<Presentation> commonSizesFor(DrinkCategory category) {
  switch (category) {
    case DrinkCategory.beer:
    case DrinkCategory.nonAlcoholic:
      return const [
        Presentation('Lata 350 ml', 350, kind: PresentationKind.can),
        Presentation('Long neck 355 ml', 355, kind: PresentationKind.longNeck),
        Presentation('Lata 473 ml', 473, kind: PresentationKind.can),
        Presentation('Garrafa 600 ml', 600, kind: PresentationKind.bottle),
      ];
    case DrinkCategory.draft:
      return const [
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Copo 400 ml', 400, kind: PresentationKind.glass),
        Presentation('Caneca 500 ml', 500, kind: PresentationKind.glass),
      ];
    case DrinkCategory.cocktail:
      return const [
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Copo 400 ml', 400, kind: PresentationKind.glass),
      ];
    case DrinkCategory.spirit:
      return const [
        Presentation('Dose 50 ml', 50, kind: PresentationKind.shot),
        Presentation('Dose dupla 100 ml', 100, kind: PresentationKind.shot),
      ];
    case DrinkCategory.wine:
      return const [
        Presentation('Taça 150 ml', 150, kind: PresentationKind.glass),
        Presentation('Taça 200 ml', 200, kind: PresentationKind.glass),
        Presentation('Garrafa 750 ml', 750, kind: PresentationKind.bottle),
      ];
    case DrinkCategory.water:
      return const [
        Presentation('Copo 300 ml', 300, kind: PresentationKind.glass),
        Presentation('Garrafa 500 ml', 500, kind: PresentationKind.bottle),
      ];
  }
}
