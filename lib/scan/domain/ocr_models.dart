/// One line of recognised text, with its position in the image when the
/// engine provides it (pasted text has none).
class OcrLine {
  const OcrLine(
    this.text, {
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.hasBox = false,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  /// False for text typed or pasted by the user: no geometry to rely on.
  final bool hasBox;

  double get height => bottom - top;
  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;

  Map<String, dynamic> toJson() => {
    't': text,
    if (hasBox) ...{'l': left, 'u': top, 'r': right, 'b': bottom},
  };

  factory OcrLine.fromJson(Map<String, dynamic> j) {
    final hasBox = j['l'] != null;
    return OcrLine(
      j['t'] as String,
      left: (j['l'] as num?)?.toDouble() ?? 0,
      top: (j['u'] as num?)?.toDouble() ?? 0,
      right: (j['r'] as num?)?.toDouble() ?? 0,
      bottom: (j['b'] as num?)?.toDouble() ?? 0,
      hasBox: hasBox,
    );
  }
}

/// Text taken from an image (or typed/pasted by the user), line by line.
class OcrResult {
  const OcrResult(this.lines);

  /// Text without geometry: one line per text line, in the given order.
  factory OcrResult.fromText(String text) => OcrResult([
    for (final raw in text.split(RegExp(r'\r?\n')))
      if (raw.trim().isNotEmpty) OcrLine(raw.trim()),
  ]);

  final List<OcrLine> lines;

  bool get isEmpty => lines.every((l) => l.text.trim().isEmpty);

  String get text => lines.map((l) => l.text).join('\n');

  List<Map<String, dynamic>> toJson() => [for (final l in lines) l.toJson()];

  factory OcrResult.fromJson(List<dynamic> json) => OcrResult([
    for (final l in json) OcrLine.fromJson(Map<String, dynamic>.from(l as Map)),
  ]);
}

/// Why a reading could not be done. Never replaced by made-up text.
class OcrFailure implements Exception {
  const OcrFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
