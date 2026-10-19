import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../outings/domain/outing.dart';
import '../../tab/data/tab_repository.dart';
import '../../tab/domain/tab_calc.dart';
import '../../tab/domain/tab_models.dart';
import '../domain/bottle_people.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/common_sizes.dart';
import '../domain/drink_draft.dart';
import '../domain/drink_category.dart';
import '../domain/drink_entry.dart';
import '../domain/price_history.dart';
import '../domain/recipe.dart';
import '../../l10n/l10n.dart';

/// The saved price could also go to equal drinks of the same outing. Nothing is
/// applied without the person choosing.
class PriceOffer {
  const PriceOffer({
    required this.saved,
    required this.unpriced,
    required this.differing,
  });

  /// The record just saved (its price is the one on offer).
  final DrinkEntry saved;

  /// Equal records with no price yet.
  final List<DrinkEntry> unpriced;

  /// Equal records that already have a DIFFERENT price (kind or value).
  final List<DrinkEntry> differing;

  int get total => unpriced.length + differing.length;
}

/// One line of the "what changes" preview of an edited shared bottle.
class BottleImpactRow {
  const BottleImpactRow({
    required this.key,
    required this.mlBefore,
    required this.mlAfter,
    required this.wasIn,
    required this.isIn,
    required this.costBefore,
    required this.costAfter,
  });

  final String key;
  final int? mlBefore;
  final int? mlAfter;
  final bool wasIn;
  final bool isIn;
  final int costBefore;
  final int costAfter;

  bool get changed =>
      wasIn != isIn || mlBefore != mlAfter || costBefore != costAfter;
}

class DrinkFormState {
  const DrinkFormState({
    required this.draft,
    this.presentations = const [],
    this.sizesAreGeneric = false,
    this.abvVariants = const [],
    this.bottles = const [],
    this.suggestion = const PriceSuggestion(),
    this.suggestionAtPlace = false,
    this.advertisedCents,
    this.showErrors = false,
    this.saving = false,
    this.saved = false,
    this.deleted = false,
    this.dirty = false,
    this.error,
    this.consumerPending = false,
    this.people,
  });

  final DrinkDraft draft;

  /// Who takes part in an already registered shared bottle (volume and cost
  /// kept apart). Null for any other record.
  final BottlePeople? people;

  /// The outing has people and the form was opened without saying whose drink
  /// it is: the person must be chosen (nothing is assumed) before saving.
  final bool consumerPending;

  /// Known sizes for the chosen product (chips above the free volume field).
  final List<Presentation> presentations;

  /// True when [presentations] are common sizes for the category, not sizes
  /// verified for this product.
  final bool sizesAreGeneric;

  /// Documented ABVs when sources disagree; the user picks one or types it.
  final List<AbvVariant> abvVariants;

  /// Documented bottles of a spirit. They are packages, not doses: they only
  /// fill the bottle volume once the user marks the drink as shared.
  final List<Presentation> bottles;

  /// The user's own last price for the same drink and size (never a market
  /// average). It only becomes the price when the user confirms it.
  final PriceSuggestion suggestion;

  /// The suggestion comes from records at this place (otherwise, from this
  /// outing).
  final bool suggestionAtPlace;

  /// Price a menu advertised for this outing-only item. It only becomes the
  /// price when the user taps to confirm it; it is not history.
  final int? advertisedCents;
  final bool showErrors;
  final bool saving;
  final bool saved;
  final bool deleted;

  /// The user changed something; leaving would lose it.
  final bool dirty;

  /// Short message after a failed save; the form content is kept.
  final String? error;

  DrinkFormState copyWith({
    DrinkDraft? draft,
    bool? showErrors,
    bool? saving,
    bool? saved,
    bool? deleted,
    bool? dirty,
    String? error,
    PriceSuggestion? suggestion,
    bool? consumerPending,
    BottlePeople? people,
  }) => DrinkFormState(
    people: people ?? this.people,
    consumerPending: consumerPending ?? this.consumerPending,
    draft: draft ?? this.draft,
    presentations: presentations,
    sizesAreGeneric: sizesAreGeneric,
    abvVariants: abvVariants,
    bottles: bottles,
    suggestion: suggestion ?? this.suggestion,
    suggestionAtPlace: suggestionAtPlace,
    advertisedCents: advertisedCents,
    showErrors: showErrors ?? this.showErrors,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    deleted: deleted ?? this.deleted,
    dirty: dirty ?? this.dirty,
    error: error,
  );
}

