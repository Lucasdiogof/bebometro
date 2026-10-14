import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Textures and shader of the full-screen beer, loaded once per page and
/// released with it.
///
/// The page shows a plain dark background until [load] completes, so no
/// frame is ever drawn with missing textures. The fragment program is
/// optional: when the backend cannot compile it, [program] is null and the
/// painter uses the Canvas fallback with the SAME textures.
class BeerMaterials {
  BeerMaterials._(this.beer, this.foam, this.glass, this.bubble, this.program);

  static const shaderAsset = 'shaders/beer.frag';

  /// Golden liquid, opaque, tileable (512x512).
  final ui.Image beer;

  /// Foam band, RGBA, tileable horizontally (1024x256; y = depth in the band).
  final ui.Image foam;

  /// Glass condensation, RGBA, tileable (512x512).
  final ui.Image glass;

  /// Carbonation bubble sprite sheet, RGBA (64, 16 and 8 px versions).
  final ui.Image bubble;

  /// Null on backends without runtime shaders.
  final ui.FragmentProgram? program;

  bool _disposed = false;

  static Future<ui.Image> _image(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  static Future<BeerMaterials> load() async {
    final images = await Future.wait([
      _image('assets/glass/beer_liquid.jpg'),
      _image('assets/glass/foam.png'),
      _image('assets/glass/condensation.png'),
      _image('assets/glass/bubble.png'),
    ]);
    ui.FragmentProgram? program;
    try {
      program = await ui.FragmentProgram.fromAsset(shaderAsset);
    } catch (e) {
      // Backend without runtime effects: the Canvas fallback is used.
      if (kDebugMode) debugPrint('[beer] shader unavailable: $e');
    }
    return BeerMaterials._(images[0], images[1], images[2], images[3], program);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    beer.dispose();
    foam.dispose();
    glass.dispose();
    bubble.dispose();
  }
}
