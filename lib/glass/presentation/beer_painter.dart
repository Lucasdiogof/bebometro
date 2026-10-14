import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/beer_sim.dart';

/// Draws a clear golden pilsner filling the whole canvas. It repaints from
/// [BeerSim] alone (no widget rebuild per frame) and keeps its paints, paths and
/// point buffers between frames. Nothing is rotated as a whole: surface, foam
/// and bubbles come from the gravity direction, so volume, tilt and pouring
/// stay exactly what the simulation says.
///
/// Layers, back to front: neutral dark air, luminous liquid (depth gradient +
/// backlight glow), tiny translucent bubbles, cream foam with a micro texture,
/// a soft lacing under the foam, and fixed glass reflections over everything.
class BeerPainter extends CustomPainter {
  BeerPainter(this.sim) : super(repaint: sim);

  final BeerSim sim;

  // Air: almost black and neutral, so the gold is the only warm thing.
  static const _airTop = Color(0xFF070707);
  static const _airBottom = Color(0xFF141414);

  // Pilsner: light and saturated at the surface, deeper amber (not brown) far
  // from it.
  static const _beerTop = Color(0xFFFFD95E);
  static const _beerMid = Color(0xFFFAB92A);
  static const _beerLow = Color(0xFFEC9C12);
  static const _beerDeep = Color(0xFFCD7C0A);

  static const _foamTop = Color(0xFFFFFEF8);
  static const _foamMid = Color(0xFFFFF6DE);
  static const _foamBottom = Color(0xFFF2DEAE);

  final _paint = Paint()..isAntiAlias = true;
  final _bubbleBody = Paint()..isAntiAlias = true;
  final _bubbleGlint = Paint()
    ..isAntiAlias = true
    ..color = const Color(0xCCFFFFFF);
  final _liquid = Path();
  final _foam = Path();
  final _lace = Path();

  // Micro texture of the foam, in three size classes, light and shaded.
  final _lightPts = <List<Offset>>[<Offset>[], <Offset>[], <Offset>[]];
  final _shadePts = <List<Offset>>[<Offset>[], <Offset>[], <Offset>[]];
  final _dot = Paint()
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;
  static const _dotSizes = [1.4, 2.4, 3.8];

  static const _samples = 72;
  final _sx = List<double>.filled(_samples + 1, 0);
  final _sy = List<double>.filled(_samples + 1, 0);

