import '../../core/utils/formatters.dart';
import 'drink_category.dart';
import 'recipe.dart';

/// Where a catalog item's information comes from.
enum InfoOrigin {
  /// Generic reference item. Values are typical, not an official product label.
  generic('generic', 'Genérico'),

  /// Created by the user on this device/account.
  user('user', 'Criada por você'),

  /// Taken from the manufacturer's own pages, with the source kept. It says
  /// where the data came from, not that it is certified or current.
  verified('verified', 'Dados do fabricante'),

  /// Manufacturer data, except at least one field (e.g. ABV) that only has a
  /// label transcribed in a secondary source.
  mixed('mixed', 'Fabricante + rótulo (fonte secundária)'),

  /// Label or listing consulted in a secondary source, not the manufacturer.
  secondary('secondary', 'Rótulo em fonte secundária'),

  /// A published reference recipe. It is not what any bar served.
  recipe('recipe', 'Receita de referência');

  const InfoOrigin(this.code, this.label);

  final String code;
  final String label;
}

/// The physical form a drink is served or sold in.
enum PresentationKind {
  can('can', 'Lata'),
  longNeck('longNeck', 'Long neck'),
  bottle('bottle', 'Garrafa'),
  glass('glass', 'Copo/taça'),
  shot('shot', 'Dose');

  const PresentationKind(this.code, this.label);

  final String code;
  final String label;

  static PresentationKind? fromCode(String? code) {
    for (final k in PresentationKind.values) {
      if (k.code == code) return k;
    }
    return null;
  }
}

/// One way a product is served or sold (can, long neck, 400 ml tulip...).
/// The package volume is not what the user drank: that is decided when the
/// drink is registered (individual or shared).
class Presentation {
  const Presentation(this.label, this.volumeMl,
      {this.kind, this.isSuggestion = false});

  /// Builds the label from the kind and volume ("Lata 350 ml"), or just the
  /// volume when the source does not say what the package is.
  factory Presentation.of(PresentationKind? kind, int volumeMl,
          {String? label}) =>
      Presentation(
        label ??
            (kind == null
                ? formatMl(volumeMl)
                : '${kind.label} ${formatMl(volumeMl)}'),
        volumeMl,
        kind: kind,
      );

  final String label;
  final int volumeMl;
  final PresentationKind? kind;

  /// A size offered for convenience (common serving, dose), not a package the
  /// product is documented to come in. Suggestions never match package
  /// filters and are not saved as the record's presentation.
  final bool isSuggestion;
}

/// An ABV that differs between sources, presentations or markets. Kept as
/// documented variants instead of silently choosing one.
class AbvVariant {
  const AbvVariant(this.value, this.scope);

  final double value;
  final String scope;
}

/// Where a catalog fact was read, so it can be checked again.
class SourceRef {
  const SourceRef({required this.url, required this.label, this.consultedOn});

  final String url;
  final String label;

  /// ISO date (yyyy-MM-dd) when the page was consulted.
  final String? consultedOn;
}

/// A product that can be logged. A single product carries several
/// presentations, so it is not duplicated for each size.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.presentations,
    this.brand,
    this.style,
    this.abvPercent,
    this.ingredients,
    this.origin = InfoOrigin.generic,
    this.note,
    this.aliases = const [],
    this.source,
    this.abvVariants = const [],
    this.abvSource,
    this.roles = const [],
    this.recipe,
  });

  final String id;
  final String name;
  final String? brand;
  final DrinkCategory category;
  final String? style;

  /// Verified sizes of this product. Empty means "not known", in which case
  /// the form offers common sizes for the category instead.
  final List<Presentation> presentations;

  /// Null means unknown, which is never the same as 0.
  final double? abvPercent;

  /// Null means unknown; an empty list is never used to mean "unknown".
  final List<String>? ingredients;
  final InfoOrigin origin;
  final String? note;

  /// Other names people search by.
  final List<String> aliases;
  final SourceRef? source;

  /// Documented ABVs when sources disagree ([abvPercent] is then null).
  final List<AbvVariant> abvVariants;

  /// Set when the ABV comes from a different (secondary) source than
  /// [source], e.g. a label transcribed elsewhere.
  final SourceRef? abvSource;

  /// What this product can be in a recipe ("gin", "cachaca"...).
  final List<String> roles;

  /// Present for reference or personal recipes (mixed drinks).
  final Recipe? recipe;

  static const customPrefix = 'custom:';

  bool get isCustom => id.startsWith(customPrefix);

  /// Packages documented for this product (suggestions excluded).
  List<Presentation> get documentedPresentations =>
      presentations.where((p) => !p.isSuggestion).toList();

  bool get isRecipe => recipe != null;

  /// "Brahma Duplo Malte"; the brand is not repeated when the name already
  /// starts with it.
  String get displayName {
    final b = brand;
    if (b == null || b.isEmpty) return name;
    return normalizeText(name).startsWith(normalizeText(b)) ? name : '$b $name';
  }

  String get subtitle {
    final parts = <String>[
      if (style != null && style!.isNotEmpty) style!,
      if (abvPercent != null)
        formatAbv(abvPercent!)
      else if (abvVariants.isNotEmpty)
        'teor varia',
    ];
    return parts.isEmpty ? category.label : parts.join(' · ');
  }

  /// Coarse style family used by the style filter, derived from the style the
  /// source states. Null when no style is known.
  String? get styleGroup {
    final s = style;
    if (s == null || s.trim().isEmpty) return null;
    final n = normalizeText(s);
    if (n.contains('stout') || n.contains('porter')) return 'Stout/Porter';
    if (n.contains('ipa') || n.contains('india pale')) return 'IPA';
    if (n.contains('witbier')) return 'Witbier';
    if (n.contains('weiss') || n.contains('weizen')) return 'Weiss';
    if (n.contains('pale ale')) return 'Pale Ale';
    if (n.contains('pils') || n.contains('lager')) return 'Lager/Pilsen';
    return s.trim();
  }

  /// Everything a search should match, normalised once.
  String get searchText => normalizeText([
        displayName,
        brand ?? '',
        style ?? '',
        styleGroup ?? '',
        category.label,
        ...aliases,
        ...documentedPresentations.map((p) => p.label),
        ...(recipe?.components.map((c) => c.name) ?? const <String>[]),
      ].join(' '));
}