class DrinkFormCubit extends Cubit<DrinkFormState> {
  DrinkFormCubit._(
    this._drinks,
    this._outingId,
    this._candidates,
    super.initial, {
    String? entryId,
    this.reviewNote,
    TabRepository? tabs,
    BottlePeople? initialPeople,
  }) : _entryId = entryId ?? _drinks.newId(),
       _tabs = tabs,
       _initialPeople = initialPeople;

  final TabRepository? _tabs;

  /// The bottle's people as they were when the form opened.
  final BottlePeople? _initialPeople;

  /// Shown on top of the form when it reviews a lock-screen tap.
  final String? reviewNote;

  static ComparableKey _keyOf(DrinkDraft d) => ComparableKey(
    item: d.catalogItemId ?? 'name:${d.name}',
    containerMl: d.containerMl,
    presentation: d.presentationLabel,
    shared: d.isShared,
  );

  /// Records at the same place (or in the same outing) to look prices up in.
  final List<DrinkEntry> _candidates;

  /// New registration from a catalog item.
  factory DrinkFormCubit.forItem(
    DrinkRepository drinks,
    Outing outing,
    CatalogItem item,
    List<DrinkEntry> candidates, {
    String? consumerId,
    bool consumerPending = false,
  }) {
    final now = DateTime.now();
    final end = outing.endedAt;
    final draft = DrinkDraft.fromItem(
      item,
      // A drink added to a finished outing defaults to its end time.
      now: (end != null && now.isAfter(end)) ? end : now,
      notBefore: outing.startedAt,
      notAfter: outing.endedAt,
    ).withConsumer(consumerId);
    return DrinkFormCubit._(
      drinks,
      outing.id,
      candidates,
      DrinkFormState(
        consumerPending: consumerPending,
        draft: draft,
        suggestionAtPlace: outing.placeId != null,
        suggestion: suggestPrice(candidates, _keyOf(draft)),
        advertisedCents: item.advertisedCents,
        presentations: _sizesFor(item).list,
        sizesAreGeneric: _sizesFor(item).generic,
        abvVariants: item.abvVariants,
        bottles: _bottlesOf(item),
      ),
    );
  }

  static List<Presentation> _bottlesOf(CatalogItem item) =>
      item.category == DrinkCategory.spirit
      ? item.documentedPresentations
            .where((p) => p.kind == PresentationKind.bottle)
            .toList()
      : const [];

  /// Sizes shown as chips. Documented packages are kept apart from plain
  /// suggestions; spirits get dose suggestions plus their documented bottles
  /// (a bottle is shared, a dose is what one person drinks).
  static ({List<Presentation> list, bool generic}) _sizesFor(CatalogItem item) {
    if (item.isRecipe) return (list: const <Presentation>[], generic: false);
    final documented = item.documentedPresentations;
    if (item.category == DrinkCategory.spirit) {
      // Doses only: the bottle is the package, not what one person drinks.
      return (list: commonSizesFor(DrinkCategory.spirit), generic: true);
    }
    if (documented.isNotEmpty) return (list: documented, generic: false);
    if (item.presentations.isNotEmpty) {
      return (list: item.presentations, generic: true);
    }
    return (list: commonSizesFor(item.category), generic: true);
  }

  /// Review of a lock-screen "Mais uma" that could not be saved on its own:
  /// a NEW record prefilled from [template], saved with [entryId] (derived
  /// from the command, so it can never be saved twice) in [outing], at [at]
  /// unless the person changes it within the outing's period.
  factory DrinkFormCubit.forReview(
    DrinkRepository drinks,
    Outing outing,
    DrinkEntry template,
    List<DrinkEntry> candidates, {
    required String entryId,
    required DateTime at,
    required String note,
    required EntryOrigin origin,
  }) {
    final item = drinks.itemById(template.catalogItemId);
    return DrinkFormCubit._(
      drinks,
      outing.id,
      candidates,
      DrinkFormState(
        draft: DrinkDraft.fromEntry(
          template,
          notBefore: outing.startedAt,
          notAfter: outing.endedAt,
          asNew: true,
          consumedAt: at,
          origin: origin,
        ),
        presentations: template.isMixed
            ? const []
            : (item != null
                  ? _sizesFor(item).list
                  : commonSizesFor(template.category)),
        sizesAreGeneric: template.isMixed
            ? false
            : (item == null || _sizesFor(item).generic),
        abvVariants: item?.abvVariants ?? const [],
        bottles: item == null ? const [] : _bottlesOf(item),
        // Shown with its errors at once: a time outside the outing must be
        // fixed before saving.
        showErrors: true,
      ),
      entryId: entryId,
      reviewNote: note,
    );
  }

