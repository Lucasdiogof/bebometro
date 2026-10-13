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
///
/// One photo failing never blocks the others. A photo deleted while its
/// upload was in flight is removed from the server again, so a late answer
/// cannot bring it back.
class PhotoUploader implements PendingUploads {
  PhotoUploader(this._store, this._repo);

  static const bucket = 'outing-photos';

  final LocalStore _store;
  final OutingDrinkRepository _repo;

  /// Photos whose file is gone (web session ended, file removed): there is
  /// nothing to send, so they are not counted as waiting.
  final _missing = <String>{};

  @override
  int get waiting {
    var count = 0;
    for (final json in _store.all(LocalStore.outingPhotos)) {
      final photo = OutingPhoto.fromJson(json);
      if (photo.isDeleted) {
        if (photo.storagePath != null) count++; // object still to remove
      } else if (!photo.isUploaded && !_missing.contains(photo.id)) {
        count++;
      }
    }
    return count;
  }

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
      }
    }

    for (final json in _store.all(LocalStore.outingPhotos)) {
      final photo = OutingPhoto.fromJson(json);
      if (photo.isDeleted || photo.isUploaded) continue;
      final bytes = await _repo.files.read(photo.id);
      if (bytes == null) {
        _missing.add(photo.id); // file gone: nothing to send
        continue;
      }
      _missing.remove(photo.id);
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
      } catch (e) {
        // E.g. bucket not available yet or no connection: the file and the
        // row stay as they are and the next pass tries again.
        _log('upload of ${photo.id} failed: $e');
        continue;
      }
      // The user may have deleted the photo while it was being sent. The row
      // is the truth: take the object back off the server instead of leaving
      // it behind with no record.
      final current = _repo.photoById(photo.id);
      if (current == null || current.isDeleted) {
        try {
          await storage.remove([path]);
        } catch (e) {
          _log('cleanup of late upload ${photo.id} failed: $e');
        }
        continue;
      }
      await _repo.markUploaded(photo.id, path);
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[photos] $message');
  }
}
