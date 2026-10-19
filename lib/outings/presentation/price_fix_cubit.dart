import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/domain/price_history.dart';
import '../../l10n/l10n.dart';
import '../../core/utils/formatters.dart';
import '../../drinks/domain/presentation_label.dart';
import '../../tab/data/tab_repository.dart';
import '../../tab/domain/tab_models.dart';

/// Records that are the same drink and size, listed together.
class PriceFixGroup {
  const PriceFixGroup(this.label, this.entries);

  final String label;
  final List<DrinkEntry> entries;
}

/// One line of the preview shown before a batch is saved.
class PricePreviewRow {
  const PricePreviewRow({
    required this.entry,
    required this.before,
    required this.after,
    required this.replaces,
  });

  final DrinkEntry entry;
  final String before;
  final String after;

  /// The record already had a price that will be replaced (only possible when
  /// the user explicitly selected records that already had one).
  final bool replaces;
}

class PriceFixState {
  const PriceFixState({
    this.groups = const [],
    this.selected = const {},
    this.includePriced = false,
    this.priceCents,
    this.complimentary = false,
    this.saving = false,
  });

  final List<PriceFixGroup> groups;
  final Set<String> selected;

  /// Also list (and allow selecting) records that already have a price.
  final bool includePriced;
  final int? priceCents;

  /// Apply "cortesia" (R$ 0, not the same as unknown) instead of a value.
  final bool complimentary;
  final bool saving;

  bool get canApply =>
      selected.isNotEmpty &&
      (complimentary || (priceCents ?? 0) > 0) &&
      !saving;

  PriceFixState copyWith({
    List<PriceFixGroup>? groups,
    Set<String>? selected,
    bool? includePriced,
    int? Function()? priceCents,
    bool? complimentary,
    bool? saving,
  }) => PriceFixState(
    groups: groups ?? this.groups,
    selected: selected ?? this.selected,
    includePriced: includePriced ?? this.includePriced,
    priceCents: priceCents != null ? priceCents() : this.priceCents,
    complimentary: complimentary ?? this.complimentary,
    saving: saving ?? this.saving,
  );
}

/// Quick edit of missing prices in the summary: one by one, or one price for
/// several equivalent records with a preview before saving. Values already
/// informed are only touched when the user explicitly includes and selects
/// them. Consumption is never changed, and for shared drinks the value is
/// what the user paid, not the bottle price.
class PriceFixCubit extends Cubit<PriceFixState> {
  PriceFixCubit(this.outingId, this._drinks, [this._tabs])
    : super(const PriceFixState()) {
    _sub = _drinks.changes.listen((_) => _load());
    _load();
  }

  final String outingId;
  final DrinkRepository _drinks;
  final TabRepository? _tabs;
  late final StreamSubscription<void> _sub;

  void _load() {
    final all = _drinks.entriesFor(outingId);
    final visible = [
      for (final e in all)
        if (state.includePriced || !e.hasPrice) e,
    ];
    // Equal drinks of different people are different groups: a guest's price
    // is never batch-applied to the owner's identical drink.
    final doc = _tabs?.load(outingId);
    final byKey = <(ComparableKey, String?), List<DrinkEntry>>{};
    for (final e in visible) {
      byKey.putIfAbsent((ComparableKey.of(e), e.consumerId), () => []).add(e);
    }
    final groups = [
      for (final list in byKey.values)
        PriceFixGroup(_label(list.first, doc), list),
    ];
    final ids = {for (final e in visible) e.id};
    emit(
      state.copyWith(
        groups: groups,
        selected: state.selected.intersection(ids),
      ),
    );
  }

  static String _label(DrinkEntry e, TabDoc? doc) {
    final size =
        (e.presentation == null
            ? null
            : localizePresentation(e.presentation!)) ??
        (e.containerMl == null ? null : formatMl(e.containerMl!));
    final who = (doc != null && doc.participants.length > 1 && !e.isShared)
        ? (e.consumerId == null
              ? (doc.me?.displayName ?? tr.tabMe)
              : (doc.participant(e.consumerId!)?.displayName ??
                    tr.ordersUnassigned))
        : null;
    return [e.name, ?size, if (e.isShared) tr.drinkShared, ?who].join(' · ');
  }

  void setIncludePriced(bool v) {
    emit(state.copyWith(includePriced: v));
    _load();
  }

  void toggle(String id) {
    final next = {...state.selected};
    if (!next.remove(id)) next.add(id);
    emit(state.copyWith(selected: next));
  }

  void selectGroup(PriceFixGroup g, bool select) {
    final next = {...state.selected};
    for (final e in g.entries) {
      if (select) {
        next.add(e.id);
      } else {
        next.remove(e.id);
      }
    }
    emit(state.copyWith(selected: next));
  }

  void setPrice(int? cents) => emit(state.copyWith(priceCents: () => cents));
  void setComplimentary(bool v) => emit(state.copyWith(complimentary: v));

  String _priceText(DrinkEntry e) => switch (e.priceKind) {
    PriceKind.informed => _money(e.paidCents ?? 0),
    PriceKind.complimentary => tr.priceComplimentary,
    PriceKind.unknown => tr.priceNone,
  };

  static String _money(int cents) => formatCents(cents);

  /// What would change, to show before saving.
  List<PricePreviewRow> preview() {
    final after = state.complimentary
        ? tr.priceComplimentary
        : _money(state.priceCents ?? 0);
    return [
      for (final g in state.groups)
        for (final e in g.entries)
          if (state.selected.contains(e.id))
            PricePreviewRow(
              entry: e,
              before: _priceText(e),
              after: after,
              replaces: e.hasPrice,
            ),
    ];
  }

  Future<void> apply() async {
    if (!state.canApply) return;
    emit(state.copyWith(saving: true));
    final kind = state.complimentary
        ? PriceKind.complimentary
        : PriceKind.informed;
    await _drinks.applyPrices({
      for (final id in state.selected)
        id: (kind: kind, paidCents: state.complimentary ? 0 : state.priceCents),
    });
    emit(state.copyWith(saving: false, selected: <String>{}));
    _load();
  }

  /// One record on its own (no batch preview needed).
  Future<void> applyTo(
    DrinkEntry e, {
    int? cents,
    bool complimentary = false,
  }) => _drinks.applyPrices({
    e.id: (
      kind: complimentary ? PriceKind.complimentary : PriceKind.informed,
      paidCents: complimentary ? 0 : cents,
    ),
  });

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
