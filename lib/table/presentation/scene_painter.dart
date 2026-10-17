import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/table_scenario.dart';

/// Paints the setting behind the vessels: a back wall/sky and a table surface
/// in light perspective. All decoration is kept low-contrast so the vessels
/// and the controls stay legible.
class ScenePainter extends CustomPainter {
  const ScenePainter(this.scenario, this.tableTop);

  final TableScenario scenario;

  /// y where the table surface begins.
  final double tableTop;

  @override
  void paint(Canvas canvas, Size size) {
    switch (scenario) {
      case TableScenario.bar:
        _bar(canvas, size);
      case TableScenario.club:
        _club(canvas, size);
      case TableScenario.barbecue:
        _barbecue(canvas, size);
      case TableScenario.home:
        _home(canvas, size);
      case TableScenario.beach:
        _beach(canvas, size);
      case TableScenario.restaurant:
        _restaurant(canvas, size);
    }
  }

  void _wall(Canvas c, Size s, Color top, Color bottom) {
    final r = Rect.fromLTWH(0, 0, s.width, tableTop + 2);
    c.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(r),
    );
  }

  void _glow(
    Canvas c,
    Offset center,
    double radius,
    Color color,
    double alpha,
  ) {
    c.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  /// The table top: a trapezoid narrower at the back, so it reads as depth.
  Path _tablePath(Size s) {
    final inset = s.width * 0.05;
    return Path()
      ..moveTo(inset, tableTop)
      ..lineTo(s.width - inset, tableTop)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
  }

  void _table(
    Canvas c,
    Size s, {
    required Color far,
    required Color near,
    required Color lines,
    Color? edge,
    int planks = 7,
  }) {
    final path = _tablePath(s);
    final r = Rect.fromLTWH(0, tableTop, s.width, s.height - tableTop);
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [far, near],
        ).createShader(r),
    );
    final inset = s.width * 0.05;
    final line = Paint()
      ..color = lines
      ..strokeWidth = 1;
    for (var i = 1; i < planks; i++) {
      final f = i / planks;
      c.drawLine(
        Offset(inset + (s.width - 2 * inset) * f, tableTop),
        Offset(s.width * f, s.height),
        line,
      );
    }
    // Soft shade where the table meets the back.
    c.drawRect(
      Rect.fromLTWH(0, tableTop, s.width, 10),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.22), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, tableTop, s.width, 10)),
    );
    c.drawLine(
      Offset(inset, tableTop),
      Offset(s.width - inset, tableTop),
      Paint()
        ..color = edge ?? Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 1.5,
    );
  }

  void _bar(Canvas c, Size s) {
    _wall(c, s, const Color(0xFF2A1A12), const Color(0xFF1A100B));
    // A few bottle silhouettes on a back shelf.
    final shelf = Paint()
      ..color = const Color(0xFF3A271B).withValues(alpha: 0.7);
    final rnd = math.Random(3);
    for (var x = s.width * 0.06; x < s.width * 0.94; x += 16) {
      final h = 14 + rnd.nextInt(14);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, tableTop - 6 - h, 7, h.toDouble()),
          const Radius.circular(2),
        ),
        shelf,
      );
    }
    for (final fx in const [0.2, 0.5, 0.8]) {
      final x = s.width * fx;
      final bottom = s.height * 0.13;
      c.drawLine(
        Offset(x, 0),
        Offset(x, bottom - 12),
        Paint()
          ..color = const Color(0xFF120A06)
          ..strokeWidth = 1.2,
      );
      final lamp = Path()
        ..moveTo(x - 5, bottom - 12)
        ..lineTo(x + 5, bottom - 12)
        ..lineTo(x + 12, bottom)
        ..lineTo(x - 12, bottom)
        ..close();
      c.drawPath(lamp, Paint()..color = const Color(0xFF3B2A1E));
      _glow(
        c,
        Offset(x, bottom + 4),
        s.height * 0.3,
        const Color(0xFFFFB347),
        0.32,
      );
    }
    _table(
      c,
      s,
      far: const Color(0xFF6B4423),
      near: const Color(0xFF8A5A2E),
      lines: Colors.black.withValues(alpha: 0.18),
    );
  }

  void _club(Canvas c, Size s) {
    _wall(c, s, const Color(0xFF0E0B1A), const Color(0xFF161029));
    _glow(
      c,
      Offset(s.width * 0.2, s.height * 0.22),
      s.height * 0.4,
      const Color(0xFFD946EF),
      0.2,
    );
    _glow(
      c,
      Offset(s.width * 0.82, s.height * 0.18),
      s.height * 0.4,
      const Color(0xFF22D3EE),
      0.16,
    );
    _glow(
      c,
      Offset(s.width * 0.52, s.height * 0.3),
      s.height * 0.3,
      const Color(0xFF7C3AED),
      0.14,
    );
    // Faint beams.
    for (final fx in const [0.28, 0.62]) {
      final beam = Path()
        ..moveTo(s.width * fx, 0)
        ..lineTo(s.width * (fx - 0.14), tableTop)
        ..lineTo(s.width * (fx + 0.1), tableTop)
        ..close();
      c.drawPath(beam, Paint()..color = Colors.white.withValues(alpha: 0.04));
    }
    _table(
      c,
      s,
      far: const Color(0xFF14121C),
      near: const Color(0xFF1F1B2D),
      lines: Colors.white.withValues(alpha: 0.04),
      edge: const Color(0xFFD946EF).withValues(alpha: 0.5),
      planks: 5,
    );
    // Glossy reflection streaks.
    final shine = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 6;
    c.drawLine(
      Offset(s.width * 0.22, tableTop + 6),
      Offset(s.width * 0.1, s.height),
      shine,
    );
    c.drawLine(
      Offset(s.width * 0.7, tableTop + 6),
      Offset(s.width * 0.62, s.height),
      shine,
    );
  }

  void _barbecue(Canvas c, Size s) {
    _wall(c, s, const Color(0xFF24304A), const Color(0xFF7A4B2B));
    // Grass strip at the horizon.
    c.drawRect(
      Rect.fromLTWH(0, tableTop - 14, s.width, 16),
      Paint()..color = const Color(0xFF23401F),
    );
    // String lights.
    final wire = Path()
      ..moveTo(0, s.height * 0.06)
      ..quadraticBezierTo(
        s.width * 0.5,
        s.height * 0.2,
        s.width,
        s.height * 0.06,
      );
    c.drawPath(
      wire,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.4),
    );
    for (var i = 1; i < 9; i++) {
      final t = i / 9;
      final x = s.width * t;
      final y =
          s.height * 0.06 + (s.height * 0.14) * 4 * t * (1 - t) * 0.5 * 1.0;
      _glow(c, Offset(x, y + 4), 9, const Color(0xFFFFE08A), 0.5);
      c.drawCircle(
        Offset(x, y + 4),
        2,
        Paint()..color = const Color(0xFFFFE9A8),
      );
    }
    // Checked cloth in perspective.
    final path = _tablePath(s);
    c.drawPath(path, Paint()..color = const Color(0xFFEADFC8));
    final inset = s.width * 0.05;
    const cols = 8;
    const rows = 5;
    final red = Paint()..color = const Color(0xFFB3392F).withValues(alpha: 0.7);
    for (var r = 0; r < rows; r++) {
      for (var cc = 0; cc < cols; cc++) {
        if ((r + cc) % 2 == 1) continue;
        final y0 = tableTop + (s.height - tableTop) * r / rows;
        final y1 = tableTop + (s.height - tableTop) * (r + 1) / rows;
        double xl(double y, int col) {
          final f = (y - tableTop) / (s.height - tableTop);
          final left = inset * (1 - f);
          final width = s.width - 2 * left;
          return left + width * col / cols;
        }

        c.drawPath(
          Path()
            ..moveTo(xl(y0, cc), y0)
            ..lineTo(xl(y0, cc + 1), y0)
            ..lineTo(xl(y1, cc + 1), y1)
            ..lineTo(xl(y1, cc), y1)
            ..close(),
          red,
        );
      }
    }
    c.drawRect(
      Rect.fromLTWH(0, tableTop, s.width, 10),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.22), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, tableTop, s.width, 10)),
    );
  }

  void _home(Canvas c, Size s) {
    _wall(c, s, const Color(0xFF3A2C26), const Color(0xFF2B201B));
    _glow(
      c,
      Offset(s.width * 0.14, s.height * 0.16),
      s.height * 0.3,
      const Color(0xFFFFC27A),
      0.22,
    );
    // Window with warm light.
    final win = Rect.fromLTWH(
      s.width * 0.62,
      s.height * 0.07,
      s.width * 0.28,
      s.height * 0.27,
    );
    c.drawRect(
      win,
      Paint()..color = const Color(0xFFFFD79A).withValues(alpha: 0.30),
    );
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF1B130F);
    c.drawRect(win, frame);
    c.drawLine(
      Offset(win.center.dx, win.top),
      Offset(win.center.dx, win.bottom),
      frame,
    );
    c.drawLine(
      Offset(win.left, win.center.dy),
      Offset(win.right, win.center.dy),
      frame,
    );
    // A plant.
    final leaf = Paint()
      ..color = const Color(0xFF3F6B3B).withValues(alpha: 0.6);
    for (final a in const [-0.5, 0.0, 0.5]) {
      c.save();
      c.translate(s.width * 0.08, tableTop - 2);
      c.rotate(a);
      c.drawOval(const Rect.fromLTWH(-5, -34, 10, 34), leaf);
      c.restore();
    }
    _table(
      c,
      s,
      far: const Color(0xFF8F6B49),
      near: const Color(0xFFA88259),
      lines: Colors.black.withValues(alpha: 0.12),
    );
    // Placemat.
    final mat = Path()
      ..moveTo(s.width * 0.2, tableTop + (s.height - tableTop) * 0.12)
      ..lineTo(s.width * 0.8, tableTop + (s.height - tableTop) * 0.12)
      ..lineTo(s.width * 0.9, s.height - 6)
      ..lineTo(s.width * 0.1, s.height - 6)
      ..close();
    c.drawPath(
      mat,
      Paint()..color = const Color(0xFFD9C7A8).withValues(alpha: 0.35),
    );
  }

  void _beach(Canvas c, Size s) {
    _wall(c, s, const Color(0xFF7CC4F0), const Color(0xFFCFEAFB));
    _glow(
      c,
      Offset(s.width * 0.82, s.height * 0.16),
      s.height * 0.3,
      const Color(0xFFFFE9A3),
      0.7,
    );
    c.drawCircle(
      Offset(s.width * 0.82, s.height * 0.16),
      15,
      Paint()..color = const Color(0xFFFFE08A),
    );
    // Sea band with a few wave strokes.
    c.drawRect(
      Rect.fromLTWH(
        0,
        tableTop - s.height * 0.14,
        s.width,
        s.height * 0.14 + 2,
      ),
      Paint()..color = const Color(0xFF3AA6C9),
    );
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.5);
    for (var i = 0; i < 4; i++) {
      final y = tableTop - s.height * 0.10 + i * 8;
      final p = Path()..moveTo(0, y);
      for (var x = 0.0; x < s.width; x += 24) {
        p.relativeQuadraticBezierTo(6, -4, 12, 0);
        p.relativeQuadraticBezierTo(6, 4, 12, 0);
      }
      c.drawPath(p, wave);
    }
    _table(
      c,
      s,
      far: const Color(0xFFE9D7B0),
      near: const Color(0xFFF2E4C4),
      lines: Colors.transparent,
      edge: Colors.white.withValues(alpha: 0.5),
    );
    // Sand speckles.
    final rnd = math.Random(7);
    final dot = Paint()
      ..color = const Color(0xFFB59A62).withValues(alpha: 0.28);
    for (var i = 0; i < 70; i++) {
      c.drawCircle(
        Offset(
          rnd.nextDouble() * s.width,
          tableTop + rnd.nextDouble() * (s.height - tableTop),
        ),
        0.9,
        dot,
      );
    }
  }

  void _restaurant(Canvas c, Size s) {
    _wall(c, s, const Color(0xFF1F2523), const Color(0xFF171C1B));
    final panel = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = s.width * 0.1; x < s.width; x += s.width * 0.2) {
      c.drawLine(Offset(x, s.height * 0.08), Offset(x, tableTop - 4), panel);
    }
    c.drawLine(
      Offset(0, tableTop - s.height * 0.12),
      Offset(s.width, tableTop - s.height * 0.12),
      panel,
    );
    final x = s.width * 0.5;
    c.drawLine(
      Offset(x, 0),
      Offset(x, s.height * 0.1),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..strokeWidth = 1.2,
    );
    c.drawCircle(
      Offset(x, s.height * 0.12),
      7,
      Paint()..color = const Color(0xFF2E3633),
    );
    _glow(
      c,
      Offset(x, s.height * 0.14),
      s.height * 0.22,
      const Color(0xFFFFE2B0),
      0.18,
    );
    _table(
      c,
      s,
      far: const Color(0xFFEDEAE3),
      near: const Color(0xFFD9D5CB),
      lines: Colors.black.withValues(alpha: 0.06),
      edge: Colors.white.withValues(alpha: 0.6),
      planks: 4,
    );
  }

  @override
  bool shouldRepaint(ScenePainter old) =>
      old.scenario != scenario || old.tableTop != tableTop;
}