  /// Correction of an existing entry.
  factory DrinkFormCubit.forEntry(
    DrinkRepository drinks,
    Outing outing,
    DrinkEntry entry,
    List<DrinkEntry> candidates, {
    TabRepository? tabs,
  }) {
    BottlePeople? people;
    if (tabs != null && entry.isShared && entry.portions != null) {
      final doc = tabs.load(entry.outingId);
      people = BottlePeople.fromEntry(
        entry,
        assign: doc.linkFor(entry.id)?.assign,
        ownerId: doc.me?.id,
      );
    }
    final item = drinks.itemById(entry.catalogItemId);
    final others = [
      for (final c in candidates)
        if (c.id != entry.id) c,
    ];
    return DrinkFormCubit._(
      drinks,
      entry.outingId,
      others,
      DrinkFormState(
        people: people,
        draft: DrinkDraft.fromEntry(
          entry,
          notBefore: outing.startedAt,
          notAfter: outing.endedAt,
        ),
        presentations: entry.isMixed
            ? const []
            : (item != null
                  ? _sizesFor(item).list
                  : commonSizesFor(entry.category)),
        sizesAreGeneric: entry.isMixed
            ? false
            : (item == null || _sizesFor(item).generic),
        abvVariants: item?.abvVariants ?? const [],
        bottles: item == null ? const [] : _bottlesOf(item),
      ),
      tabs: tabs,
      initialPeople: people,
    );
  }

  final DrinkRepository _drinks;
  final String _outingId;

  String get outingId => _outingId;

  /// Whose drink it is (null = the owner). Chosen explicitly on a table.
  void setConsumer(String? id) => emit(
    state.copyWith(
      draft: state.draft.withConsumer(id),
      dirty: true,
      consumerPending: false,
    ),
  );

  /// Corrects how much one person of a shared bottle drank (null = unknown).
  void setPortion(String key, int? ml) {
    final people = state.people;
    if (people == null) {
      final current = state.draft.portions;
      if (current == null) return;
      _set(state.draft.withPortions({...current, key: ml}));
      return;
    }
    _setPeople(people.withPortion(key, ml));
  }

  /// Keys (portion keys) of the people of the outing who can still join this
  /// bottle: present on the tab of the SAME outing and not already in it.
  List<String> get candidatesToAdd {
    final people = state.people;
    final tabs = _tabs;
    if (people == null || tabs == null) return const [];
    final doc = tabs.load(_outingId);
    return [
      for (final p in doc.present)
        if (!people.has(p.isMe ? ownerPortionKey : p.id)) p.isMe ? ownerPortionKey : p.id,
    ];
  }

  /// Adds someone of this outing. Their volume starts unknown and nobody
  /// else's volume changes.
  void addPerson(String key) {
    final people = state.people;
    if (people == null || !candidatesToAdd.contains(key)) return;
    _setPeople(people.add(key));
  }

  /// Removes someone, placing their volume and cost share as chosen.
  /// Throws [ArgumentError] when something is left unresolved.
  void removePerson(
    String key, {
    VolumeFate? volume,
    String? volumeTo,
    MoneyFate? money,
    String? moneyTo,
  }) {
    final people = state.people;
    if (people == null) return;
    _setPeople(
      people.remove(
        key,
        volume: volume,
        volumeTo: volumeTo,
        money: money,
        moneyTo: moneyTo,
      ),
    );
  }

  /// Weight of one person in the cost split (0 = does not pay any of it).
  void setWeight(String key, int weight) {
    final people = state.people;
    if (people == null) return;
    _setPeople(people.withWeight(key, weight));
  }

  void _setPeople(BottlePeople next) {
    var draft = state.draft
        .withPortions(next.portions)
        .withLeftoverMl(next.leftoverMl);
    // The owner's own cost follows the split; without a known bill total it
    // only changes when the owner stops paying.
    final bill = draft.billTotalCents;
    if (draft.priceKind == PriceKind.informed) {
      final owner = next.has(ownerPortionKey) ? next.weightOf(ownerPortionKey) : 0;
      if (owner <= 0) {
        draft = draft.withPaidCents(0);
      } else if (bill != null) {
        draft = draft.withPaidCents(next.costShares(bill)[ownerPortionKey] ?? 0);
      }
    }
    emit(
      state.copyWith(
        draft: draft,
        people: next,
        dirty: true,
        suggestion: suggestPrice(_candidates, _keyOf(draft)),
      ),
    );
  }

