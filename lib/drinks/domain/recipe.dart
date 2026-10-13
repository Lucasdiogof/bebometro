import '../../core/utils/formatters.dart';
import 'catalog_item.dart';
import '../../l10n/l10n.dart';

/// Ingredient roles a spirit product can fill in a recipe. A role lets the
/// user pick a brand when registering. The codes are stored and never change.
const ingredientRoles = [
  'cachaca',
  'vodka',
  'gin',
  'rum',
  'tequila',
  'whisky',
  'orange-liqueur',
  'campari',
  'aperol',
  'vermouth-sweet',
  'vermouth-dry',
  'sparkling-wine',
  'bitters',
];

/// Name of a role in the language on screen (the code itself when unknown).
String ingredientRoleLabel(String role) => switch (role) {
      'cachaca' => tr.roleCachaca,
      'vodka' => tr.roleVodka,
      'gin' => tr.roleGin,
      'rum' => tr.roleRum,
      'tequila' => tr.roleTequila,
      'whisky' => tr.roleWhisky,
      'orange-liqueur' => tr.roleOrangeLiqueur,
      'campari' => tr.roleCampari,
      'aperol' => tr.roleAperol,
      'vermouth-sweet' => tr.roleSweetVermouth,
      'vermouth-dry' => tr.roleDryVermouth,
      'sparkling-wine' => tr.roleSparklingWine,
      'bitters' => tr.roleBitters,
      _ => role,
    };

/// Unit of an ingredient amount. Only [ml] is a liquid volume: the others are
/// never converted into ml, so they never enter the alcohol calculation.
enum RecipeUnit {
  ml('ml'),
  g('g'),
  unit('unit'),
  tsp('tsp'),
  tbsp('tbsp'),
  leaf('leaf'),
  drop('drop'),
  toTaste('to_taste'),

  /// The recipe's own wording (e.g. "6 ramos de hortelã", "completar"),
  /// kept as written when it does not fit the units above.
  other('other');

  const RecipeUnit(this.code);

  /// Stored value; never translated.
  final String code;

  String get label => switch (this) {
        RecipeUnit.ml => tr.recipeUnitMl,
        RecipeUnit.g => tr.recipeUnitG,
        RecipeUnit.unit => tr.recipeUnitUnit,
        RecipeUnit.tsp => tr.recipeUnitTsp,
        RecipeUnit.tbsp => tr.recipeUnitTbsp,
        RecipeUnit.leaf => tr.recipeUnitLeaf,
        RecipeUnit.drop => tr.recipeUnitDrop,
        RecipeUnit.toTaste => tr.recipeUnitToTaste,
        RecipeUnit.other => tr.recipeUnitOther,
      };

  String get shortLabel => switch (this) {
        RecipeUnit.ml => 'ml',
        RecipeUnit.g => 'g',
        RecipeUnit.unit => tr.recipeShortUnit,
        RecipeUnit.tsp => tr.recipeShortTsp,
        RecipeUnit.tbsp => tr.recipeShortTbsp,
        RecipeUnit.leaf => tr.recipeShortLeaf,
        RecipeUnit.drop => tr.recipeShortDrop,
        RecipeUnit.toTaste => tr.recipeUnitToTaste,
        RecipeUnit.other => '',
      };

  /// Units the editor offers (the original wording is not selectable).
  static const editable = [ml, g, unit, tsp, tbsp, leaf, drop, toTaste];

  static RecipeUnit? fromCode(String? code) {
    for (final u in RecipeUnit.values) {
      if (u.code == code) return u;
    }
    return null;
  }
}

