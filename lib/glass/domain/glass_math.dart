import 'dart:math' as math;
import 'dart:ui';

import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../l10n/l10n.dart';

/// Scale of the accumulated-volume glass: the smallest step that holds the
/// known total, so the glass never overflows and the scale is always stated.
/// It is a way to read the number, not a capacity or a goal.
int glassScaleMl(int totalMl) {
  const steps = [500, 1000, 2000, 3000, 5000, 10000, 20000];
  for (final s in steps) {
    if (totalMl <= s) return s;
  }
  // Beyond the table: round up to the next 10 L.
  return ((totalMl / 10000).ceil()) * 10000;
}

/// "850 ml" below 1 L, "1,45 L" above (decimal mark of the language on screen).
String formatVolume(int ml) {
  if (ml < 1000) return formatMl(ml);
  return tr.unitLiters(NumberFormat('#,##0.##', trLocaleTag).format(ml / 1000));
}

/// Fraction (0..1) of a w×h glass that can stay in it when it is tilted by
/// [theta] radians (0 = upright) before liquid spills over the lower rim.
double maxFillAtTilt(double theta, double w, double h) {
  final t = theta.abs().clamp(0.0, math.pi / 2 - 0.001).toDouble();
  if (t < 1e-6) return 1;
  final tan = math.tan(t);
  if (w * tan <= h) {
    return (1 - (w / (2 * h)) * tan).clamp(0.0, 1.0).toDouble();
  }
  return (0.5 * h / (w * tan)).clamp(0.0, 1.0).toDouble();
}

/// The liquid polygon inside a rectangle of size [w]×[h] (origin at its top
/// left, y down) rotated by [theta] around its centre, when the liquid holds
/// [fill] of the area and its surface stays horizontal in the world.
/// Coordinates are in the rectangle's own (unrotated) frame.
List<Offset> liquidPolygon(double fill, double theta, double w, double h) {
  if (fill <= 0) return const [];
  final corners = [
    Offset(0, 0),
    Offset(w, 0),
    Offset(w, h),
    Offset(0, h),
  ];
  if (fill >= 1) return corners;
  final c = Offset(w / 2, h / 2);
  // World "down" expressed in the glass frame.
  final down = Offset(math.sin(theta), math.cos(theta));
  // Liquid = points whose projection on `down` is >= level.
  double areaFor(double level) {
    final poly = _clip(corners, c, down, level);
    return _area(poly);
  }

  final target = fill * w * h;
  var lo = -(w + h);
  var hi = w + h;
  for (var i = 0; i < 40; i++) {
    final mid = (lo + hi) / 2;
    // A higher level keeps less liquid.
    if (areaFor(mid) > target) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return _clip(corners, c, down, (lo + hi) / 2);
}

List<Offset> _clip(List<Offset> poly, Offset c, Offset down, double level) {
  double d(Offset p) => (p - c).dx * down.dx + (p - c).dy * down.dy - level;
  final out = <Offset>[];
  for (var i = 0; i < poly.length; i++) {
    final a = poly[i];
    final b = poly[(i + 1) % poly.length];
    final da = d(a);
    final db = d(b);
    if (da >= 0) out.add(a);
    if ((da >= 0) != (db >= 0)) {
      final t = da / (da - db);
      out.add(Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t));
    }
  }
  return out;
}

double _area(List<Offset> p) {
  if (p.length < 3) return 0;
  var s = 0.0;
  for (var i = 0; i < p.length; i++) {
    final a = p[i];
    final b = p[(i + 1) % p.length];
    s += a.dx * b.dy - b.dx * a.dy;
  }
  return s.abs() / 2;
}
