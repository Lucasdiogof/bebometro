import 'package:flutter/widgets.dart' show Locale;

import '../../core/utils/formatters.dart';
import '../../l10n/l10n.dart';
import 'abv_source.dart';
import 'drink_category.dart';
import 'presentation_label.dart';
import 'provenance.dart';
import 'recipe.dart';

/// Where a catalog item's information comes from.
enum InfoOrigin {
  /// Generic reference item. Values are typical, not an official product label.
  generic('generic'),

  /// Created by the user on this device/account.
  user('user'),

  /// Taken from the manufacturer's own pages, with the source kept. It says
  /// where the data came from, not that it is certified or current.
  verified('verified'),

  /// Manufacturer data, except at least one field (e.g. ABV) that only has a
  /// label transcribed in a secondary source.
  mixed('mixed'),

  /// Label or listing consulted in a secondary source, not the manufacturer.
  secondary('secondary'),

  /// A published reference recipe. It is not what any bar served.
  recipe('recipe');

  const InfoOrigin(this.code);

  /// Stored value; never translated.
  final String code;

  String get label => switch (this) {
    InfoOrigin.generic => tr.originGeneric,
    InfoOrigin.user => tr.originUser,
    InfoOrigin.verified => tr.originVerified,
    InfoOrigin.mixed => tr.originMixed,
    InfoOrigin.secondary => tr.originSecondary,
    InfoOrigin.recipe => tr.originRecipe,
  };
}

/// The physical form a drink is served or sold in.
enum PresentationKind {
  can('can', 'Lata'),
  longNeck('longNeck', 'Long neck'),
  bottle('bottle', 'Garrafa'),
  glass('glass', 'Copo/taça'),
  shot('shot', 'Dose');

  const PresentationKind(this.code, this.canonical);

  /// Stored value; never translated.
  final String code;

  /// Word used in the label saved with a record (pt-BR). The screen shows
  /// [label]; see [Presentation.label] for why the saved text stays fixed.
  final String canonical;

  /// Name in the language on screen.
  String get label => switch (this) {
    PresentationKind.can => tr.kindCan,
    PresentationKind.longNeck => tr.kindLongNeck,
    PresentationKind.bottle => tr.kindBottle,
    PresentationKind.glass => tr.kindGlass,
    PresentationKind.shot => tr.kindShot,
  };

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
  const Presentation(
    this.label,
    this.volumeMl, {
    this.kind,
    this.isSuggestion = false,
  });

  /// Builds the label from the kind and volume ("Lata 350 ml"), or just the
  /// volume when the source does not say what the package is.
  factory Presentation.of(
    PresentationKind? kind,
    int volumeMl, {
    String? label,
  }) => Presentation(
    label ??
        (kind == null
            ? '${_ptNumber(volumeMl)} ml'
            : '${kind.canonical} ${_ptNumber(volumeMl)} ml'),
    volumeMl,
    kind: kind,
  );

  /// Canonical text (pt-BR wording and number format). It is what a record
  /// saves as its presentation and what chips compare with, so it never
  /// changes with the language; [displayLabel] is what the screen shows.
  final String label;
  final int volumeMl;
  final PresentationKind? kind;

  /// A size offered for convenience (common serving, dose), not a package the
  /// product is documented to come in. Suggestions never match package
  /// filters and are not saved as the record's presentation.
  final bool isSuggestion;

  /// [label] in the language on screen.
  String get displayLabel => localizePresentation(label);
}

String _ptNumber(num value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => '.',
);

/// An ABV that differs between sources, presentations or markets. Kept as
/// documented variants instead of silently choosing one.
class AbvVariant {
  const AbvVariant(this.value, this.scope, {this.scopeI18n = const {}});

  final double value;

  /// Where the value applies, in the catalog's original language.
  final String scope;

  /// Editorial translations of [scope], by language code.
  final Map<String, String> scopeI18n;

  String get displayScope => localizedText(scope, scopeI18n);
}

/// Where a catalog fact was read, so it can be checked again.
class SourceRef {
  const SourceRef({
    required this.url,
    required this.label,
    this.consultedOn,
    this.labelI18n = const {},
  });

  final String url;

  /// Name of the source in the catalog's original language.
  final String label;

  /// ISO date (yyyy-MM-dd) when the page was consulted.
  final String? consultedOn;

  /// Editorial translations of [label], by language code.
  final Map<String, String> labelI18n;

  String get displayLabel => localizedText(label, labelI18n);
}