  /// The bottle's people or cost split differ from what was opened.
  bool get peopleChanged {
    final now = state.people;
    final before = _initialPeople;
    if (now == null || before == null) return false;
    if (!mapEquals(now.portions, before.portions) ||
        now.leftoverMl != before.leftoverMl) {
      return true;
    }
    return !mapEquals(
      {for (final k in now.keys) k: now.weightOf(k)},
      {for (final k in before.keys) k: before.weightOf(k)},
    );
  }

  /// Per person, what changes if the form is saved now: volume and share of
  /// the tab (service and discount included), before and after. Null when the
  /// bottle is not being edited as a table bottle.
  List<BottleImpactRow>? impact() {
    final people = state.people;
    final before = _initialPeople;
    final tabs = _tabs;
    final existing = state.draft.existing;
    if (people == null || before == null || tabs == null || existing == null) {
      return null;
    }
    final doc = tabs.load(_outingId);
    final entries = tabs.entriesOf(_outingId);
    final draftEntry = state.draft.toEntry(
      id: existing.id,
      outingId: _outingId,
      now: DateTime.now(),
    );
    final link = doc.linkFor(existing.id) ?? TabLink(entryId: existing.id);
    final nextLink = link.copyWith(assign: () => people.toLinkAssign(doc.me?.id));
    final nextDoc = doc.copyWith(
      links: [
        for (final l in doc.links)
          if (l.entryId != existing.id) l,
        nextLink,
      ],
    );
    final a = TabCalculator.compute(doc, entries);
    final b = TabCalculator.compute(nextDoc, {...entries, existing.id: draftEntry});
    String idOf(String key) =>
        key == ownerPortionKey ? (doc.me?.id ?? key) : key;
    final keys = <String>{...before.keys, ...people.keys};
    return [
      for (final k in keys)
        BottleImpactRow(
          key: k,
          mlBefore: before.portions[k],
          mlAfter: people.portions[k],
          wasIn: before.has(k),
          isIn: people.has(k),
          costBefore: a.shareOf(idOf(k)),
          costAfter: b.shareOf(idOf(k)),
        ),
    ];
  }

  /// Stable per form, so a repeated "save" never creates a second row.
  final String _entryId;

  void _set(DrinkDraft draft) => emit(
    state.copyWith(
      draft: draft,
      dirty: true,
      suggestion: suggestPrice(_candidates, _keyOf(draft)),
    ),
  );

  /// The user confirmed the suggested price (their own last paid value).
  void applySuggestedPaid() {
    final cents = state.suggestion.paidCents;
    if (cents == null) return;
    _set(state.draft.withPriceKind(PriceKind.informed).withPaidCents(cents));
  }

  /// The user confirmed the suggested package total (shared drinks).
  void applySuggestedTotal() {
    final cents = state.suggestion.totalCents;
    if (cents == null) return;
    _set(
      state.draft.withPriceKind(PriceKind.informed).withBillTotalCents(cents),
    );
  }

  /// The user confirmed the menu's advertised price as what they paid (or as
  /// the bill total when the drink is shared).
  void applyAdvertised() {
    final cents = state.advertisedCents;
    if (cents == null) return;
    final d = state.draft.withPriceKind(PriceKind.informed);
    _set(d.isShared ? d.withBillTotalCents(cents) : d.withPaidCents(cents));
  }

  void selectPresentation(Presentation p) =>
      _set(state.draft.withPresentation(p));

  void setVolume(int? ml) =>
      _set(state.draft.withContainerMl(ml, state.presentations));

  void setAbv(double? abv) => _set(state.draft.withAbv(abv));
  void setShared(bool v) => _set(state.draft.withShared(v));
  void setPeople(int n) => _set(state.draft.withPeople(n));
  void setPersonalMl(int? ml) => _set(state.draft.withPersonalMl(ml));
  void setLeftoverMl(int ml) {
    final people = state.people;
    if (people != null) {
      _setPeople(people.copyWith(leftoverMl: ml < 0 ? 0 : ml));
      return;
    }
    _set(state.draft.withLeftoverMl(ml));
  }
  void setPriceKind(PriceKind k) => _set(state.draft.withPriceKind(k));
  void setPaidCents(int? c) => _set(state.draft.withPaidCents(c));
  void setBillTotalCents(int? c) => _set(state.draft.withBillTotalCents(c));
  void suggestPayment() => _set(state.draft.withSuggestedPayment());
  void setConsumedAt(DateTime at) => _set(state.draft.withConsumedAt(at));

