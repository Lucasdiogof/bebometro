import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/beer_sim.dart';
import 'beer_materials.dart';

/// Draws the full-screen beer from [BeerSim] with real textures:
///
///  1. air + beer body: textured liquid (two scales, refraction wobble,
///     depth tint, backlight, lacing), clipped by the simulated surface;
///  2. carbonation: lens-like bubble sprites (one atlas draw), only inside
///     the liquid, fading as they reach the foam;
///  3. foam: a texture mapped by distance along the surface and depth in the
///     band (constant scale, never stretched by the tilt), irregular edge;
///  4. glass: condensation and reflections fixed to the screen, over
///     everything (also above the beer).
///
/// With a fragment program (normal case) 1, 3 and 4 are two passes of
/// `shaders/beer.frag`; without it the same textures are drawn with Canvas
/// image shaders. Nothing rotates as a whole: the textures of the liquid and
/// the glass stay fixed to the screen and only the surface moves.
///
/// Owned by the page (one per page), so the shaders are created once and
/// disposed with it. Repaints come from [BeerSim] alone.
class BeerRenderer {
  BeerRenderer(this.m)
    : _beerPass = m.program?.fragmentShader(),
      _foamPass = m.program?.fragmentShader() {
    for (final s in [_beerPass, _foamPass]) {
      if (s == null) continue;
      // Bilinear: the default sampler filter is nearest-neighbour.
      s
        ..setImageSampler(0, m.beer, filterQuality: FilterQuality.medium)
        ..setImageSampler(1, m.foam, filterQuality: FilterQuality.medium)
        ..setImageSampler(2, m.glass, filterQuality: FilterQuality.medium);
    }
    _beerPaint.shader = _beerPass;
    _foamPaint.shader = _foamPass;
  }

  final BeerMaterials m;
  final ui.FragmentShader? _beerPass;
  final ui.FragmentShader? _foamPass;

  bool get usesShader => _beerPass != null;

  // Logical px per texture tile: the same in the shader and the fallback.
  static const beerTile = 420.0;
  static const glassTile = 360.0;

  final _beerPaint = Paint();
  final _foamPaint = Paint();
  final _paint = Paint()..isAntiAlias = true;
  final _atlasPaint = Paint()..filterQuality = FilterQuality.medium;
  final _liquid = Path();
  final _foam = Path();

  static const _samples = 72;
  final _sx = Float64List(_samples + 1);
  final _sy = Float64List(_samples + 1);

  // Bubble atlas buffers (no per-frame allocation).
  Float32List _xf = Float32List(0);
  Float32List _rects = Float32List(0);
  Int32List _colors = Int32List(0);

  /// Surface wave amplitude, matching the shader.
  double _amp(BeerSim sim) =>
      sim.waveAmp + (sim.effects && !sim.calm ? 1.2 : 0);

  double _foamBase(BeerSim sim, Size size) {
    final fade = (sim.volume / 0.08).clamp(0.0, 1.0).toDouble();
    return (size.height * 0.10).clamp(40.0, 110.0) * fade;
  }

  // Same formulas as beer.frag (surfaceD, thick).
  double _surfaceD(BeerSim sim, double u, double k1, double amp) =>
      sim.level -
      amp *
          (0.58 * math.sin(u * k1 + sim.phase) +
              0.30 * math.sin(u * k1 * 1.9 - sim.phase * 1.3) +
              0.12 * math.sin(u * k1 * 4.7 + sim.phase * 2.1));

  double _thick(BeerSim sim, double u, double base) =>
      base *
      (1 +
          0.14 * math.sin(u * 0.019 + 1.7) +
          0.08 * math.sin(u * 0.047 + sim.phase * 0.35) +
          0.04 * math.sin(u * 0.11 + 0.6));

