
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'image_tools.dart';

enum CaptureSource { camera, gallery }

/// A capture problem with a message that can be shown as is.
class CaptureException implements Exception {
  const CaptureException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Camera and gallery access. Returns the image bytes; the caller decides
/// where to keep them (never in a temporary camera path).
class ImageCaptureService {
  ImageCaptureService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Largest original accepted, after the picker's own downscale.
  static const maxBytes = 12 * 1024 * 1024;

  bool supports(CaptureSource source) {
    try {
      return _picker.supportsImageSource(
        source == CaptureSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
    } catch (_) {
      return false;
    }
  }

  /// Null when the user cancelled. Throws [CaptureException] for denied
  /// permission, unreadable or oversized files and unsupported platforms.
  Future<Uint8List?> pick(CaptureSource source) async {
    if (!supports(source)) {
      throw CaptureException(source == CaptureSource.camera
          ? 'A câmera não está disponível aqui. Escolha uma foto da galeria.'
          : 'A galeria não está disponível aqui.');
    }
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: source == CaptureSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 88,
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      final denied = e.code.contains('access_denied') ||
          e.code.contains('permission');
      throw CaptureException(denied
          ? 'Sem permissão para usar a ${source == CaptureSource.camera ? 'câmera' : 'galeria'}. '
              'Libere nas configurações do aparelho ou escolha outra opção.'
          : 'Não foi possível abrir a ${source == CaptureSource.camera ? 'câmera' : 'galeria'}.');
    } catch (_) {
      throw const CaptureException('Não foi possível abrir a captura de imagem.');
    }
    if (file == null) return null;
    return _validated(file);
  }

  /// A capture that Android lost when it killed the app while the camera was
  /// open; null when there is none.
  Future<Uint8List?> recoverLost() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;
      final files = response.files;
      if (files == null || files.isEmpty) return null;
      return await _validated(files.first);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _validated(XFile file) async {
    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      throw const CaptureException('Não foi possível ler essa imagem.');
    }
    if (bytes.isEmpty) {
      throw const CaptureException('Não foi possível ler essa imagem.');
    }
    if (bytes.length > maxBytes) {
      throw const CaptureException(
          'A imagem é muito grande. Tente uma foto menor.');
    }
    if (!looksLikeImage(bytes)) {
      throw const CaptureException(
          'Esse arquivo não parece ser uma imagem válida.');
    }
    try {
      return await ensureJpeg(bytes);
    } catch (_) {
      throw const CaptureException('Não foi possível ler essa imagem.');
    }
  }
}
