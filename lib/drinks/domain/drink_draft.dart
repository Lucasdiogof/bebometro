import '../../core/utils/formatters.dart';
import 'abv_source.dart';
import 'catalog_item.dart';
import 'drink_category.dart';
import 'drink_entry.dart';
import 'recipe.dart';
import '../../l10n/l10n.dart';

/// Editable state of the "register drink" form, with all the sharing and
/// price rules kept out of the widgets.
class DrinkDraft {
  const DrinkDraft({
    required this.name,
    required this.category,
    required this.consumedAt,
    this.brand,
    this.style,
    this.catalogItemId,
    this.ingredients,
    this.origin = InfoOrigin.user,
    this.note,
    this.presentationLabel,
    this.containerMl,
    this.abvPercent,
    this.abvSource,
    this.priceKind = PriceKind.unknown,
    this.paidCents,
    this.billTotalCents,
    this.paidEdited = false,
    this.isShared = false,
    this.peopleCount = 2,
    this.personalMl,
    this.leftoverMl = 0,
    this.personalEdited = false,
    this.existing,
    this.notBefore,
    this.notAfter,
    this.composition,
    this.reference,
    this.entryOrigin,
    this.consumerId,
    this.portions,
  });

  factory DrinkDraft.fromItem(
    CatalogItem item, {
    required DateTime now,
    DateTime? notBefore,
    DateTime? notAfter,
  }) {
    final recipe = item.recipe;
    if (recipe != null) {
      // Mixed drink: starts from the recipe, no volume until the user says one.
      return DrinkDraft(
        name: item.displayName,
        category: item.category,
        catalogItemId: item.id,
        origin: item.origin,
        note: item.note,
        consumedAt: now,
        notBefore: notBefore,
        notAfter: notAfter,
        reference: recipe.components,
        composition: Composition(
          recipeId: recipe.id,
          recipeName: item.name,
          sourceLabel: recipe.source?.displayLabel,
          sourceUrl: recipe.source?.url,
          components: recipe.components,
        ),
      );
    }
    final first = item.presentations.isEmpty ? null : item.presentations.first;
    return DrinkDraft(
      name: item.displayName,
      category: item.category,
      brand: item.brand,
      style: item.style,
      catalogItemId: item.id,
      ingredients: item.ingredients,
      origin: item.origin,
      note: item.note,
      consumedAt: now,
      presentationLabel: (first == null || first.isSuggestion)
          ? null
          : first.label,
      containerMl: first?.volumeMl,
      abvPercent: item.abvPercent,
      abvSource: item.abvOrigin,
      personalMl: first?.volumeMl,
      notBefore: notBefore,
      notAfter: notAfter,
    );
  }

  /// [asNew]: a NEW record prefilled from [e] (lock-screen review), not a
  /// correction of [e]; [consumedAt] then replaces its time.
  factory DrinkDraft.fromEntry(
    DrinkEntry e, {
    DateTime? notBefore,
    DateTime? notAfter,
    bool asNew = false,
    DateTime? consumedAt,
    EntryOrigin? origin,
  }) => DrinkDraft(
    name: e.name,
    category: e.category,
    brand: e.brand,
    style: e.style,
    catalogItemId: e.catalogItemId,
    ingredients: e.ingredients,
    consumedAt: consumedAt ?? e.consumedAt,
    presentationLabel: e.presentation,
    containerMl: e.containerMl,
    abvPercent: e.abvPercent,
    abvSource: e.abvSource,
    priceKind: e.priceKind,
    paidCents: e.paidCents,
    billTotalCents: e.billTotalCents,
    paidEdited: true,
    isShared: e.isShared,
    peopleCount: e.peopleCount < 2 ? 2 : e.peopleCount,
    personalMl: e.personalMl,
    leftoverMl: e.leftoverMl,
    personalEdited: true,
    existing: asNew ? null : e,
    notBefore: notBefore,
    notAfter: notAfter,
    composition: e.composition,
    // A correction keeps the record's origin; a new record gets only the
    // origin it is given (never the template's).
    entryOrigin: asNew ? origin : e.entryOrigin,
    consumerId: e.consumerId,
    portions: e.portions,
  );

  /// Lock-screen origin carried to the saved record (see [EntryOrigin]).
  final EntryOrigin? entryOrigin;

  /// Who drank it (see [DrinkEntry.consumerId]; null is the owner) and the
  /// per-person portions of a shared bottle (see [DrinkEntry.portions]).
  final String? consumerId;
  final Map<String, int?>? portions;