  void paint(Canvas canvas, Size size, BeerSim sim) {
    sim.setSize(size);
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final w = size.width, h = size.height;
    final nx = sim.nx, ny = sim.ny;
    final tx = ny, ty = -nx;
    final k1 = 2 * math.pi / (w * 0.9);
    final amp = _amp(sim);
    final hasBeer = !sim.isEmpty;
    final foamBase = hasBeer ? _foamBase(sim, size) : 0.0;
    final deep = math.max(1.0, sim.maxProj - sim.level);

    // Surface samples (for the bubble clip and the fallback paths).
    final u0 = math.min(
      math.min(0.0, tx * w),
      math.min(ty * h, tx * w + ty * h),
    );
    final u1 = math.max(
      math.max(0.0, tx * w),
      math.max(ty * h, tx * w + ty * h),
    );
    final span = (u1 - u0) + 40;
    final uStart = u0 - 20;
    for (var i = 0; i <= _samples; i++) {
      final u = uStart + span * i / _samples;
      final d = _surfaceD(sim, u, k1, amp);
      _sx[i] = nx * d + tx * u;
      _sy[i] = ny * d + ty * u;
    }
    final far = math.sqrt(w * w + h * h) * 1.3;
    _liquid
      ..reset()
      ..moveTo(_sx[0], _sy[0]);
    for (var i = 1; i <= _samples; i++) {
      _liquid.lineTo(_sx[i], _sy[i]);
    }
    _liquid
      ..lineTo(_sx[_samples] + nx * far, _sy[_samples] + ny * far)
      ..lineTo(_sx[0] + nx * far, _sy[0] + ny * far)
      ..close();

    final beerPass = _beerPass;
    if (beerPass != null) {
      _setUniforms(beerPass, size, sim, k1, amp, foamBase, deep, 0, hasBeer);
      canvas.drawRect(rect, _beerPaint);
    } else {
      _fallbackBeer(canvas, size, sim, hasBeer, deep);
    }

    if (hasBeer && sim.effects) {
      canvas.save();
      canvas.clipPath(_liquid);
      _drawBubbles(canvas, sim);
      canvas.restore();
    }

    final foamPass = _foamPass;
    if (foamPass != null) {
      _setUniforms(foamPass, size, sim, k1, amp, foamBase, deep, 1, hasBeer);
      canvas.drawRect(rect, _foamPaint);
    } else {
      if (hasBeer && foamBase > 0.5) {
        _fallbackFoam(canvas, sim, k1, amp, foamBase, uStart, span);
      }
      _fallbackGlass(canvas, size);
    }
  }