/// A product that can be logged. A single product carries several
/// presentations, so it is not duplicated for each size.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required String name,
    this.nameI18n = const {},
    required this.category,
    required this.presentations,
    this.brand,
    this.style,
    this.abvPercent,
    this.ingredients,
    this.origin = InfoOrigin.generic,
    String? note,
    this.noteI18n = const {},
    this.aliases = const [],
    this.source,
    this.abvVariants = const [],
    this.abvSource,
    this.roles = const [],
    this.recipe,
    this.abvOrigin,
    this.advertisedCents,
    this.fieldSources = const [],
    this.market,
  }) : _name = name,
       _note = note;

  final String id;
  final String _name;

  /// Editorial translations of the name, by language code (generic items;
  /// brand products keep their own name and the user's drinks are never
  /// translated).
  final Map<String, String> nameI18n;
  final String? brand;
  final DrinkCategory category;

  /// Style as the source states it (original wording, also what a record
  /// saves). Use [displayStyle] to show it.
  final String? style;

  /// Verified sizes of this product. Empty means "not known", in which case
  /// the form offers common sizes for the category instead.
  final List<Presentation> presentations;

  /// Null means unknown, which is never the same as 0.
  final double? abvPercent;

  /// As declared by the manufacturer, in the original language: they are not
  /// translated. Null means unknown; an empty list is never used to mean
  /// "unknown".
  final List<String>? ingredients;
  final InfoOrigin origin;
  final String? _note;

  /// Editorial translations of the note, by language code.
  final Map<String, String> noteI18n;

  /// Other names people search by, in any of the app's languages.
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

  /// Where the ABV came from, only for items that belong to one outing.
  final AbvSource? abvOrigin;

  /// Price a menu advertised for this outing item. A suggestion only: the
  /// user confirms what was actually paid.
  final int? advertisedCents;

  /// Where individual fields were read; wins over [source] for that field.
  final List<FieldSource> fieldSources;

  /// Market the product data refers to ("BR", "US"), when the catalog says.
  final String? market;

  static const customPrefix = 'custom:';

  /// Items created inside an outing (manual, label or menu). They live only in
  /// that outing and never appear in the catalog.
  static const outingPrefix = 'outing:';

  bool get isOutingOnly => id.startsWith(outingPrefix);

  bool get isCustom => id.startsWith(customPrefix);

  /// Name in the language on screen.
  String get name => localizedText(_name, nameI18n);

  /// Note in the language on screen (the original when there is no
  /// translation; text the user wrote is never translated).
  String? get note => _note == null ? null : localizedText(_note, noteI18n);

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

  /// [style] in the language on screen.
  String? get displayStyle => style == null ? null : styleLabel(style!);

  String get subtitle {
    final parts = <String>[
      if (style != null && style!.isNotEmpty) styleLabel(style!),
      if (abvPercent != null)
        formatAbv(abvPercent!)
      else if (abvVariants.isNotEmpty)
        tr.abvVaries,
    ];
    return parts.isEmpty ? category.label : parts.join(' · ');
  }

  /// Coarse style family used by the style filter, derived from the style the
  /// source states. Null when no style is known. It is a stable key (not
  /// translated); show it with [styleLabel].
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

  /// Everything a search should match, normalised once. Category names and
  /// styles are included in every language, so a search in English finds the
  /// same items as one in Portuguese or Spanish.
  String get searchText => normalizeText(
    [
      displayName,
      brand ?? '',
      style ?? '',
      styleGroup ?? '',
      ...category.searchLabels,
      if (style != null) ...styleSearchLabels(style!),
      ...aliases,
      ...documentedPresentations.map((p) => p.label),
      ...(recipe?.searchComponents ?? const <String>[]),
    ].join(' '),
  );
}

/// Style as shown to the person. Most styles are international names and are
/// kept; the few written in Portuguese are translated.
String styleLabel(String style) => switch (style) {
  'Lager/Pilsen' => tr.styleLagerPilsen,
  'Pilsen/Lager' => tr.styleLagerPilsen,
  'Escura' => tr.styleDark,
  'Rum branco' => tr.styleWhiteRum,
  'Aperitivo' => tr.styleAperitif,
  'Aperitivo bitter' => tr.styleBitterAperitif,
  'Vermute doce' => tr.styleSweetVermouth,
  'Vermute seco' => tr.styleDryVermouth,
  'Tequila 100% agave' => tr.styleAgaveTequila,
  _ => style,
};

/// A style in every language, for search.
List<String> styleSearchLabels(String style) {
  final labels = <String>{style};
  for (final code in const ['pt', 'en', 'es']) {
    final t = lookupAppLocalizations(Locale(code));
    labels.add(switch (style) {
      'Lager/Pilsen' || 'Pilsen/Lager' => t.styleLagerPilsen,
      'Escura' => t.styleDark,
      'Rum branco' => t.styleWhiteRum,
      'Aperitivo' => t.styleAperitif,
      'Aperitivo bitter' => t.styleBitterAperitif,
      'Vermute doce' => t.styleSweetVermouth,
      'Vermute seco' => t.styleDryVermouth,
      'Tequila 100% agave' => t.styleAgaveTequila,
      _ => style,
    });
  }
  return labels.toList();
}
