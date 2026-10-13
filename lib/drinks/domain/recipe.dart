import '../../core/utils/formatters.dart';
import 'catalog_item.dart';

/// Ingredient roles a spirit product can fill in a recipe, with the label the
/// editor shows. A role lets the user pick a brand when registering.
const Map<String, String> ingredientRoleLabels = {
  'cachaca': 'Cachaça',
  'vodka': 'Vodka',
  'gin': 'Gin',
  'rum': 'Rum',
  'tequila': 'Tequila',
  'whisky': 'Whisky',
  'orange-liqueur': 'Licor de laranja',
  'campari': 'Campari',
  'aperol': 'Aperol',
  'vermouth-sweet': 'Vermute doce',
  'vermouth-dry': 'Vermute seco',
  'sparkling-wine': 'Espumante',
  'bitters': 'Bitter',
};

/// One ingredient of a drink, as written in a reference recipe or as the user
/// actually registered it. Unknown values stay null: a missing amount or ABV
/// is never turned into zero.
class EntryComponent {
  const EntryComponent({
    required this.name,
    required this.alcoholic,
    this.role,
    this.amountMl,
    this.amountText,
    this.abvPercent,
    this.productId,
    this.productName,
    this.optional = false,
  });

  final String name;

  /// Matches a spirit product's role ("gin", "cachaca"...), so the user can
  /// pick a brand for this ingredient.
  final String? role;
  final bool alcoholic;

  /// Liquid volume in ml, only when the recipe gives one. Pieces, spoons,
  /// dashes, leaves and ice are never converted into ml.
  final double? amountMl;

  /// How the amount reads when there is no ml value ("4 colheres de chá").
  final String? amountText;

  /// Null = unknown.
  final double? abvPercent;
  final String? productId;
  final String? productName;
  final bool optional;

  String get amountLabel {
    if (amountMl != null) return '${_trim(amountMl!)} ml';
    return amountText ?? 'quantidade não informada';
  }

  /// Pure alcohol in ml, only when both the volume and the ABV are known.
  double? get pureAlcoholMl =>
      (alcoholic && amountMl != null && abvPercent != null)
          ? amountMl! * abvPercent! / 100
          : null;

  EntryComponent copyWith({
    String? name,
    bool? alcoholic,
    double? Function()? amountMl,
    String? Function()? amountText,
    double? Function()? abvPercent,
    String? Function()? productId,
    String? Function()? productName,
  }) =>
      EntryComponent(
        name: name ?? this.name,
        alcoholic: alcoholic ?? this.alcoholic,
        role: role,
        amountMl: amountMl != null ? amountMl() : this.amountMl,
        amountText: amountText != null ? amountText() : this.amountText,
        abvPercent: abvPercent != null ? abvPercent() : this.abvPercent,
        productId: productId != null ? productId() : this.productId,
        productName: productName != null ? productName() : this.productName,
        optional: optional,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'alcoholic': alcoholic,
        if (role != null) 'role': role,
        'amount_ml': amountMl,
        if (amountText != null) 'amount_text': amountText,
        'abv_percent': abvPercent,
        if (productId != null) 'product_id': productId,
        if (productName != null) 'product_name': productName,
        if (optional) 'optional': true,
      };

  factory EntryComponent.fromJson(Map<String, dynamic> j) => EntryComponent(
        name: j['name'] as String,
        alcoholic: j['alcoholic'] as bool? ?? false,
        role: j['role'] as String?,
        amountMl: (j['amount_ml'] as num?)?.toDouble(),
        amountText: j['amount_text'] as String?,
        abvPercent: (j['abv_percent'] as num?)?.toDouble(),
        productId: j['product_id'] as String?,
        productName: j['product_name'] as String?,
        optional: j['optional'] as bool? ?? false,
      );

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : decimalToInput(v);
}

/// A reference recipe (e.g. from the IBA). It documents a recipe; it is not a
/// statement about what any bar served.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.components,
    this.source,
    this.method,
    this.garnish,
    this.note,
  });

  final String id;
  final String name;
  final List<EntryComponent> components;
  final SourceRef? source;
  final String? method;
  final String? garnish;
  final String? note;
}

/// Snapshot of what was registered for a mixed drink. It lives in the record,
/// so editing the catalog or the user's own recipes never changes history.
class Composition {
  const Composition({
    required this.components,
    this.recipeId,
    this.recipeName,
    this.sourceLabel,
    this.sourceUrl,
    this.customized = false,
  });

  final List<EntryComponent> components;

  /// The reference recipe this started from, when there was one.
  final String? recipeId;
  final String? recipeName;
  final String? sourceLabel;
  final String? sourceUrl;

  /// The user changed amounts, ABV or ingredients from the reference.
  final bool customized;

  Composition copyWith({List<EntryComponent>? components, bool? customized}) =>
      Composition(
        components: components ?? this.components,
        recipeId: recipeId,
        recipeName: recipeName,
        sourceLabel: sourceLabel,
        sourceUrl: sourceUrl,
        customized: customized ?? this.customized,
      );

  Map<String, dynamic> toJson() => {
        if (recipeId != null) 'recipe_id': recipeId,
        if (recipeName != null) 'recipe_name': recipeName,
        if (sourceLabel != null) 'source_label': sourceLabel,
        if (sourceUrl != null) 'source_url': sourceUrl,
        'customized': customized,
        'components': [for (final c in components) c.toJson()],
      };

  factory Composition.fromJson(Map<String, dynamic> j) => Composition(
        recipeId: j['recipe_id'] as String?,
        recipeName: j['recipe_name'] as String?,
        sourceLabel: j['source_label'] as String?,
        sourceUrl: j['source_url'] as String?,
        customized: j['customized'] as bool? ?? false,
        components: [
          for (final c in (j['components'] as List))
            EntryComponent.fromJson(Map<String, dynamic>.from(c as Map)),
        ],
      );
}

/// Pure alcohol that can be computed from what is known. Components with an
/// unknown amount or ABV are listed in [missing], never counted as zero.
class AlcoholEstimate {
  const AlcoholEstimate({required this.pureMl, required this.missing});

  /// Sum over the components where volume and ABV are both known.
  final double pureMl;

  /// Names of alcoholic components that could not be counted.
  final List<String> missing;

  bool get isComplete => missing.isEmpty;

  /// Ethanol density is about 0.789 g/ml.
  double get grams => pureMl * 0.789;
}

AlcoholEstimate estimateComponents(List<EntryComponent> components) {
  var pure = 0.0;
  final missing = <String>[];
  for (final c in components) {
    if (!c.alcoholic) continue;
    final ml = c.pureAlcoholMl;
    if (ml == null) {
      missing.add(c.name);
    } else {
      pure += ml;
    }
  }
  return AlcoholEstimate(pureMl: pure, missing: missing);
}
