
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'image_tools.dart';
import '../../l10n/l10n.dart';

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
          ? tr.captureCameraUnavailable
          : tr.captureGalleryUnavailable);
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
      final camera = source == CaptureSource.camera;
      throw CaptureException(denied
          ? (camera ? tr.capturePermissionCamera : tr.capturePermissionGallery)
          : (camera ? tr.captureOpenCameraFailed : tr.captureOpenGalleryFailed));
    } catch (_) {
      throw CaptureException(tr.captureFailed);
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
      throw CaptureException(tr.captureUnreadable);
    }
    if (bytes.isEmpty) {
      throw CaptureException(tr.captureUnreadable);
    }
    if (bytes.length > maxBytes) {
      throw CaptureException(tr.captureTooBig);
    }
    if (!looksLikeImage(bytes)) {
      throw CaptureException(tr.captureNotImage);
    }
    try {
      return await ensureJpeg(bytes);
    } catch (_) {
      throw CaptureException(tr.captureUnreadable);
    }
  }
}