  /// Stable pseudo random in [0, 1) for an integer key (no state, so the
  /// texture never flickers between frames).
  static double _h(int k) {
    final v = math.sin(k * 12.9898 + 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    sim.setSize(size);
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    _paint
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height),
          const [_airTop, _airBottom])
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, _paint);
    _paint.shader = null;

    if (!sim.isEmpty) _paintBeer(canvas, size);
    _paintGlass(canvas, size);
  }

  void _paintBeer(Canvas canvas, Size size) {
    final nx = sim.nx, ny = sim.ny;
    final tx = ny, ty = -nx; // along the surface
    final level = sim.level;
    final w = size.width, h = size.height;
    final diag = math.sqrt(w * w + h * h);

    // Range of the surface line that matters: the screen projected on t.
    final u0 = math.min(math.min(0.0, tx * w), math.min(ty * h, tx * w + ty * h));
    final u1 = math.max(math.max(0.0, tx * w), math.max(ty * h, tx * w + ty * h));
    final span = (u1 - u0) + 40;
    final uStart = u0 - 20;

    // Smooth surface: two slow damped waves plus a fine ripple.
    final amp = sim.waveAmp + (sim.effects && !sim.calm ? 1.2 : 0);
    final k1 = 2 * math.pi / (w * 0.9);
    final k2 = k1 * 1.9;
    final k3 = k1 * 4.7;
    final ph = sim.phase;
    double surfaceD(double u) =>
        level -
        amp *
            (0.58 * math.sin(u * k1 + ph) +
                0.30 * math.sin(u * k2 - ph * 1.3) +
                0.12 * math.sin(u * k3 + ph * 2.1));

    for (var i = 0; i <= _samples; i++) {
      final u = uStart + span * i / _samples;
      final d = surfaceD(u);
      _sx[i] = nx * d + tx * u;
      _sy[i] = ny * d + ty * u;
    }

    // Beer body: surface samples, then far down along gravity.
    _liquid
      ..reset()
      ..moveTo(_sx[0], _sy[0]);
    for (var i = 1; i <= _samples; i++) {
      _liquid.lineTo(_sx[i], _sy[i]);
    }
    final far = diag * 1.3;
    _liquid
      ..lineTo(_sx[_samples] + nx * far, _sy[_samples] + ny * far)
      ..lineTo(_sx[0] + nx * far, _sy[0] + ny * far)
      ..close();

    final fromP = Offset(nx * level, ny * level);
    final toP = Offset(nx * sim.maxProj, ny * sim.maxProj);
    final deepEnd = (toP - fromP).distanceSquared < 1
        ? fromP + Offset(nx, ny) * 40
        : toP;
    _paint
      ..shader = ui.Gradient.linear(
          fromP,
          deepEnd,
          const [_beerTop, _beerMid, _beerLow, _beerDeep],
          const [0.0, 0.32, 0.72, 1.0])
      ..style = PaintingStyle.fill;
    canvas.drawPath(_liquid, _paint);
    _paint.shader = null;

    canvas.save();
    canvas.clipPath(_liquid);

    // Backlight: the beer glows from within, brighter in the middle of the
    // body than at the edges.
    final body = (deepEnd - fromP);
    final glowC = fromP + body * 0.42;
    final glowR = math.max(diag * 0.42, 60.0);
    _paint.shader = ui.Gradient.radial(glowC, glowR,
        const [Color(0x40FFF0B0), Color(0x14FFE58A), Color(0x00FFE58A)],
        const [0.0, 0.55, 1.0]);
    canvas.drawRect(Offset.zero & size, _paint);
    _paint.shader = null;

    // Lacing: a soft lighter band right under the foam.
    final lace = (h * 0.07).clamp(26.0, 70.0);
    _paint.shader = ui.Gradient.linear(
        fromP, fromP + Offset(nx, ny) * lace,
        const [Color(0x55FFF3C4), Color(0x00FFF3C4)]);
    canvas.drawRect(Offset.zero & size, _paint);
    _paint.shader = null;

    // Bubbles: tiny, translucent, with a pinpoint of light. Faint deep down,
    // clearer as they approach the foam.
    if (sim.effects) {
      for (var i = 0; i < sim.bubbleCount; i++) {
        if (!sim.bubbleAlive(i)) continue;
        final x = sim.bubbleX(i), y = sim.bubbleY(i);
        final r = sim.bubbleR(i);
        final depth = nx * x + ny * y - level;
        final near = (1 - depth / (h * 0.5)).clamp(0.0, 1.0).toDouble();
        final a = 0.10 + 0.20 * near + 0.06 * (r / 3.0);
        _bubbleBody.color = Color.fromRGBO(255, 250, 225, a.clamp(0.0, 0.4).toDouble());
        final c = Offset(x, y);
        canvas.drawCircle(c, r, _bubbleBody);
        if (r > 1.3) {
          canvas.drawCircle(c + Offset(-r * 0.32, -r * 0.32), r * 0.28, _bubbleGlint);
        }
      }
    }
    canvas.restore();

    _paintFoam(canvas, size, surfaceD, uStart, span, fromP);
  }

  void _paintFoam(Canvas canvas, Size size, double Function(double) surfaceD,
      double uStart, double span, Offset fromP) {
    final nx = sim.nx, ny = sim.ny;
    final tx = ny, ty = -nx;
    final ph = sim.phase;
    final h = size.height;

    final fade = (sim.volume / 0.08).clamp(0.0, 1.0).toDouble();
    final base = (h * 0.04).clamp(18.0, 46.0) * fade;
    if (base <= 1) return;

    // Foam thickness along the surface: broad lumps plus a finer unevenness.
    double thick(double u) =>
        base *
        (1 +
            0.20 * math.sin(u * 0.037 + 1.7) +
            0.13 * math.sin(u * 0.093 + ph * 0.35) +
            0.08 * math.sin(u * 0.21 + 0.6) +
            0.04 * math.sin(u * 0.47 + ph * 0.8));

    Offset surfacePoint(double u, double lift) {
      final d = surfaceD(u) - lift; // lift moves toward the air
      return Offset(nx * d + tx * u, ny * d + ty * u);
    }

    _foam
      ..reset()
      ..moveTo(_sx[0], _sy[0]);
    for (var i = 1; i <= _samples; i++) {
      _foam.lineTo(_sx[i], _sy[i]);
    }
    for (var i = _samples; i >= 0; i--) {
      final u = uStart + span * i / _samples;
      final p = surfacePoint(u, thick(u));
      _foam.lineTo(p.dx, p.dy);
    }
    _foam.close();

    final top = Offset(nx * (sim.level - base * 1.3), ny * (sim.level - base * 1.3));
    _paint
      ..shader = ui.Gradient.linear(top, fromP + Offset(nx, ny) * 8,
          const [_foamTop, _foamMid, _foamBottom], const [0.0, 0.5, 1.0])
      ..style = PaintingStyle.fill;
    canvas.drawPath(_foam, _paint);
    _paint.shader = null;

    // Micro texture, clipped to the foam: irregular tiny dots, light and
    // shaded, never on a grid.
    canvas.save();
    canvas.clipPath(_foam);
    for (final l in _lightPts) {
      l.clear();
    }
    for (final l in _shadePts) {
      l.clear();
    }
    const step = 4.5;
    final cols = (span / step).floor();
    for (var c = 0; c < cols; c++) {
      for (var row = 0; row < 4; row++) {
        final k = c * 7 + row * 131;
        final u = uStart + (c + _h(k)) * step;
        final t = thick(u);
        final depthAlong = (row + _h(k + 1)) / 4 * (t + 4) - 2;
        final p = surfacePoint(u, depthAlong);
        final cls = _h(k + 2) < 0.62 ? 0 : (_h(k + 2) < 0.92 ? 1 : 2);
        if (_h(k + 3) < 0.42) {
          _shadePts[cls].add(p);
        } else {
          _lightPts[cls].add(p);
        }
      }
    }
    for (var cls = 0; cls < 3; cls++) {
      _dot.strokeWidth = _dotSizes[cls];
      _dot.color = const Color(0x55E6CC93);
      canvas.drawPoints(ui.PointMode.points, _shadePts[cls], _dot);
      _dot.color = const Color(0xAAFFFFFF);
      canvas.drawPoints(ui.PointMode.points, _lightPts[cls], _dot);
    }

    // Soft shading where the foam sits on the beer.
    _paint.shader = ui.Gradient.linear(
        fromP + Offset(nx, ny) * 1,
        fromP - Offset(nx, ny) * (base * 0.8),
        const [Color(0x40D9A12E), Color(0x00D9A12E)]);
    canvas.drawRect(Offset.zero & size, _paint);
    _paint.shader = null;
    canvas.restore();

    // Faint amber line at the foam/beer boundary.
    _lace
      ..reset()
      ..moveTo(_sx[0], _sy[0]);
    for (var i = 1; i <= _samples; i++) {
      _lace.lineTo(_sx[i], _sy[i]);
    }
    _paint
      ..color = const Color(0x30B8780C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(_lace, _paint);
    _paint.style = PaintingStyle.fill;
  }

  /// Reflections of the glass, fixed to the screen: a soft broad band and a
  /// thin sharp one near each side, plus a slight darkening at the edges.
  void _paintGlass(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    void band(double x0, double x1, int alpha) {
      final r = Rect.fromLTRB(w * x0, 0, w * x1, h);
      _paint.shader = ui.Gradient.linear(r.centerLeft, r.centerRight, [
        const Color(0x00FFFFFF),
        Color.fromARGB(alpha, 255, 255, 255),
        const Color(0x00FFFFFF),
      ], const [0.0, 0.5, 1.0]);
      canvas.drawRect(r, _paint);
    }

    band(0.045, 0.16, 26);
    band(0.075, 0.088, 38);
    band(0.86, 0.95, 16);
    band(0.915, 0.923, 24);
    _paint.shader = ui.Gradient.linear(Offset.zero, Offset(w, 0), const [
      Color(0x33000000),
      Color(0x00000000),
      Color(0x00000000),
      Color(0x33000000),
    ], const [
      0.0,
      0.08,
      0.92,
      1.0
    ]);
    canvas.drawRect(Offset.zero & size, _paint);
    _paint.shader = null;
  }

  @override
  bool shouldRepaint(BeerPainter old) => old.sim != sim;
}
