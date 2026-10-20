import '../../l10n/l10n.dart';
import '../domain/ocr_models.dart';
import 'text_recognizer.dart';

TextRecognizer createTextRecognizer() => _UnsupportedRecognizer();

/// Web: no on-device text recognition is available, so nothing is simulated.
class _UnsupportedRecognizer implements TextRecognizer {
  @override
  bool get isSupported => false;

  @override
  Future<OcrResult> recognizeFile(String path) async =>
      throw OcrFailure(tr.ocrUnavailable);
}
