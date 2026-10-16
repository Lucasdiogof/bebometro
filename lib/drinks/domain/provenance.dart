import '../../l10n/l10n.dart';
import 'catalog_item.dart';

/// What kind of source a piece of data comes from. It says where the data
/// was read, never that it is certified, current or still on sale.
enum ProvenanceKind {
  /// Manufacturer's own page or technical sheet.
  official('official'),

  /// A label transcribed or photographed in a secondary source.
  labelPhoto('label'),

  /// Public package registry (barcode records). Proves a package existed in
  /// the market, not that it is sold today.
  packagingRegistry('packagingRegistry'),

  /// Other secondary source (press, distributor listing...).
  secondary('secondary'),

  /// Published reference recipe.
  recipe('recipe'),

  /// Typed by the person (own drink or outing item).
  user('user'),

  /// Common size offered for convenience, not a documented package.
  suggestion('suggestion'),

  /// Typical values of a generic reference item.
  generic('generic'),

  /// No source for this field: the product's general source applies.
  general('general');

  const ProvenanceKind(this.code);

  /// Stored value; never translated.
  final String code;

  String get label => switch (this) {
        ProvenanceKind.official => tr.provenanceOfficial,
        ProvenanceKind.labelPhoto => tr.provenanceLabel,
        ProvenanceKind.packagingRegistry => tr.provenancePackagingRegistry,
        ProvenanceKind.secondary => tr.provenanceSecondary,
        ProvenanceKind.recipe => tr.provenanceRecipe,
        ProvenanceKind.user => tr.provenanceUser,
        ProvenanceKind.suggestion => tr.provenanceSuggestion,
        ProvenanceKind.generic => tr.provenanceGeneric,
        ProvenanceKind.general => tr.provenanceGeneral,
      };

  static ProvenanceKind? fromCode(String? code) {
    for (final k in ProvenanceKind.values) {
      if (k.code == code) return k;
    }
    return null;
  }
}

/// Fields that can carry their own source.
enum ProvenanceField {
  abv('abv'),
  ingredients('ingredients'),
  presentations('presentations'),
  style('style');

  const ProvenanceField(this.code);

  final String code;

  String get label => switch (this) {
        ProvenanceField.abv => tr.detailAbv,
        ProvenanceField.ingredients => tr.detailIngredients,
        ProvenanceField.presentations => tr.detailPresentations,
        ProvenanceField.style => tr.catalogStyle,
      };

  static ProvenanceField? fromCode(String code) {
    for (final f in ProvenanceField.values) {
      if (f.code == code) return f;
    }
    return null;
  }
}

/// Where ONE field of a catalog product was read (catalog `fieldSources`).
class FieldSource {
  const FieldSource({
    required this.field,
    required this.kind,
    required this.label,
    this.url,
    this.labelI18n = const {},
    this.consultedOn,
    this.market,
    this.variant,
    this.note,
    this.noteI18n = const {},
  });

  final ProvenanceField field;
  final ProvenanceKind kind;

  /// As written in the catalog (quotes of the source stay in the original).
  final String label;
  final Map<String, String> labelI18n;
  final String? url;

  /// ISO date (yyyy-MM-dd) the source was consulted. It is not the date the
  /// product or the page was updated.
  final String? consultedOn;

  /// Market the source refers to ("BR", "US"...).
  final String? market;

  /// Part of the field this source covers ("can 350 ml").
  final String? variant;
  final String? note;
  final Map<String, String> noteI18n;

  String get displayLabel => localizedText(label, labelI18n);
  String? get displayNote => note == null ? null : localizedText(note!, noteI18n);

  /// Volume named in [variant] ("can 350 ml" -> 350), or null.
  Set<int> get variantVolumes => {
        for (final m in RegExp(r'\d+').allMatches(variant ?? ''))
          int.parse(m.group(0)!),
      };
}

/// The sources shown for one field.
class FieldProvenance {
  const FieldProvenance(this.field, this.sources,
      {this.fallback = false, this.presentations = const {}});

  final ProvenanceField field;
  final List<FieldSource> sources;

  /// True when the field has no source of its own and the product's general
  /// source (or its origin) is shown instead.
  final bool fallback;

  /// For [ProvenanceField.presentations]: which documented sizes each source
  /// covers (by index in [sources]).
  final Map<int, List<Presentation>> presentations;
}

/// Field-by-field provenance of [item]. A field source always wins over the
/// product's general source; a field without one says so (never a guessed
/// attribution).
List<FieldProvenance> provenanceOf(CatalogItem item) {
  final own = item.fieldSources;
  List<FieldSource> of(ProvenanceField f) =>
      own.where((s) => s.field == f).toList();

  // Origins where the whole item has one kind of source.
  final whole = switch (item.origin) {
    InfoOrigin.user => ProvenanceKind.user,
    InfoOrigin.recipe => ProvenanceKind.recipe,
    InfoOrigin.generic => ProvenanceKind.generic,
    _ => null,
  };
  final itemUser = item.isCustom || item.isOutingOnly;

  FieldSource general(ProvenanceField f) => FieldSource(
        field: f,
        kind: itemUser ? ProvenanceKind.user : (whole ?? ProvenanceKind.general),
        label: item.source?.label ?? item.origin.label,
        labelI18n: item.source?.labelI18n ?? const {},
        url: item.source?.url,
        consultedOn: item.source?.consultedOn,
        market: item.market,
      );

  FieldProvenance simple(ProvenanceField f) {
    final list = of(f);
    if (list.isNotEmpty) return FieldProvenance(f, list);
    if (f == ProvenanceField.abv && item.abvSource != null) {
      final s = item.abvSource!;
      return FieldProvenance(f, [
        FieldSource(
          field: f,
          kind: ProvenanceKind.labelPhoto,
          label: s.label,
          labelI18n: s.labelI18n,
          url: s.url,
          consultedOn: s.consultedOn,
          market: item.market,
        ),
      ]);
    }
    return FieldProvenance(f, [general(f)], fallback: true);
  }

  final out = <FieldProvenance>[
    if (item.abvPercent != null || item.abvVariants.isNotEmpty)
      simple(ProvenanceField.abv),
    if (item.ingredients != null) simple(ProvenanceField.ingredients),
    if (item.style != null && item.style!.isNotEmpty)
      simple(ProvenanceField.style),
  ];

  final documented = item.documentedPresentations;
  if (documented.isNotEmpty) {
    final list = of(ProvenanceField.presentations);
    final covered = <int, List<Presentation>>{};
    final left = [...documented];
    for (final (i, s) in list.indexed) {
      final vols = s.variantVolumes;
      final mine = vols.isEmpty
          ? <Presentation>[]
          : left.where((p) => vols.contains(p.volumeMl)).toList();
      left.removeWhere(mine.contains);
      covered[i] = mine;
    }
    final sources = [...list];
    if (left.isNotEmpty || list.isEmpty) {
      covered[sources.length] = left;
      sources.add(general(ProvenanceField.presentations));
    }
    out.add(FieldProvenance(ProvenanceField.presentations, sources,
        fallback: list.isEmpty, presentations: covered));
  } else if (item.presentations.isNotEmpty) {
    out.add(FieldProvenance(ProvenanceField.presentations, [
      FieldSource(
        field: ProvenanceField.presentations,
        kind: ProvenanceKind.suggestion,
        label: tr.provenanceSuggestionLine,
      ),
    ]));
  }
  return out;
}
