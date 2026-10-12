import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_draft.dart';
import '../domain/drink_entry.dart';

class DrinkFormState {
  const DrinkFormState({
    required this.draft,
    this.presentations = const [],
    this.showErrors = false,
    this.saving = false,
    this.saved = false,
  });

  final DrinkDraft draft;

  /// Known sizes for the chosen product (chips above the free volume field).
  final List<Presentation> presentations;
  final bool showErrors;
  final bool saving;
  final bool saved;

  DrinkFormState copyWith({
    DrinkDraft? draft,
    bool? showErrors,
    bool? saving,
    bool? saved,
  }) =>
      DrinkFormState(
        draft: draft ?? this.draft,
        presentations: presentations,
        showErrors: showErrors ?? this.showErrors,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
      );
}

class DrinkFormCubit extends Cubit<DrinkFormState> {
  DrinkFormCubit._(this._drinks, this._outingId, super.initial)
      : _entryId = _drinks.newId();

  /// New registration from a catalog item.
  factory DrinkFormCubit.forItem(
    DrinkRepository drinks,
    String outingId,
    CatalogItem item,
  ) =>
      DrinkFormCubit._(
        drinks,
        outingId,
        DrinkFormState(
          draft: DrinkDraft.fromItem(item, now: DateTime.now()),
          presentations: item.presentations,
        ),
      );

  /// Correction of an existing entry.
  factory DrinkFormCubit.forEntry(DrinkRepository drinks, DrinkEntry entry) {
    final item = drinks.itemById(entry.catalogItemId);
    return DrinkFormCubit._(
      drinks,
      entry.outingId,
      DrinkFormState(
        draft: DrinkDraft.fromEntry(entry),
        presentations: item?.presentations ?? const [],
      ),
    );
  }

  final DrinkRepository _drinks;
  final String _outingId;

  /// Stable per form, so a repeated "save" never creates a second row.
  final String _entryId;

  void _set(DrinkDraft draft) => emit(state.copyWith(draft: draft));

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
    if (state.saving || state.saved) return;
    if (!state.draft.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(saving: true));
    final entry = state.draft.toEntry(
      id: _entryId,
      outingId: _outingId,
      now: DateTime.now(),
    );
    await _drinks.save(entry);
    emit(state.copyWith(saving: false, saved: true));
  }

  Future<void> delete() async {
    final existing = state.draft.existing;
    if (existing == null) return;
    await _drinks.delete(existing.id);
    emit(state.copyWith(saved: true));
  }
}
