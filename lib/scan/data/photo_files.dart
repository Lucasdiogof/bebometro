import 'dart:typed_data';

import 'photo_files_factory.dart' as factory_impl;

/// Where outing photos live as files (never as base64 inside a row).
///
/// On Android/iOS they are kept in the app's documents directory, so they
/// survive restarts and never depend on the camera's temporary path. On the
/// web there is no durable file storage: photos live only in memory for the
/// current session ([isDurable] is false) and the UI says so.
abstract class PhotoFiles {
  factory PhotoFiles() => factory_impl.createPhotoFiles();

  /// False when photos do not survive closing the app (web).
  bool get isDurable;

  Future<void> write(String photoId, Uint8List bytes);

  /// The photo bytes, or null when the file is gone (history keeps working).
  Future<Uint8List?> read(String photoId);

  Future<void> delete(String photoId);

  /// Whether the photo file is still there (false after the web session ended
  /// or when the file was removed). Never reads the whole image.
  Future<bool> exists(String photoId);

  /// Local file path for engines that read from disk (text recognition);
  /// null when there is no file (web).
  Future<String?> pathOf(String photoId);
}