  DrinkDraft withConsumer(String? id) => DrinkDraft(
    name: name,
    category: category,
    brand: brand,
    style: style,
    catalogItemId: catalogItemId,
    ingredients: ingredients,
    origin: origin,
    note: note,
    consumedAt: consumedAt,
    presentationLabel: presentationLabel,
    containerMl: containerMl,
    abvPercent: abvPercent,
    abvSource: abvSource,
    priceKind: priceKind,
    paidCents: paidCents,
    billTotalCents: billTotalCents,
    paidEdited: paidEdited,
    isShared: isShared,
    peopleCount: peopleCount,
    personalMl: personalMl,
    leftoverMl: leftoverMl,
    personalEdited: personalEdited,
    existing: existing,
    notBefore: notBefore,
    notAfter: notAfter,
    composition: composition,
    reference: reference,
    entryOrigin: entryOrigin,
    consumerId: id,
    // A guest-only draft has no owner portion; per-person portions are set by
    // the order flow, never by this setter.
    portions: portions,
  );

  final String name;
  final DrinkCategory category;
  final String? brand;
  final String? style;
  final String? catalogItemId;
  final List<String>? ingredients;
  final InfoOrigin origin;
  final String? note;
  final DateTime consumedAt;

  final String? presentationLabel;
  final int? containerMl;
  final double? abvPercent;
  final AbvSource? abvSource;

  final PriceKind priceKind;
  final int? paidCents;
  final int? billTotalCents;
  final bool paidEdited;

  final bool isShared;
  final int peopleCount;
  final int? personalMl;
  final int leftoverMl;
  final bool personalEdited;

  final DrinkEntry? existing;

  /// What went into a mixed drink (null for simple drinks). The components
  /// are editable; [reference] is the recipe they started from, if any.
  final Composition? composition;
  final List<EntryComponent>? reference;

  /// Period of the outing the drink belongs to. [notAfter] is null while the
  /// outing is still running (then "now" is the limit).
  final DateTime? notBefore;
  final DateTime? notAfter;

  static const maxPeople = 30;

  bool get isEditing => existing != null;

  bool get isRecipe => composition != null;

  List<EntryComponent> get components => composition?.components ?? const [];

  /// Pure alcohol of the composition as it stands, with what is missing.
  AlcoholEstimate? get alcoholEstimate =>
      composition == null || !components.any((c) => c.alcoholic)
      ? null
      : estimateComponents(components);

  DrinkDraft _copy({
    String? Function()? presentationLabel,
    int? Function()? containerMl,
    double? Function()? abvPercent,
    AbvSource? Function()? abvSource,
    PriceKind? priceKind,
    int? Function()? paidCents,
    int? Function()? billTotalCents,
    bool? paidEdited,
    bool? isShared,
    int? peopleCount,
    int? Function()? personalMl,
    int? leftoverMl,
    bool? personalEdited,
    DateTime? consumedAt,
    Composition? composition,
  }) => DrinkDraft(
    name: name,
    category: category,
    brand: brand,
    style: style,
    catalogItemId: catalogItemId,
    ingredients: ingredients,
    origin: origin,
    note: note,
    existing: existing,
    notBefore: notBefore,
    notAfter: notAfter,
    reference: reference,
    entryOrigin: entryOrigin,
    consumerId: consumerId,
    portions: portions,
    composition: composition ?? this.composition,
    consumedAt: consumedAt ?? this.consumedAt,
    presentationLabel: presentationLabel != null
        ? presentationLabel()
        : this.presentationLabel,
    containerMl: containerMl != null ? containerMl() : this.containerMl,
    abvPercent: abvPercent != null ? abvPercent() : this.abvPercent,
    abvSource: abvSource != null ? abvSource() : this.abvSource,
    priceKind: priceKind ?? this.priceKind,
    paidCents: paidCents != null ? paidCents() : this.paidCents,
    billTotalCents: billTotalCents != null
        ? billTotalCents()
        : this.billTotalCents,
    paidEdited: paidEdited ?? this.paidEdited,
    isShared: isShared ?? this.isShared,
    peopleCount: peopleCount ?? this.peopleCount,
    personalMl: personalMl != null ? personalMl() : this.personalMl,
    leftoverMl: leftoverMl ?? this.leftoverMl,
    personalEdited: personalEdited ?? this.personalEdited,
  );

