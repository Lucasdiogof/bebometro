import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../outings/domain/outing.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/common_sizes.dart';
import '../domain/drink_draft.dart';
import '../domain/drink_entry.dart';

class DrinkFormState {
  const DrinkFormState({
    required this.draft,
    this.presentations = const [],
    this.sizesAreGeneric = false,
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
          presentations: item.presentations.isEmpty
              ? commonSizesFor(item.category)
              : item.presentations,
          sizesAreGeneric: item.presentations.isEmpty,
        ),
      );

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
        presentations: (item != null && item.presentations.isNotEmpty)
            ? item.presentations
            : commonSizesFor(entry.category),
        sizesAreGeneric: item == null || item.presentations.isEmpty,
      ),
    );
  }

  final DrinkRepository _drinks;
  final String _outingId;

  /// Stable per form, so a repeated "save" never creates a second row.
  final String _entryId;

  void _set(DrinkDraft draft) => emit(state.copyWith(draft: draft, dirty: true));

  void selectPresentation(Presentation p) =>
      _set(state.draft.withPresentation(p));

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
