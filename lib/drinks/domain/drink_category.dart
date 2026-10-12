import 'package:flutter/material.dart';

enum DrinkCategory {
  beer('beer', 'Cerveja', Icons.sports_bar_rounded),
  draft('draft', 'Chopp', Icons.local_drink_rounded),
  cocktail('cocktail', 'Drink', Icons.wine_bar_rounded),
  spirit('spirit', 'Destilado/dose', Icons.liquor_rounded),
  wine('wine', 'Vinho', Icons.wine_bar_outlined),
  nonAlcoholic('non_alcoholic', 'Sem álcool', Icons.emoji_food_beverage_rounded),
  water('water', 'Água', Icons.water_drop_rounded);

  const DrinkCategory(this.code, this.label, this.icon);

  final String code;
  final String label;
  final IconData icon;

  /// Categories whose products may contain alcohol.
  bool get canBeAlcoholic =>
      this != DrinkCategory.nonAlcoholic && this != DrinkCategory.water;

  static DrinkCategory fromCode(String code) => DrinkCategory.values
      .firstWhere((c) => c.code == code, orElse: () => DrinkCategory.cocktail);
}