  /// Re-derives the user's portion and the suggested payment.
  DrinkDraft _rebalance() {
    var next = this;
    final container = containerMl;
    if (!isShared) {
      next = next._copy(personalMl: () => container, personalEdited: false);
    } else if (!personalEdited && container != null) {
      final available = container - leftoverMl;
      next = next._copy(
        personalMl: () => available <= 0 ? 0 : available ~/ peopleCount,
      );
    }
    if (isShared &&
        !paidEdited &&
        priceKind == PriceKind.informed &&
        billTotalCents != null) {
      next = next._copy(
        paidCents: () => (billTotalCents! / peopleCount).round(),
      );
    }
    return next;
  }

  /// A documented package is saved as the record's presentation; a size
  /// suggestion only fills the volume.
  DrinkDraft withPresentation(Presentation p) => _copy(
    presentationLabel: () => p.isSuggestion ? null : p.label,
    containerMl: () => p.volumeMl,
  )._rebalance();

  DrinkDraft withContainerMl(int? ml, List<Presentation> known) {
    String? label;
    for (final p in known) {
      if (!p.isSuggestion && p.volumeMl == ml) label = p.label;
    }
    return _copy(
      containerMl: () => ml,
      presentationLabel: () => label,
    )._rebalance();
  }

  /// Changing the ABV makes the user its source; the same value keeps the
  /// source it already had (label, menu, catalog).
  DrinkDraft withAbv(double? abv) => _copy(
    abvPercent: () => abv,
    abvSource: () =>
        abv == abvPercent ? abvSource : (abv == null ? null : AbvSource.typed),
  );

  DrinkDraft withShared(bool shared) => _copy(
    isShared: shared,
    personalEdited: false,
    paidEdited: false,
  )._rebalance();

  DrinkDraft withPeople(int people) => _copy(
    peopleCount: people.clamp(2, maxPeople).toInt(),
    personalEdited: false,
    paidEdited: false,
  )._rebalance();

  DrinkDraft withPersonalMl(int? ml) =>
      _copy(personalMl: () => ml, personalEdited: true);

  DrinkDraft withLeftoverMl(int ml) =>
      _copy(leftoverMl: ml < 0 ? 0 : ml)._rebalance();

  DrinkDraft withPriceKind(PriceKind kind) {
    switch (kind) {
      case PriceKind.informed:
        return _copy(
          priceKind: kind,
          paidCents: () => priceKind == PriceKind.informed ? paidCents : null,
          paidEdited: false,
        )._rebalance();
      case PriceKind.complimentary:
        return _copy(priceKind: kind, paidCents: () => 0);
      case PriceKind.unknown:
        return _copy(priceKind: kind, paidCents: () => null);
    }
  }

  DrinkDraft withPaidCents(int? cents) =>
      _copy(paidCents: () => cents, paidEdited: true);

  DrinkDraft withBillTotalCents(int? cents) =>
      _copy(billTotalCents: () => cents)._rebalance();

  /// Back to the equal split suggested from the bill total.
  DrinkDraft withSuggestedPayment() => _copy(paidEdited: false)._rebalance();

  DrinkDraft withConsumedAt(DateTime at) => _copy(consumedAt: at);

  bool _sameAsReference(List<EntryComponent> list) {
    final ref = reference;
    if (ref == null || ref.length != list.length) return false;
    for (var i = 0; i < ref.length; i++) {
      final a = ref[i];
      final b = list[i];
      if (a.name != b.name ||
          a.amount != b.amount ||
          a.unit != b.unit ||
          a.abvPercent != b.abvPercent ||
          a.productId != b.productId) {
        return false;
      }
    }
    return true;
  }

  DrinkDraft _withComponents(List<EntryComponent> list) {
    final comp = composition;
    if (comp == null) return this;
    // Without a reference (editing a saved record) any change counts as one.
    final customized = reference == null ? true : !_sameAsReference(list);
    return _copy(
      composition: comp.copyWith(
        components: list,
        customized: customized || (reference == null && comp.customized),
      ),
    );
  }

  /// Sets the amount (and optionally the unit) of a component. Nothing is
  /// converted: an amount in spoons stays in spoons.
  DrinkDraft withComponentAmount(
    int index,
    double? amount, [
    RecipeUnit? unit,
  ]) {
    final list = [...components];
    list[index] = list[index].copyWith(
      amount: () => amount,
      unit: unit,
      amountText: () => amount == null ? list[index].amountText : null,
    );
    return _withComponents(list);
  }

