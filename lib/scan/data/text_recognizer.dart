import '../domain/ocr_models.dart';
import 'text_recognizer_factory.dart' as factory_impl;

/// Reads text from an image file. Implementations run on the device (no
/// network, no per-reading cost) and never invent text: when nothing could be
/// read they throw an [OcrFailure] or return an empty result.
abstract class TextRecognizer {
  factory TextRecognizer() => factory_impl.createTextRecognizer();

  /// False where no local engine exists (web, desktop). The UI then lets the
  /// user view the photo and type or paste the text.
  bool get isSupported;

  Future<OcrResult> recognizeFile(String path);
}
