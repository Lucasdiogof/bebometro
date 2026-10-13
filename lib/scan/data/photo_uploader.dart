import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/data/local_store.dart';
import '../../core/sync/pending_uploads.dart';
import '../../outing_drinks/data/outing_drink_repository.dart';
import '../../outing_drinks/domain/outing_drink.dart';

/// Sends confirmed photos to a private bucket, organised as
/// `<owner>/<outing>/<photo>.jpg`. The path is derived from ids, so a retry
/// overwrites the same object instead of creating a second one. A photo is
/// marked as uploaded only after the server confirmed it, and the structured
/// data of the outing is synced regardless of the photos.
class PhotoUploader implements PendingUploads {
  PhotoUploader(this._store, this._repo);

  static const bucket = 'outing-photos';

  final LocalStore _store;
  final OutingDrinkRepository _repo;

  @override
  Future<void> run(SupabaseClient client, String ownerId) async {
    final storage = client.storage.from(bucket);

    // Photos deleted by the user: remove the remote object, then forget it.
    for (final json in _store.all(LocalStore.outingPhotos)) {
      final photo = OutingPhoto.fromJson(json);
      if (!photo.isDeleted || photo.storagePath == null) continue;
      try {
        await storage.remove([photo.storagePath!]);
        await _store.put(
          LocalStore.outingPhotos,
          photo
              .copyWith(clearStorage: true, updatedAt: DateTime.now())
              .toJson(),
        );
      } catch (e) {
        _log('remote delete of ${photo.id} failed: $e');
        return; // storage unavailable: try again on the next pass
      }
    }

    for (final json in _store.all(LocalStore.outingPhotos)) {
      final photo = OutingPhoto.fromJson(json);
      if (photo.isDeleted || photo.isUploaded) continue;
      final bytes = await _repo.files.read(photo.id);
      if (bytes == null) continue; // file gone: nothing to send
      final path = '$ownerId/${photo.outingId}/${photo.id}.jpg';
      try {
        await storage.uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
        await _repo.markUploaded(photo.id, path);
      } catch (e) {
        _log('upload of ${photo.id} failed: $e');
        return; // e.g. bucket not created yet: keep the photo on the device
      }
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[photos] $message');
  }
}