  void _setUniforms(
    ui.FragmentShader s,
    Size size,
    BeerSim sim,
    double k1,
    double amp,
    double foam,
    double deep,
    double pass,
    bool hasBeer,
  ) {
    s
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, sim.time)
      ..setFloat(3, sim.nx)
      ..setFloat(4, sim.ny)
      ..setFloat(5, sim.level)
      ..setFloat(6, amp)
      ..setFloat(7, sim.phase)
      ..setFloat(8, k1)
      ..setFloat(9, foam)
      ..setFloat(10, deep)
      ..setFloat(11, pass)
      ..setFloat(12, hasBeer ? 1 : 0);
  }

  void _drawBubbles(Canvas canvas, BeerSim sim) {
    final count = sim.bubbleCount;
    if (_xf.length != count * 4) {
      _xf = Float32List(count * 4);
      _rects = Float32List(count * 4);
      _colors = Int32List(count);
    }
    final nx = sim.nx, ny = sim.ny;
    // Sprite sheet: 64 px at x=0, pre-reduced 16 px at x=64 and 8 px at
    // x=80 (the atlas has no mipmaps; tiny bubbles use the small ones).
    var n = 0;
    for (var i = 0; i < count; i++) {
      if (!sim.bubbleAlive(i)) continue;
      final x = sim.bubbleX(i), y = sim.bubbleY(i);
      final r = sim.bubbleR(i);
      final depth = nx * x + ny * y - sim.level;
      // Dissolve as they reach the foam; fainter deep down (smaller, farther).
      final reach = (depth / 16).clamp(0.0, 1.0).toDouble();
      final near = (1 - depth / (sim.size.height * 0.6))
          .clamp(0.25, 1.0)
          .toDouble();
      final a = (reach * (0.55 + 0.45 * near)).clamp(0.0, 1.0).toDouble();
      if (a <= 0.01) continue;
      final onScreen = r * 1.35 * 2 / 0.92; // sprite size on screen (px)
      final double sprite, left;
      if (onScreen <= 10) {
        sprite = 8;
        left = 80;
      } else if (onScreen <= 26) {
        sprite = 16;
        left = 64;
      } else {
        sprite = 64;
        left = 0;
      }
      final scale = onScreen / sprite;
      final half = onScreen / 2;
      _xf[n * 4] = scale;
      _xf[n * 4 + 1] = 0;
      _xf[n * 4 + 2] = x - half;
      _xf[n * 4 + 3] = y - half;
      _rects[n * 4] = left;
      _rects[n * 4 + 1] = 0;
      _rects[n * 4 + 2] = left + sprite;
      _rects[n * 4 + 3] = sprite;
      // modulate: white keeps the sprite colours, alpha fades it.
      _colors[n] = ((a * 255).round() << 24) | 0x00FFFFFF;
      n++;
    }
    if (n == 0) return;
    canvas.drawRawAtlas(
      m.bubble,
      Float32List.sublistView(_xf, 0, n * 4),
      Float32List.sublistView(_rects, 0, n * 4),
      Int32List.sublistView(_colors, 0, n),
      BlendMode.modulate,
      null,
      _atlasPaint,
    );
  }

  Float64List _scale(double s) =>
      Float64List.fromList([s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);

  void _fallbackBeer(
    Canvas canvas,
    Size size,
    BeerSim sim,
    bool hasBeer,
    double deep,
  ) {
    final rect = Offset.zero & size;
    _paint
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), const [
        Color(0xFF070707),
        Color(0xFF131211),
      ])
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, _paint);
    if (!hasBeer) {
      _paint.shader = null;
      return;
    }
    _paint.shader = ImageShader(
      m.beer,
      TileMode.repeated,
      TileMode.repeated,
      _scale(beerTile / m.beer.width),
      filterQuality: FilterQuality.medium,
    );
    canvas.drawPath(_liquid, _paint);
    // Depth tint (multiply) and the lacing under the foam.
    final nx = sim.nx, ny = sim.ny;
    final from = Offset(nx * sim.level, ny * sim.level);
    final to = from + Offset(nx, ny) * deep;
    canvas.save();
    canvas.clipPath(_liquid);
    _paint
      ..shader = ui.Gradient.linear(
        from,
        to,
        const [Color(0xFFFFFFFF), Color(0xFFE3C79A), Color(0xFF9A6629)],
        const [0.0, 0.35, 1.0],
      )
      ..blendMode = BlendMode.multiply;
    canvas.drawRect(rect, _paint);
    _paint
      ..blendMode = BlendMode.srcOver
      ..shader = ui.Gradient.linear(from, from + Offset(nx, ny) * 40, const [
        Color(0x4DFFEDBD),
        Color(0x00FFEDBD),
      ]);
    canvas.drawRect(rect, _paint);
    canvas.restore();
    _paint.shader = null;
  }

  void _fallbackFoam(
    Canvas canvas,
    BeerSim sim,
    double k1,
    double amp,
    double base,
    double uStart,
    double span,
  ) {
    final nx = sim.nx, ny = sim.ny;
    final tx = ny, ty = -nx;
    Offset at(double u, double lift) {
      final d = _surfaceD(sim, u, k1, amp) - lift;
      return Offset(nx * d + tx * u, ny * d + ty * u);
    }

    // Band from slightly under the surface (translucent transition) to the
    // irregular top edge.
    _foam.reset();
    for (var i = 0; i <= _samples; i++) {
      final u = uStart + span * i / _samples;
      final p = at(u, -base * 0.42);
      if (i == 0) {
        _foam.moveTo(p.dx, p.dy);
      } else {
        _foam.lineTo(p.dx, p.dy);
      }
    }
    for (var i = _samples; i >= 0; i--) {
      final u = uStart + span * i / _samples;
      final p = at(u, _thick(sim, u, base));
      _foam.lineTo(p.dx, p.dy);
    }
    _foam.close();

    // Texture frame: x along the surface, y down into the band, constant
    // scale (texture px -> logical px), anchored on the surface level.
    final band = base * 1.45;
    // Same scale both ways (the texture is 4:1): cells stay round.
    final sy = band / m.foam.height;
    final sx = sy;
    final topAbove = band - base * 0.42; // texture y = 0
    final ox = nx * (sim.level - topAbove);
    final oy = ny * (sim.level - topAbove);
    final matrix = Float64List.fromList([
      tx * sx, ty * sx, 0, 0, //
      nx * sy, ny * sy, 0, 0, //
      0, 0, 1, 0, //
      ox, oy, 0, 1,
    ]);
    _paint.shader = ImageShader(
      m.foam,
      TileMode.repeated,
      TileMode.clamp,
      matrix,
      filterQuality: FilterQuality.medium,
    );
    canvas.drawPath(_foam, _paint);
    _paint.shader = null;
  }

  void _fallbackGlass(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _paint.shader = ImageShader(
      m.glass,
      TileMode.repeated,
      TileMode.repeated,
      _scale(glassTile / m.glass.width),
      filterQuality: FilterQuality.medium,
    );
    canvas.drawRect(rect, _paint);
    final w = size.width, h = size.height;
    void band(double x0, double x1, int alpha) {
      final r = Rect.fromLTRB(w * x0, 0, w * x1, h);
      _paint.shader = ui.Gradient.linear(
        r.centerLeft,
        r.centerRight,
        [
          const Color(0x00FFFFFF),
          Color.fromARGB(alpha, 255, 255, 255),
          const Color(0x00FFFFFF),
        ],
        const [0.0, 0.5, 1.0],
      );
      canvas.drawRect(r, _paint);
    }

    band(0.045, 0.16, 26);
    band(0.075, 0.088, 38);
    band(0.86, 0.95, 16);
    band(0.915, 0.923, 24);
    _paint.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(w, 0),
      const [
        Color(0x33000000),
        Color(0x00000000),
        Color(0x00000000),
        Color(0x33000000),
      ],
      const [0.0, 0.08, 0.92, 1.0],
    );
    canvas.drawRect(rect, _paint);
    _paint.shader = null;
  }

  void dispose() {
    _beerPass?.dispose();
    _foamPass?.dispose();
  }
}

/// Repaints from [BeerSim] alone (no widget rebuild per frame).
class BeerPainter extends CustomPainter {
  BeerPainter(this.sim, this.renderer) : super(repaint: sim);

  final BeerSim sim;
  final BeerRenderer renderer;

  @override
  void paint(Canvas canvas, Size size) => renderer.paint(canvas, size, sim);

  @override
  bool shouldRepaint(BeerPainter old) =>
      old.sim != sim || old.renderer != renderer;
}
