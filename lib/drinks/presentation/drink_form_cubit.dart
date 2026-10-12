import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../outings/domain/outing.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/common_sizes.dart';
import '../domain/drink_draft.dart';
import '../domain/drink_category.dart';
import '../domain/drink_entry.dart';
import '../domain/recipe.dart';

class DrinkFormState {
  const DrinkFormState({
    required this.draft,
    this.presentations = const [],
    this.sizesAreGeneric = false,
    this.abvVariants = const [],
    this.showErrors = false,
    this.saving = false,
    this.saved = false,
    this.deleted = false,
    this.dirty = false,
    this.error,
  });

  final DrinkDraft draft;

  /// Known sizes for the chosen product (chips above the free volume field).
  final List<Presentation> presentations;

  /// True when [presentations] are common sizes for the category, not sizes
  /// verified for this product.
  final bool sizesAreGeneric;

  /// Documented ABVs when sources disagree; the user picks one or types it.
  final List<AbvVariant> abvVariants;
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
  }) =>
      DrinkFormState(
        draft: draft ?? this.draft,
        presentations: presentations,
        sizesAreGeneric: sizesAreGeneric,
        abvVariants: abvVariants,
        showErrors: showErrors ?? this.showErrors,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
        deleted: deleted ?? this.deleted,
        dirty: dirty ?? this.dirty,
        error: error,
      );
}

class DrinkFormCubit extends Cubit<DrinkFormState> {
  DrinkFormCubit._(this._drinks, this._outingId, super.initial)
      : _entryId = _drinks.newId();

  /// New registration from a catalog item.
  factory DrinkFormCubit.forItem(
    DrinkRepository drinks,
    Outing outing,
    CatalogItem item,
  ) =>
      DrinkFormCubit._(
        drinks,
        outing.id,
        DrinkFormState(
          draft: DrinkDraft.fromItem(
            item,
            now: DateTime.now(),
            notBefore: outing.startedAt,
            notAfter: outing.endedAt,
          ),
          presentations: _sizesFor(item).list,
          sizesAreGeneric: _sizesFor(item).generic,
          abvVariants: item.abvVariants,
        ),
      );

  /// Sizes shown as chips. Documented packages are kept apart from plain
  /// suggestions; spirits get dose suggestions plus their documented bottles
  /// (a bottle is shared, a dose is what one person drinks).
  static ({List<Presentation> list, bool generic}) _sizesFor(CatalogItem item) {
    if (item.isRecipe) return (list: const <Presentation>[], generic: false);
    final documented = item.documentedPresentations;
    if (item.category == DrinkCategory.spirit) {
      return (
        list: [
          ...commonSizesFor(DrinkCategory.spirit),
          ...documented.where((p) => p.kind == PresentationKind.bottle),
        ],
        generic: true,
      );
    }
    if (documented.isNotEmpty) return (list: documented, generic: false);
    if (item.presentations.isNotEmpty) {
      return (list: item.presentations, generic: true);
    }
    return (list: commonSizesFor(item.category), generic: true);
  }

  /// Correction of an existing entry.
  factory DrinkFormCubit.forEntry(
    DrinkRepository drinks,
    Outing outing,
    DrinkEntry entry,
  ) {
    final item = drinks.itemById(entry.catalogItemId);
    return DrinkFormCubit._(
      drinks,
      entry.outingId,
      DrinkFormState(
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
        sizesAreGeneric: entry.isMixed ? false : (item == null || _sizesFor(item).generic),
        abvVariants: item?.abvVariants ?? const [],
      ),
    );
  }

  final DrinkRepository _drinks;
  final String _outingId;

  /// Stable per form, so a repeated "save" never creates a second row.
  final String _entryId;

  void _set(DrinkDraft draft) => emit(state.copyWith(draft: draft, dirty: true));

  void selectPresentation(Presentation p) {
    var draft = state.draft.withPresentation(p);
    // A spirit bottle is meant to be shared; a dose is one person's.
    if (draft.category == DrinkCategory.spirit &&
        !p.isSuggestion &&
        p.kind == PresentationKind.bottle) {
      draft = draft.withShared(true);
    }
    _set(draft);
  }

  void setVolume(int? ml) =>
      _set(state.draft.withContainerMl(ml, state.presentations));

  void setAbv(double? abv) => _set(state.draft.withAbv(abv));
  void setShared(bool v) => _set(state.draft.withShared(v));
  void setPeople(int n) => _set(state.draft.withPeople(n));
  void setPersonalMl(int? ml) => _set(state.draft.withPersonalMl(ml));
  void setLeftoverMl(int ml) => _set(state.draft.withLeftoverMl(ml));
  void setPriceKind(PriceKind k) => _set(state.draft.withPriceKind(k));
  void setPaidCents(int? c) => _set(state.draft.withPaidCents(c));
  void setBillTotalCents(int? c) => _set(state.draft.withBillTotalCents(c));
  void suggestPayment() => _set(state.draft.withSuggestedPayment());
  void setConsumedAt(DateTime at) => _set(state.draft.withConsumedAt(at));

  // ---- Mixed drinks ------------------------------------------------------------

  void setComponentAmount(int i, double? ml) =>
      _set(state.draft.withComponentAmount(i, ml));
  void setComponentAbv(int i, double? abv) =>
      _set(state.draft.withComponentAbv(i, abv));
  void pickComponentProduct(int i, CatalogItem? product) =>
      _set(state.draft.withComponentProduct(i, product));
  void removeComponent(int i) => _set(state.draft.removeComponent(i));
  void addComponent(String name, {required bool alcoholic}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _set(state.draft.addComponent(
      EntryComponent(name: trimmed, alcoholic: alcoholic),
    ));
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
      return 'Não foi possível salvar a receita.';
    }
  }

  Future<void> submit() async {
    if (state.saving || state.saved || state.deleted) return;
    if (!state.draft.isValid) {
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
      await _drinks.save(entry);
      emit(state.copyWith(saving: false, saved: true));
    } catch (e) {
      if (kDebugMode) debugPrint('[drink form] save failed: $e');
      emit(state.copyWith(
        saving: false,
        error: 'Não foi possível salvar. Nada foi perdido, tente de novo.',
      ));
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
      emit(state.copyWith(
        saving: false,
        error: 'Não foi possível excluir. Tente de novo.',
      ));
    }
  }
}
