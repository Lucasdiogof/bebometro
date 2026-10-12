import 'catalog_item.dart';
import 'drink_category.dart';
import 'drink_entry.dart';

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
  });

  factory DrinkDraft.fromItem(CatalogItem item, {required DateTime now}) {
    final first = item.presentations.isEmpty ? null : item.presentations.first;
    return DrinkDraft(
      name: item.name,
      category: item.category,
      brand: item.brand,
      style: item.style,
      catalogItemId: item.id,
      ingredients: item.ingredients,
      origin: item.origin,
      note: item.note,
      consumedAt: now,
      presentationLabel: first?.label,
      containerMl: first?.volumeMl,
      abvPercent: item.abvPercent,
      personalMl: first?.volumeMl,
    );
  }

  factory DrinkDraft.fromEntry(DrinkEntry e) => DrinkDraft(
        name: e.name,
        category: e.category,
        brand: e.brand,
        style: e.style,
        catalogItemId: e.catalogItemId,
        ingredients: e.ingredients,
        consumedAt: e.consumedAt,
        presentationLabel: e.presentation,
        containerMl: e.containerMl,
        abvPercent: e.abvPercent,
        priceKind: e.priceKind,
        paidCents: e.paidCents,
        billTotalCents: e.billTotalCents,
        paidEdited: true,
        isShared: e.isShared,
        peopleCount: e.peopleCount < 2 ? 2 : e.peopleCount,
        personalMl: e.personalMl,
        leftoverMl: e.leftoverMl,
        personalEdited: true,
        existing: e,
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

  static const maxPeople = 30;

  bool get isEditing => existing != null;

  DrinkDraft _copy({
    String? Function()? presentationLabel,
    int? Function()? containerMl,
    double? Function()? abvPercent,
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
  }) =>
      DrinkDraft(
        name: name,
        category: category,
        brand: brand,
        style: style,
        catalogItemId: catalogItemId,
        ingredients: ingredients,
        origin: origin,
        note: note,
        existing: existing,
        consumedAt: consumedAt ?? this.consumedAt,
        presentationLabel: presentationLabel != null
            ? presentationLabel()
            : this.presentationLabel,
        containerMl: containerMl != null ? containerMl() : this.containerMl,
        abvPercent: abvPercent != null ? abvPercent() : this.abvPercent,
        priceKind: priceKind ?? this.priceKind,
        paidCents: paidCents != null ? paidCents() : this.paidCents,
        billTotalCents:
            billTotalCents != null ? billTotalCents() : this.billTotalCents,
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

  DrinkDraft withPresentation(Presentation p) => _copy(
        presentationLabel: () => p.label,
        containerMl: () => p.volumeMl,
      )._rebalance();

  DrinkDraft withContainerMl(int? ml, List<Presentation> known) {
    String? label;
    for (final p in known) {
      if (p.volumeMl == ml) label = p.label;
    }
    return _copy(containerMl: () => ml, presentationLabel: () => label)
        ._rebalance();
  }

  DrinkDraft withAbv(double? abv) => _copy(abvPercent: () => abv);

  DrinkDraft withShared(bool shared) =>
      _copy(isShared: shared, personalEdited: false, paidEdited: false)
          ._rebalance();

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
  DrinkDraft withSuggestedPayment() =>
      _copy(paidEdited: false)._rebalance();

  DrinkDraft withConsumedAt(DateTime at) => _copy(consumedAt: at);

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
    if (container == null || container <= 0) {
      result['volume'] = 'Informe o volume em ml';
    } else if (container > 20000) {
      result['volume'] = 'Volume alto demais';
    }
    final abv = abvPercent;
    if (abv != null && (abv < 0 || abv > 100)) {
      result['abv'] = 'O teor vai de 0 a 100%';
    }
    if (isShared && container != null && container > 0) {
      final personal = personalMl;
      if (personal == null || personal <= 0) {
        result['personal'] = 'Informe a sua parte em ml';
      } else if (personal + leftoverMl > container) {
        result['personal'] =
            'Sua parte + sobra passam do volume (${container}ml)';
      }
    }
    if (priceKind == PriceKind.informed && paidCents == null) {
      result['paid'] = 'Informe o valor ou escolha outra opção';
    }
    return result;
  }

  bool get isValid => errors.isEmpty;

  DrinkEntry toEntry({
    required String id,
    required String outingId,
    required DateTime now,
  }) {
    final container = containerMl!;
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
      abvPercent: abvPercent,
      ingredients: ingredients,
      containerMl: container,
      isShared: isShared,
      peopleCount: isShared ? peopleCount : 1,
      personalMl: isShared ? personalMl! : container,
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
      updatedAt: now,
    );
  }
}
