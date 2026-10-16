import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Native sharing (system share sheet; on the web, the browser's share when it
/// exists). Nothing is ever published automatically: every call is a person's
/// explicit tap.
///
/// Not executed or verified in this environment (the dependency is declared in
/// pubspec.yaml but was not resolved here).
class ShareService {
  const ShareService._();

  /// Why the last call returned false/null (type and message), for the debug
  /// log and for support. Not shown to people as is.
  static String? lastFailure;

  /// The share sheet closed without sharing is NOT a failure; "unavailable" (the
  /// platform could not present it) is.
  static bool _presented(ShareResult r) {
    if (r.status == ShareResultStatus.unavailable) {
      lastFailure = 'share sheet unavailable (ShareResultStatus.unavailable)';
      return false;
    }
    return true;
  }

  /// Shares a file from memory. Returns false when sharing is not available or
  /// failed, so the caller can offer a copy-to-clipboard alternative.
  static Future<bool> shareFile({
    required Uint8List bytes,
    required String name,
    required String mimeType,
    String? text,
  }) async {
    try {
      final result = await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: mimeType, name: name)],
        // The temp file takes this name: share_plus ignores XFile.name when
        // the file has no path.
        fileNameOverrides: [name],
        text: text,
      );
      return _presented(result);
    } catch (e) {
      lastFailure = 'shareXFiles: ${e.runtimeType}: $e';
      if (kDebugMode) debugPrint('[share] file failed: $lastFailure');
      return false;
    }
  }

  static Future<bool> shareText(String text, {String? subject}) async {
    try {
      final result = await Share.share(text, subject: subject);
      return _presented(result);
    } catch (e) {
      lastFailure = 'share: ${e.runtimeType}: $e';
      if (kDebugMode) debugPrint('[share] text failed: $lastFailure');
      return false;
    }
  }

  /// Renders the [RepaintBoundary] behind [key] to PNG bytes. Never throws:
  /// null means the image could not be produced ([lastFailure] says why).
  static Future<Uint8List?> capturePng(GlobalKey key,
      {double pixelRatio = 3}) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        lastFailure = 'capture: no RepaintBoundary behind the key';
        return null;
      }
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) lastFailure = 'capture: toByteData returned null';
      return data?.buffer.asUint8List();
    } catch (e) {
      lastFailure = 'capture: ${e.runtimeType}: $e';
      if (kDebugMode) debugPrint('[share] capture failed: $lastFailure');
      return null;
    }
  }
}