  void setComponentAmount(int i, double? amount, [RecipeUnit? unit]) =>
      _set(state.draft.withComponentAmount(i, amount, unit));
  void setComponentUnit(int i, RecipeUnit unit) => _set(
    state.draft.withComponentAmount(i, state.draft.components[i].amount, unit),
  );
  void setComponentAbv(int i, double? abv) =>
      _set(state.draft.withComponentAbv(i, abv));
  void pickComponentProduct(int i, CatalogItem? product) =>
      _set(state.draft.withComponentProduct(i, product));
  void removeComponent(int i) => _set(state.draft.removeComponent(i));
  void addComponent(String name, {required bool alcoholic}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _set(
      state.draft.addComponent(
        EntryComponent(name: trimmed, alcoholic: alcoholic),
      ),
    );
  }

  /// Products (brands) that can fill an ingredient with this role.
  List<CatalogItem> productsForRole(String role) => [
    for (final i in _drinks.catalog())
      if (i.roles.contains(role)) i,
  ];

  /// Saves the composition as the user's own reusable recipe. Returns an
  /// error message, or null on success.
  Future<String?> saveAsMyRecipe(String name) async {
    try {
      await _drinks.saveCustomRecipe(
        name: name,
        components: state.draft.components,
      );
      return null;
    } on ArgumentError catch (e) {
      return '${e.message}';
    } catch (_) {
      return tr.formSaveRecipeFailed;
    }
  }

  DrinkEntry? _saved;

  /// After a successful save: equal drinks in this outing that the saved price
  /// could be applied to, or null when it has no price or there is nothing to
  /// offer. Records already at that exact price are left out.
  PriceOffer? priceOffer() {
    final saved = _saved;
    if (saved == null || !saved.hasPrice) return null;
    if (saved.priceKind == PriceKind.informed && (saved.paidCents ?? 0) <= 0) {
      return null;
    }
    final unpriced = <DrinkEntry>[];
    final differing = <DrinkEntry>[];
    for (final e in _drinks.equivalentsOf(saved)) {
      if (!e.hasPrice) {
        unpriced.add(e);
      } else if (e.priceKind != saved.priceKind ||
          e.effectivePaidCents != saved.effectivePaidCents) {
        differing.add(e);
      }
    }
    if (unpriced.isEmpty && differing.isEmpty) return null;
    return PriceOffer(saved: saved, unpriced: unpriced, differing: differing);
  }

  /// Applies the offered price to the records without price and, only when
  /// [replaceExisting], also to those that had another one. Returns how many
  /// records changed. Only the payment changes (never volumes or the bill total).
  Future<int> applyPriceOffer(
    PriceOffer offer, {
    required bool replaceExisting,
  }) async {
    final targets = [
      ...offer.unpriced,
      if (replaceExisting) ...offer.differing,
    ];
    await _drinks.applyPrices({
      for (final e in targets)
        e.id: (kind: offer.saved.priceKind, paidCents: offer.saved.paidCents),
    });
    return targets.length;
  }

  Future<void> submit() async {
    if (state.saving || state.saved || state.deleted) return;
    if (state.consumerPending || !state.draft.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(saving: true));
    try {
      final entry = state.draft.toEntry(
        id: _entryId,
        outingId: _outingId,
        now: DateTime.now(),
      );
      // The tab's split goes first: if the app stops in between, the bottle
      // still has its old people and the new split only names the same total.
      final people = state.people;
      final tabs = _tabs;
      if (people != null && tabs != null && peopleChanged) {
        final ownerId = tabs.load(_outingId).me?.id;
        await tabs.update(_outingId, (doc) {
          final link = doc.linkFor(entry.id) ?? TabLink(entryId: entry.id);
          final next = link.copyWith(assign: () => people.toLinkAssign(ownerId));
          return doc.copyWith(
            links: [
              for (final l in doc.links)
                if (l.entryId != entry.id) l,
              next,
            ],
          );
        });
      }
      await _drinks.save(entry);
      _saved = entry;
      emit(state.copyWith(saving: false, saved: true));
    } catch (e) {
      if (kDebugMode) debugPrint('[drink form] save failed: $e');
      emit(state.copyWith(saving: false, error: tr.formSaveFailed));
    }
  }

  Future<void> delete() async {
    final existing = state.draft.existing;
    if (existing == null || state.saving || state.deleted) return;
    emit(state.copyWith(saving: true));
    try {
      await _drinks.delete(existing.id);
      emit(state.copyWith(saving: false, deleted: true));
    } catch (e) {
      if (kDebugMode) debugPrint('[drink form] delete failed: $e');
      emit(state.copyWith(saving: false, error: tr.formDeleteFailed));
    }
  }
}
