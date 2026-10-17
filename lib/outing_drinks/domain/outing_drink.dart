import '../../drinks/domain/abv_source.dart';
import '../../drinks/domain/catalog_item.dart';
import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/recipe.dart';
import '../../l10n/l10n.dart';

/// How an outing drink was created.
enum OutingDrinkOrigin {
  manual('manual'),
  photoLabel('label'),
  menu('menu');

  const OutingDrinkOrigin(this.code);

  /// Stored value; never translated.
  final String code;

  String get label => switch (this) {
    OutingDrinkOrigin.manual => tr.originManual,
    OutingDrinkOrigin.photoLabel => tr.originPhotoLabel,
    OutingDrinkOrigin.menu => tr.originMenu,
  };

  static OutingDrinkOrigin fromCode(String? code) =>
      OutingDrinkOrigin.values.firstWhere(
        (o) => o.code == code,
        orElse: () => OutingDrinkOrigin.manual,
      );
}

/// A drink that belongs to exactly one outing: registered by hand, read from a
/// label photo or taken from a menu photo. It is not part of the catalog, not
/// in "Minhas bebidas" and never offered in another outing.
///
/// Unknown values stay null (volume, ABV, price, ingredients): they are never
/// turned into zero.
class OutingDrink {
  const OutingDrink({
    required this.id,
    required this.outingId,
    required this.name,
    required this.category,
    required this.origin,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.style,
    this.description,
    this.volumeMl,
    this.abvPercent,
    this.abvSource,
    this.ingredients,
    this.components,
    this.referenceItemId,
    this.advertisedCents,
    this.photoIds = const [],
    this.sourceText,
    this.deletedAt,
  });

  final String id;
  final String outingId;
  final String name;
  final DrinkCategory category;
  final OutingDrinkOrigin origin;
  final String? brand;
  final String? style;

  /// Menu wording, kept as written.
  final String? description;

  /// Package or serving size written on the label/menu; null = unknown.
  final int? volumeMl;
  final double? abvPercent;
  final AbvSource? abvSource;
  final List<String>? ingredients;

  /// Ingredients of a mixed drink. Amounts the source did not give stay null.
  final List<EntryComponent>? components;

  /// Catalog product the user chose as a reference. Only a pointer: the
  /// official product is never changed.
  final String? referenceItemId;

  /// What the menu advertised. A suggestion; the user confirms the payment.
  final int? advertisedCents;
  final List<String> photoIds;

  /// The text this item was read from (label or menu snippet).
  final String? sourceText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  String get itemId => '${CatalogItem.outingPrefix}$id';

  String get displayName {
    final b = brand;
    if (b == null || b.isEmpty) return name;
    return name.toLowerCase().startsWith(b.toLowerCase()) ? name : '$b $name';
  }

  /// The drink as the registration form sees it. The id carries the outing
  /// prefix so every record made from it stays recognisable as outing-only.
  CatalogItem toCatalogItem() {
    final comps = components;
    if (comps != null && comps.isNotEmpty) {
      return CatalogItem(
        id: itemId,
        name: displayName,
        category: DrinkCategory.cocktail,
        presentations: const [],
        origin: InfoOrigin.user,
        note: description,
        recipe: Recipe(id: itemId, name: displayName, components: comps),
        advertisedCents: advertisedCents,
      );
    }
    final ml = volumeMl;
    return CatalogItem(
      id: itemId,
      name: name,
      brand: brand,
      style: style,
      category: category,
      abvPercent: abvPercent,
      abvOrigin: abvPercent == null ? null : abvSource,
      ingredients: ingredients,
      origin: InfoOrigin.user,
      note: description,
      presentations: ml == null ? const [] : [Presentation('$ml ml', ml)],
      advertisedCents: advertisedCents,
    );
  }

