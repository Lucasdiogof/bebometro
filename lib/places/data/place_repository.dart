import 'package:uuid/uuid.dart';

import '../../core/data/local_store.dart';
import '../../outings/domain/outing.dart';
import '../domain/geo_point.dart';
import '../domain/place.dart';
import '../domain/place_draft.dart';
import '../../l10n/l10n.dart';

class PlaceRepository {
  PlaceRepository(this._store);

  final LocalStore _store;
  static const _uuid = Uuid();

  Stream<void> get changes =>
      _store.changes.where((c) => c == LocalStore.places);

  /// Tombstones (`deleted_at`, from another device) never show up.
  List<Place> _all() => _store
      .all(LocalStore.places)
      .where((j) => j['deleted_at'] == null)
      .map(Place.fromJson)
      .toList();

  Place? byId(String? id) {
    if (id == null) return null;
    final j = _store.get(LocalStore.places, id);
    return j == null ? null : Place.fromJson(j);
  }

  /// Active places: favourites first, then by name.
  List<Place> active() => _all().where((p) => !p.isArchived).toList()
    ..sort((a, b) {
      if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

  List<Place> archived() =>
      _all().where((p) => p.isArchived).toList()
        ..sort((a, b) => b.archivedAt!.compareTo(a.archivedAt!));

  /// Active places ordered by the latest outing held there (then creation).
  List<Place> recent(List<Outing> outings, {int limit = 6}) {
    final last = <String, DateTime>{};
    for (final o in outings) {
      final id = o.placeId;
      if (id == null) continue;
      final prev = last[id];
      if (prev == null || o.startedAt.isAfter(prev)) last[id] = o.startedAt;
    }
    final list = active();
    list.sort((a, b) {
      final la = last[a.id] ?? a.createdAt;
      final lb = last[b.id] ?? b.createdAt;
      return lb.compareTo(la);
    });
    return list.take(limit).toList();
  }

  /// The saved place (active or archived) that already holds this provider
  /// result. Places are only matched by the provider id: never by name, and
  /// nearby houses or addresses are never merged.
  Place? findByProvider(String? provider, String? providerPlaceId) {
    if (provider == null || providerPlaceId == null) return null;
    for (final p in _all()) {
      if (p.provider == provider && p.providerPlaceId == providerPlaceId) {
        return p;
      }
    }
    return null;
  }

  /// Creates a place, or updates [id]. A nickname, a name from the map data
  /// or an address is enough; a bare point needs a nickname to be saved.
  /// Location fields are written exactly as given (null clears them).
  Future<Place> save({
    String? id,
    required OutingType type,
    String? nickname,
    String? address,
    String? city,
    String? state,
    String? providerName,
    GeoPoint? point,
    LocationSource? source,
    String? provider,
    String? providerPlaceId,
  }) async {
    String? clean(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    final nick = clean(nickname);
    final addr = clean(address);
    final name = clean(providerName);
    if (nick == null && addr == null && name == null) {
      throw ArgumentError(
        point != null ? tr.repoPointNeedsName : tr.repoNicknameOrAddress,
      );
    }
    final uf = clean(state)?.toUpperCase();
    if (uf != null && !RegExp(r'^[A-Z]{2}$').hasMatch(uf)) {
      throw ArgumentError(tr.repoStateFormat);
    }
    final now = DateTime.now();
    final existing = byId(id);
    final linked =
        point != null &&
        clean(provider) != null &&
        clean(providerPlaceId) != null;
    final place = Place(
      id: existing?.id ?? _uuid.v4(),
      type: type,
      nickname: nick,
      address: addr,
      city: clean(city),
      state: uf,
      providerName: name,
      point: point,
      source: point == null && addr == null ? null : source,
      provider: linked ? clean(provider) : null,
      providerPlaceId: linked ? clean(providerPlaceId) : null,
      favorite: existing?.favorite ?? false,
      archivedAt: existing?.archivedAt,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _store.put(LocalStore.places, place.toJson());
    return place;
  }

  /// Turns what the picker returned into the outing's own copy of the place,
  /// saving or updating the saved place first when the person asked for it.
  ///
  /// * A saved place chosen as it is: linked as it is.
  /// * New data for a saved place (or a search result that already is one):
  ///   the saved place gets the confirmed location, and keeps its nickname
  ///   unless the person typed a new one. An archived match is reactivated.
  /// * New data with "save" on: a new saved place.
  /// * Otherwise: a one-off copy, no saved place.
  Future<PlaceSnapshot> resolve(PlaceDraft d, OutingType type) async {
    if (d.isSavedAsIs) return PlaceSnapshot.ofPlace(d.saved!);
    final existing = d.saved ?? findByProvider(d.provider, d.providerPlaceId);
    if (existing == null && !d.save) return PlaceSnapshot.ofDraft(d);
    final typed = d.nickname?.trim();
    final saved = await save(
      id: existing?.id,
      type: existing?.type ?? type,
      nickname: (typed != null && typed.isNotEmpty)
          ? typed
          : existing?.nickname,
      address: d.address,
      city: d.city,
      state: d.state,
      providerName: d.providerName,
      point: d.point,
      source: d.source,
      provider: d.provider,
      providerPlaceId: d.providerPlaceId,
    );
    if (saved.isArchived) await setArchived(saved.id, false);
    return PlaceSnapshot.ofPlace(byId(saved.id) ?? saved);
  }

  Future<void> toggleFavorite(String id) async {
    final p = byId(id);
    if (p == null) return;
    await _store.put(
      LocalStore.places,
      p.copyWith(favorite: !p.favorite, updatedAt: DateTime.now()).toJson(),
    );
  }

  Future<void> setArchived(String id, bool archived) async {
    final p = byId(id);
    if (p == null) return;
    final now = DateTime.now();
    await _store.put(
      LocalStore.places,
      p
          .copyWith(archivedAt: () => archived ? now : null, updatedAt: now)
          .toJson(),
    );
  }
}
