import 'dart:typed_data';

import 'photo_files.dart';

PhotoFiles createPhotoFiles() => _MemoryPhotoFiles();

/// Web: no durable file storage, so photos last for the session only.
class _MemoryPhotoFiles implements PhotoFiles {
  final _bytes = <String, Uint8List>{};

  @override
  bool get isDurable => false;

  @override
  Future<void> write(String photoId, Uint8List bytes) async {
    _bytes[photoId] = bytes;
  }

  @override
  Future<Uint8List?> read(String photoId) async => _bytes[photoId];

  @override
  Future<void> delete(String photoId) async {
    _bytes.remove(photoId);
  }

  @override
  Future<String?> pathOf(String photoId) async => null;
}