  OutingDrink copyWith({
    String? name,
    DrinkCategory? category,
    String? Function()? brand,
    String? Function()? style,
    String? Function()? description,
    int? Function()? volumeMl,
    double? Function()? abvPercent,
    AbvSource? Function()? abvSource,
    List<String>? Function()? ingredients,
    List<EntryComponent>? Function()? components,
    String? Function()? referenceItemId,
    int? Function()? advertisedCents,
    List<String>? photoIds,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => OutingDrink(
    id: id,
    outingId: outingId,
    name: name ?? this.name,
    category: category ?? this.category,
    origin: origin,
    brand: brand != null ? brand() : this.brand,
    style: style != null ? style() : this.style,
    description: description != null ? description() : this.description,
    volumeMl: volumeMl != null ? volumeMl() : this.volumeMl,
    abvPercent: abvPercent != null ? abvPercent() : this.abvPercent,
    abvSource: abvSource != null ? abvSource() : this.abvSource,
    ingredients: ingredients != null ? ingredients() : this.ingredients,
    components: components != null ? components() : this.components,
    referenceItemId: referenceItemId != null
        ? referenceItemId()
        : this.referenceItemId,
    advertisedCents: advertisedCents != null
        ? advertisedCents()
        : this.advertisedCents,
    photoIds: photoIds ?? this.photoIds,
    sourceText: sourceText,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'outing_id': outingId,
    'name': name,
    'category': category.code,
    'origin': origin.code,
    'brand': brand,
    'style': style,
    'description': description,
    'volume_ml': volumeMl,
    'abv_percent': abvPercent,
    'abv_source': abvPercent == null ? null : abvSource?.code,
    'ingredients': ingredients,
    'components': components == null
        ? null
        : [for (final c in components!) c.toJson()],
    'reference_item_id': referenceItemId,
    'advertised_cents': advertisedCents,
    'photo_ids': photoIds,
    'source_text': sourceText,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory OutingDrink.fromJson(Map<String, dynamic> j) => OutingDrink(
    id: j['id'] as String,
    outingId: j['outing_id'] as String,
    name: j['name'] as String,
    category: DrinkCategory.fromCode(j['category'] as String),
    origin: OutingDrinkOrigin.fromCode(j['origin'] as String?),
    brand: j['brand'] as String?,
    style: j['style'] as String?,
    description: j['description'] as String?,
    volumeMl: (j['volume_ml'] as num?)?.toInt(),
    abvPercent: (j['abv_percent'] as num?)?.toDouble(),
    abvSource: AbvSource.fromCode(j['abv_source'] as String?),
    ingredients: (j['ingredients'] as List?)?.cast<String>(),
    components: (j['components'] as List?)
        ?.map(
          (c) => EntryComponent.fromJson(Map<String, dynamic>.from(c as Map)),
        )
        .toList(),
    referenceItemId: j['reference_item_id'] as String?,
    advertisedCents: (j['advertised_cents'] as num?)?.toInt(),
    photoIds: (j['photo_ids'] as List?)?.cast<String>() ?? const [],
    sourceText: j['source_text'] as String?,
    createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(j['updated_at'] as String).toLocal(),
    deletedAt: j['deleted_at'] == null
        ? null
        : DateTime.parse(j['deleted_at'] as String).toLocal(),
  );
}

/// What a photo shows. Photos belong to the outing they were taken in.
enum OutingPhotoKind {
  photoLabel('label'),
  menu('menu');

  const OutingPhotoKind(this.code);

  /// Stored value; never translated.
  final String code;

  String get label => switch (this) {
    OutingPhotoKind.photoLabel => tr.photoKindLabel,
    OutingPhotoKind.menu => tr.photoKindMenu,
  };

  static OutingPhotoKind fromCode(String? code) =>
      OutingPhotoKind.values.firstWhere(
        (k) => k.code == code,
        orElse: () => OutingPhotoKind.photoLabel,
      );
}

/// Metadata of a photo. The image itself is a file (never base64 in a row);
/// [uploadedAt] is set only after the server confirmed the private upload.
class OutingPhoto {
  const OutingPhoto({
    required this.id,
    required this.outingId,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
    this.storagePath,
    this.uploadedAt,
    this.deletedAt,
  });

  final String id;
  final String outingId;
  final OutingPhotoKind kind;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// `<owner>/<outing>/<photo>.jpg` in the private bucket, once uploaded.
  final String? storagePath;
  final DateTime? uploadedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
  bool get isUploaded => uploadedAt != null && storagePath != null;

  OutingPhoto copyWith({
    String? storagePath,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearStorage = false,
  }) => OutingPhoto(
    id: id,
    outingId: outingId,
    kind: kind,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    storagePath: clearStorage ? null : (storagePath ?? this.storagePath),
    uploadedAt: clearStorage ? null : (uploadedAt ?? this.uploadedAt),
    deletedAt: deletedAt ?? this.deletedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'outing_id': outingId,
    'kind': kind.code,
    'storage_path': storagePath,
    'uploaded_at': uploadedAt?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory OutingPhoto.fromJson(Map<String, dynamic> j) => OutingPhoto(
    id: j['id'] as String,
    outingId: j['outing_id'] as String,
    kind: OutingPhotoKind.fromCode(j['kind'] as String?),
    storagePath: j['storage_path'] as String?,
    uploadedAt: j['uploaded_at'] == null
        ? null
        : DateTime.parse(j['uploaded_at'] as String).toLocal(),
    createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(j['updated_at'] as String).toLocal(),
    deletedAt: j['deleted_at'] == null
        ? null
        : DateTime.parse(j['deleted_at'] as String).toLocal(),
  );
}