/// One ingredient of a drink, as written in a reference recipe or as the user
/// actually registered it. Unknown values stay null: a missing amount or ABV
/// is never turned into zero.
class EntryComponent {
  const EntryComponent({
    required this.name,
    required this.alcoholic,
    this.role,
    this.amount,
    this.unit = RecipeUnit.ml,
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

  /// Amount in [unit]. Null = unknown.
  final double? amount;
  final RecipeUnit unit;

  /// The recipe's wording, kept when the amount is not a number in [unit]
  /// ("completar", "6 ramos de hortelã").
  final String? amountText;

  /// Null = unknown.
  final double? abvPercent;
  final String? productId;
  final String? productName;
  final bool optional;

  /// Liquid volume in ml, only when the amount is in ml. Spoons, pieces,
  /// leaves, drops and grams are never turned into ml.
  double? get amountMl => unit == RecipeUnit.ml ? amount : null;

  String get amountLabel {
    switch (unit) {
      case RecipeUnit.toTaste:
        return tr.recipeUnitToTaste;
      case RecipeUnit.other:
        return amountText ?? tr.recipeAmountUnknown;
      default:
        if (amount == null) return amountText ?? tr.recipeAmountUnknown;
        return '${_trim(amount!)} ${unit.shortLabel}';
    }
  }

  /// Why the alcohol of this ingredient cannot be counted, or null if it can.
  String? get alcoholGap {
    if (!alcoholic) return null;
    if (abvPercent == null) return tr.recipeGapAbv;
    if (unit != RecipeUnit.ml) return tr.recipeGapNotMl;
    if (amount == null) return tr.recipeGapAmount;
    return null;
  }

  /// Pure alcohol in ml, only when both the volume (in ml) and the ABV are
  /// known.
  double? get pureAlcoholMl =>
      (alcoholic && amountMl != null && abvPercent != null)
          ? amountMl! * abvPercent! / 100
          : null;

  EntryComponent copyWith({
    String? name,
    bool? alcoholic,
    double? Function()? amount,
    RecipeUnit? unit,
    String? Function()? amountText,
    double? Function()? abvPercent,
    String? Function()? productId,
    String? Function()? productName,
  }) =>
      EntryComponent(
        name: name ?? this.name,
        alcoholic: alcoholic ?? this.alcoholic,
        role: role,
        amount: amount != null ? amount() : this.amount,
        unit: unit ?? this.unit,
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
        // Kept for readers that only know millilitres.
        'amount_ml': amountMl,
        'amount': amount,
        'unit': unit.code,
        if (amountText != null) 'amount_text': amountText,
        'abv_percent': abvPercent,
        if (productId != null) 'product_id': productId,
        if (productName != null) 'product_name': productName,
        if (optional) 'optional': true,
      };

  /// Reads current snapshots and older ones (which only had `amount_ml` and
  /// `amount_text`, no unit).
  factory EntryComponent.fromJson(Map<String, dynamic> j) {
    var unit = RecipeUnit.fromCode(j['unit'] as String?);
    unit ??= (j['amount_ml'] != null || j['amount_text'] == null)
        ? RecipeUnit.ml
        : RecipeUnit.other;
    final amount = (j['amount'] as num?)?.toDouble() ??
        (unit == RecipeUnit.ml ? (j['amount_ml'] as num?)?.toDouble() : null);
    return EntryComponent(
      name: j['name'] as String,
      alcoholic: j['alcoholic'] as bool? ?? false,
      role: j['role'] as String?,
      amount: amount,
      unit: unit,
      amountText: j['amount_text'] as String?,
      abvPercent: (j['abv_percent'] as num?)?.toDouble(),
      productId: j['product_id'] as String?,
      productName: j['product_name'] as String?,
      optional: j['optional'] as bool? ?? false,
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : decimalToInput(v);
}

/// Editorial translation of a reference recipe into one language. Lists are
/// aligned with the recipe's components (same order); a null entry keeps the
/// original wording.
class RecipeTexts {
  const RecipeTexts({
    this.method,
    this.garnish,
    this.note,
    this.componentNames = const [],
    this.componentTexts = const [],
  });

  final String? method;
  final String? garnish;
  final String? note;
  final List<String?> componentNames;
  final List<String?> componentTexts;
}

/// A reference recipe (e.g. from the IBA). It documents a recipe; it is not a
/// statement about what any bar served. Texts are written in Portuguese and
/// translated through [translations]; the user's own recipes have none, so
/// they always show exactly what was typed.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required List<EntryComponent> components,
    this.source,
    String? method,
    String? garnish,
    String? note,
    this.translations = const {},
  })  : _components = components,
        _method = method,
        _garnish = garnish,
        _note = note;

  final String id;
  final String name;
  final SourceRef? source;
  final Map<String, RecipeTexts> translations;
  final List<EntryComponent> _components;
  final String? _method;
  final String? _garnish;
  final String? _note;

  RecipeTexts? get _texts => translations[trLanguage];

  /// Components in the language on screen.
  List<EntryComponent> get components {
    final t = _texts;
    if (t == null) return _components;
    return [
      for (var i = 0; i < _components.length; i++)
        _components[i].copyWith(
          name: i < t.componentNames.length ? t.componentNames[i] : null,
          amountText: i < t.componentTexts.length && t.componentTexts[i] != null
              ? () => t.componentTexts[i]
              : null,
        ),
    ];
  }

  String? get method => _texts?.method ?? _method;
  String? get garnish => _texts?.garnish ?? _garnish;
  String? get note => _texts?.note ?? _note;

  /// Component names in every language, for search.
  List<String> get searchComponents => [
        for (final c in _components) c.name,
        for (final t in translations.values)
          for (final n in t.componentNames) ?n,
      ];
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
      missing.add('${c.name} (${c.alcoholGap})');
    } else {
      pure += ml;
    }
  }
  return AlcoholEstimate(pureMl: pure, missing: missing);
}
