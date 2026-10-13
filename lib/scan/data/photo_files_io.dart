import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'photo_files.dart';

PhotoFiles createPhotoFiles() => _IoPhotoFiles();

class _IoPhotoFiles implements PhotoFiles {
  Directory? _dir;

  @override
  bool get isDurable => true;

  Future<Directory> _directory() async {
    final cached = _dir;
    if (cached != null) return cached;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}outing_photos');
    if (!await dir.exists()) await dir.create(recursive: true);
    return _dir = dir;
  }

  Future<File> _file(String photoId) async {
    final dir = await _directory();
    return File('${dir.path}${Platform.pathSeparator}$photoId.jpg');
  }

  @override
  Future<void> write(String photoId, Uint8List bytes) async {
    final target = await _file(photoId);
    // Write to a temporary name first so a crash never leaves half a photo.
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(target.path);
  }

  @override
  Future<Uint8List?> read(String photoId) async {
    try {
      final file = await _file(photoId);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String photoId) async {
    try {
      final file = await _file(photoId);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A file that cannot be removed now is harmless: the row is gone.
    }
  }

  @override
  Future<String?> pathOf(String photoId) async {
    final file = await _file(photoId);
    return await file.exists() ? file.path : null;
  }
}
