import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../places/data/place_repository.dart';
import '../../places/domain/place.dart';
import '../../places/domain/place_draft.dart';
import '../../tab/data/tab_repository.dart';
import '../../tab/domain/tab_models.dart';
import '../data/outing_repository.dart';
import '../domain/outing.dart';
import '../../l10n/l10n.dart';

class StartOutingState {
  const StartOutingState({
    required this.type,
    required this.startedAt,
    this.nickname = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.place,
    this.saveAsPlace = true,
    this.budgetCents,
    this.guests = const [],
    this.submitting = false,
    this.showErrors = false,
    this.error,
    this.createdId,
  });

  final OutingType type;
  final DateTime startedAt;
  final String nickname;
  final String address;
  final String city;
  final String state;

  /// What the place picker returned (a saved place, a search result, the
  /// device point or a nickname), used instead of the inline fields.
  final PlaceDraft? place;

  /// Save the typed place for next time (ignored when [place] is chosen).
  final bool saveAsPlace;
  final int? budgetCents;

  /// Names of the people at the table besides the owner ("Você" is always in).
  final List<String> guests;
  final bool submitting;
  final bool showErrors;
  final String? error;

  /// Set once the outing exists; the page then navigates away.
  final String? createdId;

  /// Needs a saved place, or at least a nickname or an address.
  String? get placeError =>
      (place == null && nickname.trim().isEmpty && address.trim().isEmpty)
      ? tr.startPlaceError
      : null;

  String? get stateError {
    final uf = state.trim();
    if (uf.isEmpty) return null;
    return RegExp(r'^[A-Za-z]{2}$').hasMatch(uf) ? null : tr.stateTwoLetters;
  }

  StartOutingState copyWith({
    OutingType? type,
    DateTime? startedAt,
    String? nickname,
    String? address,
    String? city,
    String? state,
    PlaceDraft? Function()? place,
    bool? saveAsPlace,
    int? Function()? budgetCents,
    List<String>? guests,
    bool? submitting,
    bool? showErrors,
    String? error,
    String? createdId,
  }) => StartOutingState(
    type: type ?? this.type,
    startedAt: startedAt ?? this.startedAt,
    nickname: nickname ?? this.nickname,
    address: address ?? this.address,
    city: city ?? this.city,
    state: state ?? this.state,
    place: place != null ? place() : this.place,
    saveAsPlace: saveAsPlace ?? this.saveAsPlace,
    budgetCents: budgetCents != null ? budgetCents() : this.budgetCents,
    guests: guests ?? this.guests,
    submitting: submitting ?? this.submitting,
    showErrors: showErrors ?? this.showErrors,
    error: error,
    createdId: createdId ?? this.createdId,
  );
}

class StartOutingCubit extends Cubit<StartOutingState> {
  StartOutingCubit(this._outings, this._places, this._tabs)
    : super(StartOutingState(type: OutingType.bar, startedAt: DateTime.now()));

  final OutingRepository _outings;
  final PlaceRepository _places;
  final TabRepository _tabs;
  static const _uuid = Uuid();

  /// Saved places offered as shortcuts: recent first, then favourites.
  List<Place> get shortcuts {
    final recent = _places.recent([..._outings.ended()]);
    final favorites = _places.active().where((p) => p.favorite);
    final seen = <String>{};
    return [
      for (final p in [...favorites, ...recent])
        if (seen.add(p.id)) p,
    ];
  }

  void setType(OutingType type) => emit(state.copyWith(type: type));
  void setNickname(String v) => emit(state.copyWith(nickname: v));
  void setAddress(String v) => emit(state.copyWith(address: v));
  void setCity(String v) => emit(state.copyWith(city: v));
  void setState(String v) => emit(state.copyWith(state: v));
  void setStartedAt(DateTime v) => emit(state.copyWith(startedAt: v));
  void setSaveAsPlace(bool v) => emit(state.copyWith(saveAsPlace: v));
  void setBudgetCents(int? v) => emit(state.copyWith(budgetCents: () => v));

  /// People at the table. Same name twice is allowed (two "João"): the id, not
  /// the name, is the identity.
  void addGuest(String name) {
    final clean = name.trim();
    if (clean.isEmpty || state.guests.length >= 29) return;
    emit(state.copyWith(guests: [...state.guests, clean]));
  }

  void removeGuest(int index) {
    if (index < 0 || index >= state.guests.length) return;
    emit(
      state.copyWith(
        guests: [
          for (var i = 0; i < state.guests.length; i++)
            if (i != index) state.guests[i],
        ],
      ),
    );
  }

  /// Picks a saved place (its type becomes the outing type) or clears it.
  void selectPlace(Place? place) => emit(
    state.copyWith(
      place: () => place == null ? null : PlaceDraft.saved(place),
      type: place?.type,
    ),
  );

  /// Uses what the place picker returned.
  void choosePlace(PlaceDraft draft) =>
      emit(state.copyWith(place: () => draft, type: draft.saved?.type));

  Future<void> submit() async {
    if (state.submitting || state.createdId != null) return;
    if (state.placeError != null || state.stateError != null) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    if (state.startedAt.isAfter(
      DateTime.now().add(const Duration(minutes: 5)),
    )) {
      emit(state.copyWith(showErrors: true, error: tr.startFuture));
      return;
    }
    emit(state.copyWith(submitting: true));
    try {
      // Saved place as it is, a confirmed search result/point (saved only if
      // the person asked) or the inline nickname/address. The outing keeps
      // its own copy of the place data.
      final draft =
          state.place ??
          PlaceDraft(
            nickname: state.nickname,
            address: state.address,
            city: state.city,
            state: state.state,
            save: state.saveAsPlace,
          );
      final place = await _places.resolve(draft, state.type);

      final outing = await _outings.start(
        type: state.type,
        place: place,
        budgetCents: state.budgetCents,
        startedAt: state.startedAt,
      );
      // Every new outing is a table: "Você" plus whoever was added. The tab
      // includes the records of the outing by itself (no second write).
      final me = Participant(id: _uuid.v4(), name: tr.tabMe, isMe: true);
      final guests = [
        for (final g in state.guests) Participant(id: _uuid.v4(), name: g),
      ];
      await _tabs.update(outing.id, (_) {
        final base = TabDoc.forTable(outing.id, me);
        return base.copyWith(
          participants: [me, ...guests],
          equalIds: [me.id, for (final g in guests) g.id],
        );
      });
      emit(state.copyWith(submitting: false, createdId: outing.id));
    } on ActiveOutingExistsException {
      final active = _outings.active;
      // Recover the existing outing instead of creating a second one.
      emit(state.copyWith(submitting: false, createdId: active?.id));
    } catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          showErrors: true,
          error: tr.startFailed,
        ),
      );
    }
  }
}
