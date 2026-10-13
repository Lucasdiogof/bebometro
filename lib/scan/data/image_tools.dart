import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// True when the bytes look like an image the app can handle.
bool looksLikeImage(Uint8List bytes) => img.findDecoderForData(bytes) != null;

Uint8List _rotate(({Uint8List bytes, int degrees}) args) {
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) throw const FormatException('not an image');
  final upright = img.bakeOrientation(decoded);
  final rotated = img.copyRotate(upright, angle: args.degrees);
  return Uint8List.fromList(img.encodeJpg(rotated, quality: 90));
}

/// Rotates the image by [degrees] (90, 180 or 270) and returns a JPEG. Runs in
/// a background isolate where the platform has one.
Future<Uint8List> rotateImage(Uint8List bytes, int degrees) =>
    compute(_rotate, (bytes: bytes, degrees: degrees));