  DrinkDraft withComponentAbv(int index, double? abv) {
    final list = [...components];
    list[index] = list[index].copyWith(abvPercent: () => abv);
    return _withComponents(list);
  }

  /// Chooses a brand/product for an ingredient (its ABV comes along when the
  /// product has a single known one) or clears the choice with null.
  DrinkDraft withComponentProduct(int index, CatalogItem? product) {
    final list = [...components];
    list[index] = list[index].copyWith(
      productId: () => product?.id,
      productName: () => product?.displayName,
      abvPercent: () => product?.abvPercent,
    );
    return _withComponents(list);
  }

  DrinkDraft addComponent(EntryComponent component) =>
      _withComponents([...components, component]);

  DrinkDraft removeComponent(int index) {
    final list = [...components]..removeAt(index);
    return _withComponents(list);
  }

  /// ml left for the other people once the user's portion and leftovers are
  /// taken out, split among them. Null when it cannot be computed.
  int? get othersEachMl {
    if (!isShared || containerMl == null || personalMl == null) return null;
    final rest = containerMl! - personalMl! - leftoverMl;
    if (rest < 0) return null;
    return rest ~/ (peopleCount - 1);
  }

  /// Field key -> message.
  Map<String, String> get errors {
    final result = <String, String>{};
    final container = containerMl;
    if (isRecipe) {
      // The final volume of a mixed drink may stay unknown.
      if (container != null && (container <= 0 || container > 20000)) {
        result['volume'] = tr.draftVolumeInvalid;
      }
      for (var i = 0; i < components.length; i++) {
        final abv = components[i].abvPercent;
        if (abv != null && (abv < 0 || abv > 100)) {
          result['component_abv_$i'] = tr.draftAbvRange;
        }
        final qty = components[i].amount;
        if (qty != null && qty < 0)
          result['component_ml_$i'] = tr.draftAmountInvalid;
      }
    } else if (container == null || container <= 0) {
      result['volume'] = tr.draftVolumeRequired;
    } else if (container > 20000) {
      result['volume'] = tr.draftVolumeTooHigh;
    }
    final abv = abvPercent;
    if (abv != null && (abv < 0 || abv > 100)) {
      result['abv'] = tr.draftAbvRange;
    }
    if (isShared && container != null && container > 0) {
      final personal = personalMl;
      if (personal == null || personal <= 0) {
        result['personal'] = tr.draftShareRequired;
      } else if (personal + leftoverMl > container) {
        result['personal'] = tr.draftShareOver(formatMl(container));
      }
    }
    final before = notBefore;
    if (before != null && consumedAt.isBefore(before)) {
      result['time'] = tr.draftBeforeStart(formatTime(before));
    }
    final after = notAfter ?? DateTime.now().add(const Duration(minutes: 5));
    if (consumedAt.isAfter(after)) {
      result['time'] = notAfter == null
          ? tr.draftNotFuture
          : tr.draftAfterEnd(formatTime(notAfter!));
    }
    if (priceKind == PriceKind.informed && paidCents == null) {
      result['paid'] = tr.draftPaidRequired;
    }
    return result;
  }

  bool get isValid => errors.isEmpty;

  DrinkEntry toEntry({
    required String id,
    required String outingId,
    required DateTime now,
  }) {
    final container = containerMl;
    final personal = isShared ? personalMl : container;
    return DrinkEntry(
      id: existing?.id ?? id,
      outingId: existing?.outingId ?? outingId,
      consumedAt: consumedAt,
      name: name,
      category: category,
      brand: brand,
      style: style,
      presentation: presentationLabel,
      catalogItemId: catalogItemId,
      abvPercent: isRecipe ? null : abvPercent,
      abvSource: isRecipe ? null : abvSource,
      ingredients: ingredients,
      composition: composition,
      containerMl: container,
      isShared: isShared,
      peopleCount: isShared ? peopleCount : 1,
      personalMl: personal,
      leftoverMl: isShared ? leftoverMl : 0,
      priceKind: priceKind,
      paidCents: switch (priceKind) {
        PriceKind.informed => paidCents,
        PriceKind.complimentary => 0,
        PriceKind.unknown => null,
      },
      billTotalCents: isShared && priceKind == PriceKind.informed
          ? billTotalCents
          : null,
      createdAt: existing?.createdAt ?? now,
      consumerId: consumerId,
      portions: portions,
      updatedAt: now,
      entryOrigin: entryOrigin,
    );
  }
}
