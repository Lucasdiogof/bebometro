import 'dart:io' show Platform;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as mlkit;

import '../domain/ocr_models.dart';
import 'text_recognizer.dart';
import '../../l10n/l10n.dart';

TextRecognizer createTextRecognizer() => _MlKitRecognizer();

/// On-device text recognition with Google ML Kit (Latin script). Supported on
/// Android and iOS only; on other io platforms (desktop) it reports itself as
/// unsupported.
class _MlKitRecognizer implements TextRecognizer {
  @override
  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  @override
  Future<OcrResult> recognizeFile(String path) async {
    if (!isSupported) {
      throw OcrFailure(tr.ocrUnavailable);
    }
    final recognizer =
        mlkit.TextRecognizer(script: mlkit.TextRecognitionScript.latin);
    try {
      final result =
          await recognizer.processImage(mlkit.InputImage.fromFilePath(path));
      final lines = <OcrLine>[];
      for (final block in result.blocks) {
        for (final line in block.lines) {
          final box = line.boundingBox;
          lines.add(OcrLine(
            line.text,
            left: box.left,
            top: box.top,
            right: box.right,
            bottom: box.bottom,
            hasBox: true,
          ));
        }
      }
      return OcrResult(lines);
    } catch (_) {
      throw OcrFailure(tr.ocrReadFailed);
    } finally {
      await recognizer.close();
    }
  }
}
