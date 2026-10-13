import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/drink_vessel.dart';

/// Canonical drawing box of a vessel. Everything is drawn in these units and
/// scaled to the widget size.
const double kVesselW = 56;
const double kVesselH = 92;

/// Draws one vessel (can, bottle, glass...) with its liquid level.
///
/// The level comes from [fillAt] evaluated at the shared [clock], so only this
/// small painter repaints as time passes; no widget is rebuilt per frame.
class VesselPainter extends CustomPainter {
  VesselPainter({
    required this.kind,
    required this.liquid,
    required this.fillAt,
    required this.clock,
    required this.signature,
    this.foam = false,
    this.fixedNow,
  }) : super(repaint: clock);

  final VesselKind kind;
  final Color liquid;
  final bool foam;

  /// Fill level (0..1) at a given time.
  final double Function(DateTime now) fillAt;
  final ValueListenable<DateTime> clock;

  /// Changes when the record changes, so a repaint is forced.
  final Object signature;

  /// When set (animations off), the level is drawn for this instant and the
  /// clock is ignored: a static picture that updates on rebuild.
  final DateTime? fixedNow;

  static const _foamColor = Color(0xFFFFF3D6);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = fillAt(fixedNow ?? clock.value).clamp(0.0, 1.0).toDouble();
    canvas.save();
    canvas.scale(size.width / kVesselW, size.height / kVesselH);
    canvas.drawOval(
      const Rect.fromLTWH(8, 83, 40, 8),
      Paint()..color = Colors.black.withValues(alpha: 0.30),
    );
    switch (kind) {
      case VesselKind.beerGlass:
        _tumbler(canvas, _beerPath(), 22, 84, fill, foam: foam);
      case VesselKind.draftMug:
        _mug(canvas, fill);
      case VesselKind.shot:
        _tumbler(canvas, _shotPath(), 52, 84, fill, opaque: true);
      case VesselKind.wineGlass:
        _wine(canvas, fill);
      case VesselKind.cocktailGlass:
        _cocktail(canvas, fill);
      case VesselKind.waterGlass:
        _water(canvas, fill);
      case VesselKind.genericGlass:
        _tumbler(canvas, _genericPath(), 30, 84, fill);
      case VesselKind.can:
        _can(canvas, fill);
      case VesselKind.longNeck:
        _bottle(canvas, _longNeckPath(), fill, const Rect.fromLTWH(15, 58, 26, 18),
            capRect: const Rect.fromLTWH(23, 5, 10, 4));
      case VesselKind.bottle:
        _bottle(canvas, _bottlePath(), fill, const Rect.fromLTWH(12, 56, 32, 22),
            capRect: const Rect.fromLTWH(22, 1, 12, 4));
    }
    canvas.restore();
  }

  // ---- shared drawing helpers -------------------------------------------------

  Color _darker(Color c, [double amount = 0.14]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0).toDouble())
        .toColor();
  }

  Paint get _outline => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.white.withValues(alpha: 0.6);

  void _fillLiquid(
    Canvas c,
    Path clip,
    double top,
    double bottom,
    double fill, {
    bool foam = false,
    bool opaque = false,
  }) {
    if (fill <= 0.01) return;
    final y = bottom - (bottom - top) * fill;
    c.save();
    c.clipPath(clip);
    final rect = Rect.fromLTRB(0, y, kVesselW, bottom + 2);
    c.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [liquid, _darker(liquid, opaque ? 0.22 : 0.12)],
        ).createShader(rect),
    );
    if (foam && fill > 0.08) {
      final f = Paint()..color = _foamColor;
      c.drawRect(Rect.fromLTRB(0, y - 4, kVesselW, y + 3), f);
      for (var i = 0; i < 6; i++) {
        c.drawCircle(Offset(6.0 + i * 8.5, y - 4), 4.2, f);
      }
    }
    c.restore();
  }

  void _glassBody(Canvas c, Path p) {
    c.drawPath(p, Paint()..color = Colors.white.withValues(alpha: 0.10));
  }

  void _highlight(Canvas c, Rect r) {
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(2)),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
  }

  void _tumbler(
    Canvas c,
    Path p,
    double top,
    double bottom,
    double fill, {
    bool foam = false,
    bool opaque = false,
  }) {
    _glassBody(c, p);
    _fillLiquid(c, p, top, bottom, fill, foam: foam, opaque: opaque);
    _highlight(c, Rect.fromLTWH(15, top + 4, 3, (bottom - top) * 0.55));
    c.drawPath(p, _outline);
  }

  // ---- silhouettes ------------------------------------------------------------

  Path _beerPath() => Path()
    ..moveTo(8, 18)
    ..lineTo(48, 18)
    ..lineTo(42, 84)
    ..quadraticBezierTo(42, 86, 40, 86)
    ..lineTo(16, 86)
    ..quadraticBezierTo(14, 86, 14, 84)
    ..close();

  Path _shotPath() => Path()
    ..moveTo(16, 48)
    ..lineTo(40, 48)
    ..lineTo(37, 84)
    ..quadraticBezierTo(37, 86, 35, 86)
    ..lineTo(21, 86)
    ..quadraticBezierTo(19, 86, 19, 84)
    ..close();

  Path _genericPath() => Path()
    ..moveTo(11, 26)
    ..lineTo(45, 26)
    ..lineTo(41, 84)
    ..quadraticBezierTo(41, 86, 39, 86)
    ..lineTo(17, 86)
    ..quadraticBezierTo(15, 86, 15, 84)
    ..close();

  Path _longNeckPath() => Path()
    ..moveTo(24, 8)
    ..lineTo(32, 8)
    ..lineTo(32, 32)
    ..quadraticBezierTo(42, 42, 42, 54)
    ..lineTo(42, 84)
    ..quadraticBezierTo(42, 86, 40, 86)
    ..lineTo(16, 86)
    ..quadraticBezierTo(14, 86, 14, 84)
    ..lineTo(14, 54)
    ..quadraticBezierTo(14, 42, 24, 32)
    ..close();

  Path _bottlePath() => Path()
    ..moveTo(23, 4)
    ..lineTo(33, 4)
    ..lineTo(33, 28)
    ..quadraticBezierTo(45, 40, 45, 52)
    ..lineTo(45, 84)
    ..quadraticBezierTo(45, 86, 43, 86)
    ..lineTo(13, 86)
    ..quadraticBezierTo(11, 86, 11, 84)
    ..lineTo(11, 52)
    ..quadraticBezierTo(11, 40, 23, 28)
    ..close();

  // ---- vessels with their own details --------------------------------------------

  void _mug(Canvas c, double fill) {
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 22, 32, 64), const Radius.circular(4)));
    _glassBody(c, body);
    _fillLiquid(c, body, 26, 78, fill, foam: foam);
    c.drawRect(
      const Rect.fromLTWH(8, 78, 32, 8),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    _highlight(c, const Rect.fromLTWH(12, 30, 3, 36));
    c.drawPath(body, _outline);
    final handle = Path()
      ..moveTo(40, 33)
      ..cubicTo(55, 33, 55, 73, 40, 73);
    c.drawPath(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  void _wine(Canvas c, double fill) {
    final bowl = Path()
      ..moveTo(17, 14)
      ..quadraticBezierTo(15, 44, 28, 52)
      ..quadraticBezierTo(41, 44, 39, 14)
      ..close();
    _glassBody(c, bowl);
    _fillLiquid(c, bowl, 20, 50, fill);
    c.drawRect(
      const Rect.fromLTWH(26.8, 52, 2.4, 28),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    c.drawOval(
      const Rect.fromLTWH(16, 78, 24, 6),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    _highlight(c, const Rect.fromLTWH(20, 18, 2.5, 18));
    c.drawPath(bowl, _outline);
  }

  void _cocktail(Canvas c, double fill) {
    final body = Path()
      ..moveTo(10, 34)
      ..lineTo(46, 34)
      ..lineTo(43, 84)
      ..quadraticBezierTo(43, 86, 41, 86)
      ..lineTo(15, 86)
      ..quadraticBezierTo(13, 86, 13, 84)
      ..close();
    // Straw behind the glass front.
    c.drawLine(
      const Offset(30, 18),
      const Offset(36, 62),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFF8FB1).withValues(alpha: 0.85),
    );
    _glassBody(c, body);
    _fillLiquid(c, body, 38, 84, fill);
    if (fill > 0.3) {
      final ice = Paint()..color = Colors.white.withValues(alpha: 0.28);
      for (final r in const [
        Rect.fromLTWH(18, 46, 10, 10),
        Rect.fromLTWH(30, 52, 9, 9),
        Rect.fromLTWH(21, 64, 10, 10),
      ]) {
        c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), ice);
      }
    }
    _highlight(c, const Rect.fromLTWH(15, 40, 3, 30));
    c.drawPath(body, _outline);
    // Garnish slice on the rim.
    c.drawCircle(
      const Offset(44, 34),
      7,
      Paint()..color = const Color(0xFFFFA54A).withValues(alpha: 0.35),
    );
    c.drawCircle(
      const Offset(44, 34),
      7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFFFFA54A),
    );
  }

  void _water(Canvas c, double fill) {
    final body = Path()
      ..moveTo(12, 28)
      ..lineTo(44, 28)
      ..lineTo(42, 86)
      ..lineTo(14, 86)
      ..close();
    _tumbler(c, body, 32, 84, fill);
    if (fill > 0.2) {
      final b = Paint()..color = Colors.white.withValues(alpha: 0.5);
      c.drawCircle(const Offset(24, 62), 1.3, b);
      c.drawCircle(const Offset(32, 50), 1.7, b);
      c.drawCircle(const Offset(28, 74), 1.0, b);
    }
  }

  void _can(Canvas c, double fill) {
    const bodyRect = Rect.fromLTWH(14, 20, 28, 66);
    final body = RRect.fromRectAndRadius(bodyRect, const Radius.circular(4));
    c.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9AA0A8), Color(0xFFE6E9ED), Color(0xFF9AA0A8)],
        ).createShader(bodyRect),
    );
    // Label band: colour by category, plus two stripes (shape, not only colour).
    c.drawRect(const Rect.fromLTWH(14, 36, 28, 28), Paint()..color = liquid);
    final stripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.5;
    c.drawLine(const Offset(14, 43), const Offset(42, 43), stripe);
    c.drawLine(const Offset(14, 57), const Offset(42, 57), stripe);
    c.drawOval(
      const Rect.fromLTWH(14, 17, 28, 7),
      Paint()..color = const Color(0xFFD3D7DC),
    );
    c.drawCircle(const Offset(28, 20.5), 2.4,
        Paint()..color = const Color(0xFF8A9099));
    c.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.4),
    );
    // A can is opaque, so its level is shown on a small gauge beside it.
    final track = RRect.fromRectAndRadius(
        const Rect.fromLTWH(46, 22, 4, 62), const Radius.circular(2));
    c.drawRRect(track, Paint()..color = Colors.white.withValues(alpha: 0.15));
    final h = 62 * fill;
    if (h > 0.5) {
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(46, 84 - h, 4, h), const Radius.circular(2)),
        Paint()..color = liquid,
      );
    }
  }

  void _bottle(Canvas c, Path p, double fill, Rect label, {required Rect capRect}) {
    c.drawPath(p, Paint()..color = const Color(0xFF4A2C12).withValues(alpha: 0.55));
    _fillLiquid(c, p, 12, 84, fill);
    c.drawRRect(
      RRect.fromRectAndRadius(label, const Radius.circular(2)),
      Paint()..color = const Color(0xFFF3E6C8).withValues(alpha: 0.92),
    );
    c.drawRect(
      Rect.fromLTWH(label.left, label.center.dy - 1.5, label.width, 3),
      Paint()..color = liquid,
    );
    _highlight(c, Rect.fromLTWH(label.left + 1, label.top - 22, 2.5, 18));
    c.drawPath(p, _outline);
    c.drawRRect(
      RRect.fromRectAndRadius(capRect, const Radius.circular(1.5)),
      Paint()..color = const Color(0xFFE0B040),
    );
  }

  @override
  bool shouldRepaint(VesselPainter old) =>
      old.kind != kind ||
      old.liquid != liquid ||
      old.foam != foam ||
      old.signature != signature ||
      old.fixedNow != fixedNow;
}
