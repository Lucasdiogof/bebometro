import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/recipe.dart';
import '../../l10n/l10n.dart';
import '../../outings/domain/outing.dart';
import '../data/local_store.dart';
import '../utils/formatters.dart';

/// One readable fact of a version ("Endereço: Rua 5"). Never a column name or
/// an id.
class ConflictField {
  const ConflictField(this.label, this.value);

  final String label;
  final String value;
}

/// The facts of one version, in a fixed order so both sides line up.
class ConflictSide {
  const ConflictSide({required this.fields, required this.deleted});

  final List<ConflictField> fields;

  /// This version is a deletion (the other one is an edit).
  final bool deleted;
}

/// What the conflict is about: the item by name, the kind of change and both
/// versions with the fields that differ.
class ConflictView {
  const ConflictView({
    required this.kind,
    required this.name,
    required this.local,
    required this.remote,
    required this.differing,
  });

  /// "Local", "Bebida pessoal", "Receita pessoal".
  final String kind;
  final String name;
  final ConflictSide local;
  final ConflictSide? remote;

  /// Labels of the fields whose value differs between the versions.
  final Set<String> differing;
}

/// Readable description of a place / personal drink / personal recipe conflict.
/// Returns null for any other collection (those keep their own description).
class ConflictDescriber {
  const ConflictDescriber._();

  static ConflictView? describe(
    String collection,
    Map<String, dynamic> local,
    Map<String, dynamic>? remote,
  ) {
    switch (collection) {
      case LocalStore.places:
        return _build(
          kind: tr.conflictKindPlace,
          name: _placeName,
          fieldsOf: _placeFields,
          local: local,
          remote: remote,
        );
      case LocalStore.customDrinks:
        final isRecipe =
            local['components'] != null || remote?['components'] != null;
        return _build(
          kind: isRecipe ? tr.conflictKindRecipe : tr.conflictKindDrink,
          name: (j) => _text(j['name']) ?? tr.drinkFallbackName,
          fieldsOf: _drinkFields,
          local: local,
          remote: remote,
        );
    }
    return null;
  }

  static ConflictView _build({
    required String kind,
    required String Function(Map<String, dynamic>) name,
    required List<ConflictField> Function(Map<String, dynamic>) fieldsOf,
    required Map<String, dynamic> local,
    required Map<String, dynamic>? remote,
  }) {
    final l = fieldsOf(local);
    final r = remote == null ? null : fieldsOf(remote);
    final differing = <String>{};
    if (r != null) {
      for (var i = 0; i < l.length && i < r.length; i++) {
        if (l[i].value != r[i].value) differing.add(l[i].label);
      }
    }
    // The name of the item: the version still alive wins, else this device's.
    final localGone = local['deleted_at'] != null;
    final shown = localGone && remote != null ? remote : local;
    return ConflictView(
      kind: kind,
      name: name(shown),
      local: ConflictSide(fields: l, deleted: localGone),
      remote: r == null
          ? null
          : ConflictSide(fields: r, deleted: remote!['deleted_at'] != null),
      differing: differing,
    );
  }

  static String? _text(Object? v) {
    final s = v?.toString().trim();
    return s == null || s.isEmpty ? null : s;
  }

  static String _or(Object? v) => _text(v) ?? tr.conflictNotInformed;

  static String _placeName(Map<String, dynamic> j) =>
      _text(j['nickname']) ??
      _text(j['provider_name']) ??
      _text(j['address']) ??
      tr.itemFallbackName;

  static List<ConflictField> _placeFields(Map<String, dynamic> j) {
    final city = [
      _text(j['city']),
      _text(j['state']),
    ].whereType<String>().join(' / ');
    final hasPoint = j['latitude'] != null && j['longitude'] != null;
    return [
      ConflictField(tr.conflictFieldName, _or(j['nickname'] ?? j['provider_name'])),
      ConflictField(
        tr.conflictFieldType,
        OutingType.fromCode(_text(j['type']) ?? 'other').label,
      ),
      ConflictField(tr.conflictFieldAddress, _or(j['address'])),
      ConflictField(tr.conflictFieldCity, city.isEmpty ? tr.conflictNotInformed : city),
      ConflictField(
        tr.conflictFieldFavorite,
        j['favorite'] == true ? tr.conflictYes : tr.conflictNo,
      ),
      ConflictField(
        tr.conflictFieldStatus,
        j['archived_at'] != null ? tr.conflictArchived : tr.conflictActive,
      ),
      ConflictField(
        tr.conflictFieldMap,
        hasPoint ? tr.conflictPointSet : tr.conflictPointNone,
      ),
    ];
  }

  static List<ConflictField> _drinkFields(Map<String, dynamic> j) {
    final components = j['components'];
    final category = _text(j['category']);
    final volume = j['volume_ml'];
    final abv = j['abv_percent'];
    final ingredients = (j['ingredients'] as List?)
        ?.map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return [
      ConflictField(tr.conflictFieldName, _or(j['name'])),
      if (category != null)
        ConflictField(
          tr.conflictFieldCategory,
          DrinkCategory.fromCode(category).label,
        ),
      if (components is List) ...[
        ConflictField(tr.conflictFieldRecipe, _recipeLines(components)),
      ] else ...[
        ConflictField(tr.conflictFieldBrand, _or(j['brand'])),
        ConflictField(tr.conflictFieldStyle, _or(j['style'])),
        ConflictField(
          tr.conflictFieldVolume,
          volume is num && volume > 0
              ? formatMl(volume.toInt())
              : tr.conflictNotInformed,
        ),
        ConflictField(
          tr.conflictFieldAbv,
          abv is num ? formatAbv(abv.toDouble()) : tr.conflictNotInformed,
        ),
        ConflictField(
          tr.conflictFieldIngredients,
          ingredients == null || ingredients.isEmpty
              ? tr.conflictNotInformed
              : ingredients.join(', '),
        ),
      ],
    ];
  }

  /// One line per ingredient: "Gin · 50 ml · 40%" (unknown parts say so).
  static String _recipeLines(List components) {
    final lines = <String>[];
    for (final raw in components) {
      if (raw is! Map) continue;
      final c = EntryComponent.fromJson(Map<String, dynamic>.from(raw));
      lines.add(
        [
          c.name,
          c.amountLabel,
          if (c.alcoholic)
            c.abvPercent == null
                ? '${tr.conflictFieldAbv}: ${tr.conflictNotInformed}'
                : formatAbv(c.abvPercent!),
        ].join(' · '),
      );
    }
    return lines.isEmpty ? tr.conflictNotInformed : lines.join('\n');
  }
}
