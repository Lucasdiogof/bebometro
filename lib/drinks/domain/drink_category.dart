import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

enum DrinkCategory {
  beer('beer', Icons.sports_bar_rounded),
  draft('draft', Icons.local_drink_rounded),
  cocktail('cocktail', Icons.wine_bar_rounded),
  spirit('spirit', Icons.liquor_rounded),

  /// Industrialized mixed drinks sold ready to drink (bottled/canned
  /// cocktails, "ice", hard seltzers). Recipes stay in [cocktail].
  readyToDrink('ready_to_drink', Icons.local_bar_rounded),
  wine('wine', Icons.wine_bar_outlined),
  nonAlcoholic('non_alcoholic', Icons.emoji_food_beverage_rounded),
  water('water', Icons.water_drop_rounded);

  const DrinkCategory(this.code, this.icon);

  /// Stored value; never translated.
  final String code;
  final IconData icon;

  /// Name in the language on screen.
  String get label => _labelIn(tr);

  /// Names in every language of the app, so a search finds the category
  /// whatever language it is written in.
  List<String> get searchLabels => [
        for (final code in const ['pt', 'en', 'es'])
          _labelIn(lookupAppLocalizations(Locale(code))),
      ];

  String _labelIn(AppLocalizations t) => switch (this) {
        DrinkCategory.beer => t.categoryBeer,
        DrinkCategory.draft => t.categoryDraft,
        DrinkCategory.cocktail => t.categoryCocktail,
        DrinkCategory.spirit => t.categorySpirit,
        DrinkCategory.readyToDrink => t.categoryReadyToDrink,
        DrinkCategory.wine => t.categoryWine,
        DrinkCategory.nonAlcoholic => t.categoryNonAlcoholic,
        DrinkCategory.water => t.categoryWater,
      };

  /// Categories whose products may contain alcohol.
  bool get canBeAlcoholic =>
      this != DrinkCategory.nonAlcoholic && this != DrinkCategory.water;

  static DrinkCategory fromCode(String code) => DrinkCategory.values
      .firstWhere((c) => c.code == code, orElse: () => DrinkCategory.cocktail);
}
