import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/beer_sim.dart';

/// Draws the beer filling the whole canvas. It repaints from [BeerSim] alone
/// (no widget rebuild per frame) and keeps its paints and paths between
/// frames. Nothing is rotated as a whole: the surface, foam and bubbles are
/// computed from the gravity direction.
class BeerPainter extends CustomPainter {
  BeerPainter(this.sim) : super(repaint: sim);

  final BeerSim sim;

  static const _airTop = Color(0xFF241608);
  static const _airBottom = Color(0xFF3A2410);
  static const _beerLight = Color(0xFFF6BE3B);
  static const _beerMid = Color(0xFFE39A16);
  static const _beerDeep = Color(0xFFA85E08);
  static const _foamLight = Color(0xFFFFF7E0);
  static const _foamDark = Color(0xFFF1DDA6);

  final _paint = Paint()..isAntiAlias = true;
  final _bubbleFill = Paint()
    ..isAntiAlias = true
    ..color = const Color(0x2EFFFFFF);
  final _bubbleLine = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0x66FFFFFF);
  final _liquid = Path();
  final _foam = Path();
  static const _samples = 30;
  final _sx = List<double>.filled(_samples + 1, 0);
  final _sy = List<double>.filled(_samples + 1, 0);

  @override
  void paint(Canvas canvas, Size size) {
    sim.setSize(size);
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    // Air behind the beer: a warm dark backdrop so the beer is the subject.
    _paint
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height),
          const [_airTop, _airBottom])
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, _paint);
    _paint.shader = null;

    if (sim.isEmpty) return;

    final nx = sim.nx, ny = sim.ny;
    final tx = ny, ty = -nx; // along the surface
    final level = sim.level;
    final diag = math.sqrt(size.width * size.width + size.height * size.height);

    // Range of the surface line that matters: the screen projected on t.
    final w = size.width, h = size.height;
    final u0 = math.min(math.min(0.0, tx * w), math.min(ty * h, tx * w + ty * h));
    final u1 = math.max(math.max(0.0, tx * w), math.max(ty * h, tx * w + ty * h));
    final span = (u1 - u0) + 40;
    final uStart = u0 - 20;

    // Surface samples with small damped waves.
    final amp = sim.waveAmp + (sim.effects && !sim.calm ? 1.4 : 0);
    final k1 = 2 * math.pi / (w * 0.9);
    final k2 = k1 * 1.9;
    final ph = sim.phase;
    for (var i = 0; i <= _samples; i++) {
      final u = uStart + span * i / _samples;
      final wave = amp *
          (0.62 * math.sin(u * k1 + ph) + 0.38 * math.sin(u * k2 - ph * 1.3));
      final d = level - wave; // positive wave moves the surface up (air side)
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
    final shaderEnd = (toP - fromP).distanceSquared < 1
        ? fromP + Offset(nx, ny) * 40
        : toP;
    _paint
      ..shader = ui.Gradient.linear(fromP, shaderEnd,
          const [_beerLight, _beerMid, _beerDeep], const [0.0, 0.45, 1.0])
      ..style = PaintingStyle.fill;
    canvas.drawPath(_liquid, _paint);
    _paint.shader = null;

    // Bubbles, kept inside the liquid.
    if (sim.effects) {
      canvas.save();
      canvas.clipPath(_liquid);
      for (var i = 0; i < sim.bubbleCount; i++) {
        if (!sim.bubbleAlive(i)) continue;
        final c = Offset(sim.bubbleX(i), sim.bubbleY(i));
        final r = sim.bubbleR(i);
        canvas.drawCircle(c, r, _bubbleFill);
        canvas.drawCircle(c, r, _bubbleLine);
      }
      canvas.restore();
    }

    // Foam: a band on the air side of the surface, with an uneven top edge.
    final fade = (sim.volume / 0.08).clamp(0.0, 1.0).toDouble();
    final base = (h * 0.034).clamp(16.0, 38.0) * fade;
    if (base > 1) {
      _foam
        ..reset()
        ..moveTo(_sx[0], _sy[0]);
      for (var i = 1; i <= _samples; i++) {
        _foam.lineTo(_sx[i], _sy[i]);
      }
      for (var i = _samples; i >= 0; i--) {
        final u = uStart + span * i / _samples;
        final t = base *
            (1 +
                0.22 * math.sin(u * 0.043 + 1.7) +
                0.14 * math.sin(u * 0.11 + ph * 0.4) +
                0.08 * math.sin(u * 0.27));
        _foam.lineTo(_sx[i] - nx * t, _sy[i] - ny * t);
      }
      _foam.close();
      final up = Offset(nx * (level - base), ny * (level - base));
      _paint
        ..shader = ui.Gradient.linear(
            up, fromP + Offset(nx, ny) * 6, const [_foamLight, _foamDark])
        ..style = PaintingStyle.fill;
      canvas.drawPath(_foam, _paint);
      _paint.shader = null;

      // Small, irregular beads along the foam edge (never big circles).
      _paint
        ..color = const Color(0xCCFFF9E8)
        ..style = PaintingStyle.fill;
      for (var i = 0; i <= _samples; i++) {
        final u = uStart + span * i / _samples;
        final t = base *
            (1 +
                0.22 * math.sin(u * 0.043 + 1.7) +
                0.14 * math.sin(u * 0.11 + ph * 0.4) +
                0.08 * math.sin(u * 0.27));
        final r = 2.0 + 2.6 * (0.5 + 0.5 * math.sin(i * 12.9898));
        canvas.drawCircle(
            Offset(_sx[i] - nx * (t - r * 0.4), _sy[i] - ny * (t - r * 0.4)),
            r,
            _paint);
      }
      // Thin darker line where foam meets beer.
      _paint
        ..color = const Color(0x33A85E08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      _foam
        ..reset()
        ..moveTo(_sx[0], _sy[0]);
      for (var i = 1; i <= _samples; i++) {
        _foam.lineTo(_sx[i], _sy[i]);
      }
      canvas.drawPath(_foam, _paint);
      _paint.style = PaintingStyle.fill;
    }

    // A faint glossy edge on the side the beer leans against, for depth.
    final sheen = Offset(nx, ny);
    _paint.shader = ui.Gradient.linear(
        Offset(size.width / 2, size.height / 2) - sheen * (diag / 2),
        Offset(size.width / 2, size.height / 2) + sheen * (diag / 2),
        const [Color(0x00000000), Color(0x00000000), Color(0x22000000)],
        const [0.0, 0.6, 1.0]);
    canvas.drawPath(_liquid, _paint);
    _paint.shader = null;
  }

  @override
  bool shouldRepaint(BeerPainter old) => old.sim != sim;
}
