import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/price_history.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';
import '../data/place_repository.dart';
import '../domain/place.dart';

class PlaceRow {
  const PlaceRow(this.place, this.visits);

  final Place place;
  final int visits;
}

class PlacesState {
  const PlacesState({this.active = const [], this.archived = const []});

  final List<PlaceRow> active;
  final List<PlaceRow> archived;
}

class PlacesCubit extends Cubit<PlacesState> {
  PlacesCubit(this._places, this._outings) : super(const PlacesState()) {
    _subs = [
      _places.changes.listen((_) => _load()),
      _outings.changes.listen((_) => _load()),
    ];
    _load();
  }

  final PlaceRepository _places;
  final OutingRepository _outings;
  late final List<StreamSubscription<void>> _subs;

  void _load() {
    PlaceRow row(Place p) => PlaceRow(p, _outings.forPlace(p.id).length);
    emit(PlacesState(
      active: [for (final p in _places.active()) row(p)],
      archived: [for (final p in _places.archived()) row(p)],
    ));
  }

  Future<void> toggleFavorite(Place p) => _places.toggleFavorite(p.id);
  Future<void> setArchived(Place p, bool archived) =>
      _places.setArchived(p.id, archived);

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}

class PlaceVisit {
  const PlaceVisit(this.outing, this.summary);

  final Outing outing;
  final OutingSummary summary;
}

class PlaceDetailState {
  const PlaceDetailState({
    this.place,
    this.visits = const [],
    this.drinkCount = 0,
    this.informedCents = 0,
    this.unpricedCount = 0,
    this.priceStats = const [],
    this.loading = true,
  });

  final Place? place;
  final List<PlaceVisit> visits;
  final int drinkCount;
  final int informedCents;
  final int unpricedCount;

  /// "Seu histórico" at this place; never a market average.
  final List<PriceGroupStats> priceStats;
  final bool loading;
}

class PlaceDetailCubit extends Cubit<PlaceDetailState> {
  PlaceDetailCubit(this.placeId, this._places, this._outings, this._drinks)
      : super(const PlaceDetailState()) {
    _subs = [
      _places.changes.listen((_) => _load()),
      _outings.changes.listen((_) => _load()),
      _drinks.changes.listen((_) => _load()),
    ];
    _load();
  }

  final String placeId;
  final PlaceRepository _places;
  final OutingRepository _outings;
  final DrinkRepository _drinks;
  late final List<StreamSubscription<void>> _subs;

  void _load() {
    final visits = <PlaceVisit>[];
    var drinks = 0;
    var cents = 0;
    var unpriced = 0;
    final all = [
      for (final o in _outings.forPlace(placeId)) o,
    ];
    final allEntries = [
      for (final o in all) ..._drinks.entriesFor(o.id),
    ];
    for (final o in all) {
      final s = OutingSummary.of(_drinks.entriesFor(o.id));
      visits.add(PlaceVisit(o, s));
      drinks += s.entryCount;
      cents += s.informedCents;
      unpriced += s.unpricedCount;
    }
    emit(PlaceDetailState(
      loading: false,
      place: _places.byId(placeId),
      visits: visits,
      drinkCount: drinks,
      informedCents: cents,
      unpricedCount: unpriced,
      priceStats: priceStatsFor(allEntries),
    ));
  }

  Future<void> toggleFavorite() => _places.toggleFavorite(placeId);
  Future<void> setArchived(bool archived) =>
      _places.setArchived(placeId, archived);

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
