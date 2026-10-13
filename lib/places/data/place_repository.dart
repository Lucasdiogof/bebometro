import 'package:uuid/uuid.dart';

import '../../core/data/local_store.dart';
import '../../outings/domain/outing.dart';
import '../domain/place.dart';

class PlaceRepository {
  PlaceRepository(this._store);

  final LocalStore _store;
  static const _uuid = Uuid();

  Stream<void> get changes =>
      _store.changes.where((c) => c == LocalStore.places);

  List<Place> _all() =>
      _store.all(LocalStore.places).map(Place.fromJson).toList();

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

  List<Place> archived() => _all().where((p) => p.isArchived).toList()
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

  /// Creates a place, or updates [id]. Nickname OR address is enough.
  Future<Place> save({
    String? id,
    required OutingType type,
    String? nickname,
    String? address,
    String? city,
    String? state,
  }) async {
    String? clean(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final nick = clean(nickname);
    final addr = clean(address);
    if (nick == null && addr == null) {
      throw ArgumentError('Informe um apelido ou um endereço.');
    }
    final uf = clean(state)?.toUpperCase();
    if (uf != null && !RegExp(r'^[A-Z]{2}$').hasMatch(uf)) {
      throw ArgumentError('A UF tem 2 letras (ex.: SP).');
    }
    final now = DateTime.now();
    final existing = byId(id);
    final place = Place(
      id: existing?.id ?? _uuid.v4(),
      type: type,
      nickname: nick,
      address: addr,
      city: clean(city),
      state: uf,
      favorite: existing?.favorite ?? false,
      archivedAt: existing?.archivedAt,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _store.put(LocalStore.places, place.toJson());
    return place;
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
      p.copyWith(archivedAt: () => archived ? now : null, updatedAt: now).toJson(),
    );
  }
}
