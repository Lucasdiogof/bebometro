import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../core/data/local_store.dart';
import '../../scan/data/photo_files.dart';
import '../domain/outing_drink.dart';

/// Drinks and photos that exist only inside one outing. Everything is keyed by
/// the outing id (never by calendar date), so a night that crosses midnight is
/// still one outing and no other outing ever sees these rows.
class OutingDrinkRepository {
  OutingDrinkRepository(this._store, this._files) {
    _store.changes
        .where((c) =>
            c == LocalStore.outingDrinks || c == LocalStore.outingPhotos)
        .listen((_) => _changes.add(null));
  }

  final LocalStore _store;
  final PhotoFiles _files;
  final _changes = StreamController<void>.broadcast();
  static const _uuid = Uuid();

  PhotoFiles get files => _files;

  String newId() => _uuid.v4();

  Stream<void> get changes => _changes.stream;

  // ---- Drinks ------------------------------------------------------------

  /// Live items of this outing only, newest first.
  List<OutingDrink> forOuting(String outingId) => _store
      .all(LocalStore.outingDrinks)
      .where((j) => j['outing_id'] == outingId && j['deleted_at'] == null)
      .map(OutingDrink.fromJson)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  OutingDrink? byId(String id) {
    final j = _store.get(LocalStore.outingDrinks, id);
    return j == null ? null : OutingDrink.fromJson(j);
  }

  /// The item behind an `outing:<id>` catalog id, or null.
  OutingDrink? byItemId(String? itemId) {
    if (itemId == null || !itemId.startsWith('outing:')) return null;
    return byId(itemId.substring('outing:'.length));
  }

  /// Idempotent by id.
  Future<void> save(OutingDrink drink) =>
      _store.put(LocalStore.outingDrinks, drink.toJson());

  /// Takes the item out of the outing's list. Records already made from it
  /// keep their own snapshot and stay in the history.
  Future<void> remove(String id) async {
    final drink = byId(id);
    if (drink == null || drink.isDeleted) return;
    final now = DateTime.now();
    await save(drink.copyWith(deletedAt: now, updatedAt: now));
  }

  /// Number of live items on this device (all outings).
  int liveCount() => _store
      .all(LocalStore.outingDrinks)
      .where((j) => j['deleted_at'] == null)
      .length;

  // ---- Photos ------------------------------------------------------------

  List<OutingPhoto> photosFor(String outingId) => _store
      .all(LocalStore.outingPhotos)
      .where((j) => j['outing_id'] == outingId && j['deleted_at'] == null)
      .map(OutingPhoto.fromJson)
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  OutingPhoto? photoById(String id) {
    final j = _store.get(LocalStore.outingPhotos, id);
    return j == null ? null : OutingPhoto.fromJson(j);
  }

  /// Registers photos whose files already exist, once the user confirmed the
  /// reading. Photos of a discarded reading never get a row.
  Future<void> confirmPhotos(
    String outingId,
    OutingPhotoKind kind,
    List<String> photoIds,
  ) async {
    final now = DateTime.now();
    for (final id in photoIds) {
      if (photoById(id) != null) continue;
      await _store.put(
        LocalStore.outingPhotos,
        OutingPhoto(
          id: id,
          outingId: outingId,
          kind: kind,
          createdAt: now,
          updatedAt: now,
        ).toJson(),
      );
    }
  }

  /// Deletes the photo (file and row) and keeps every confirmed drink data.
  /// A drink that pointed to it simply has no photo any more.
  Future<void> deletePhoto(String id) async {
    final photo = photoById(id);
    final now = DateTime.now();
    if (photo != null && !photo.isDeleted) {
      await _store.put(
        LocalStore.outingPhotos,
        photo.copyWith(deletedAt: now, updatedAt: now).toJson(),
      );
    }
    await _files.delete(id);
    for (final drink in _store
        .all(LocalStore.outingDrinks)
        .map(OutingDrink.fromJson)
        .where((d) => d.photoIds.contains(id))) {
      await save(drink.copyWith(
        photoIds: [for (final p in drink.photoIds) if (p != id) p],
        updatedAt: now,
      ));
    }
  }

  /// Marks a private upload as confirmed by the server.
  Future<void> markUploaded(String id, String storagePath) async {
    final photo = photoById(id);
    if (photo == null || photo.isDeleted) return;
    final now = DateTime.now();
    await _store.put(
      LocalStore.outingPhotos,
      photo
          .copyWith(storagePath: storagePath, uploadedAt: now, updatedAt: now)
          .toJson(),
    );
  }
}
