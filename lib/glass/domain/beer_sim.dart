import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';

/// Visual simulation of a beer that fills the whole screen. It knows nothing
/// about drinks, records or goals: it has its own fill level.
///
/// Frame: screen coordinates, x to the right, y down, origin at the top-left.
/// [angle] is the direction of "down" in that frame: 0 = down is the bottom
/// of the screen, positive = down points towards the right edge (the phone is
/// leaned to the right). The unit vector of "down" is `n = (sin a, cos a)`.
/// The beer surface is the line `n·p = level`; the liquid is `n·p >= level`.
///
/// The container is the screen. Its mouth is the top edge: liquid that would
/// sit above the lowest point of that edge leaves through it.
class BeerSim extends ChangeNotifier {
  BeerSim({this.initialFill = 0.78, int bubbleCount = 72})
      : volume = initialFill,
        _bx = Float32List(bubbleCount),
        _by = Float32List(bubbleCount),
        _br = Float32List(bubbleCount),
        _bs = Float32List(bubbleCount),
        _bp = Float32List(bubbleCount),
        _balive = Uint8List(bubbleCount);

  /// Fraction of the screen filled by a fresh glass (leaves air on top).
  final double initialFill;

  // ---- Settings ------------------------------------------------------------
  /// Waves, wobble and bubbles. Off = calm, critically damped surface.
  bool effects = true;

  /// Fewer bubbles, smaller waves, no oscillation (reduce-motion preference).
  bool calm = false;

  // ---- State ---------------------------------------------------------------
  Size size = Size.zero;
  double angle = 0;
  double angularVelocity = 0;

  /// Liquid volume as a fraction (0..1) of the screen area.
  double volume;
  double waveAmp = 0;
  double _phase = 0;
  double _time = 0;

  /// True while liquid is leaving through the mouth.
  bool pouring = false;

  /// Distance (px) of the surface line from the origin along `n`.
  double level = 0;

  /// Smallest/largest projection of the screen corners on `n`.
  double minProj = 0;
  double maxProj = 0;

  bool get isEmpty => volume < 0.003;

  double get nx => math.sin(angle);
  double get ny => math.cos(angle);
  double get time => _time;
  double get phase => _phase;

  // ---- Bubbles (struct of arrays, no per-frame allocation) -----------------
  final Float32List _bx, _by, _br, _bs, _bp;
  final Uint8List _balive;
  final _rand = math.Random(7);
  int get bubbleCount => _bx.length;
  int get activeBubbles => calm ? bubbleCount ~/ 3 : bubbleCount;
  bool bubbleAlive(int i) => _balive[i] == 1;
  double bubbleX(int i) => _bx[i];
  double bubbleY(int i) => _by[i];
  double bubbleR(int i) => _br[i];

  final _poly = Float64List(24);

  // ---- Geometry ------------------------------------------------------------

  /// Fraction of the screen where `n·p >= s`.
  double areaFraction(double s) {
    final w = size.width, h = size.height;
    if (w <= 0 || h <= 0) return 0;
    final nx = this.nx, ny = this.ny;
    // Rectangle corners, counter-clockwise.
    final cx = _cornersX, cy = _cornersY;
    cx[0] = 0;
    cy[0] = 0;
    cx[1] = w;
    cy[1] = 0;
    cx[2] = w;
    cy[2] = h;
    cx[3] = 0;
    cy[3] = h;
    var count = 0;
    final out = _poly;
    for (var i = 0; i < 4; i++) {
      final j = (i + 1) & 3;
      final di = nx * cx[i] + ny * cy[i] - s;
      final dj = nx * cx[j] + ny * cy[j] - s;
      if (di >= 0) {
        out[count * 2] = cx[i];
        out[count * 2 + 1] = cy[i];
        count++;
      }
      if ((di >= 0) != (dj >= 0)) {
        final t = di / (di - dj);
        out[count * 2] = cx[i] + (cx[j] - cx[i]) * t;
        out[count * 2 + 1] = cy[i] + (cy[j] - cy[i]) * t;
        count++;
      }
    }
    if (count < 3) return 0;
    var a = 0.0;
    for (var i = 0; i < count; i++) {
      final j = (i + 1) % count;
      a += out[i * 2] * out[j * 2 + 1] - out[j * 2] * out[i * 2 + 1];
    }
    return (a.abs() / 2 / (w * h)).clamp(0.0, 1.0).toDouble();
  }

  final _cornersX = Float64List(4);
  final _cornersY = Float64List(4);

  /// The surface level that holds exactly [v] of the screen (bisection on the
  /// exact half-plane area), so the volume is conserved at every angle.
  double levelFor(double v) {
    var lo = minProj, hi = maxProj;
    if (v <= 0) return hi;
    if (v >= 1) return lo;
    for (var i = 0; i < 22; i++) {
      final mid = (lo + hi) / 2;
      if (areaFraction(mid) > v) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  /// Largest volume that stays inside: the surface may not rise above the
  /// lowest point of the top edge, `max(0, nx·W)`.
  double capacity() {
    final m = math.max(0.0, nx * size.width);
    return areaFraction(m);
  }

  void _updateProjections() {
    final w = size.width, h = size.height;
    final nx = this.nx, ny = this.ny;
    final a = 0.0, b = nx * w, c = ny * h, d = nx * w + ny * h;
    minProj = math.min(math.min(a, b), math.min(c, d));
    maxProj = math.max(math.max(a, b), math.max(c, d));
  }

  // ---- Actions -------------------------------------------------------------

  void setSize(Size s) {
    if (s == size) return;
    final first = size == Size.zero;
    size = s;
    _updateProjections();
    level = levelFor(volume);
    if (first) {
      for (var i = 0; i < bubbleCount; i++) {
        _respawn(i, anywhere: true);
      }
    }
  }

  /// Refill the glass. Animated by [step] so it does not jump.
  bool refilling = false;
  void refill() {
    refilling = true;
    notifyListeners();
  }

  /// Back to level without touching the volume.
  void settle() {
    angle = 0;
    angularVelocity = 0;
    waveAmp = 0;
  }

  // ---- Step ----------------------------------------------------------------

  /// Advances the simulation by [dt] seconds towards [targetAngle].
  void step(double dt, double targetAngle) {
    if (size == Size.zero) return;
    dt = dt.clamp(0.0, 0.05).toDouble();
    if (dt <= 0) return;
    _time += dt;

    // Substeps keep the spring stable if a frame is long.
    final sub = dt > 1 / 90 ? 2 : 1;
    final h = dt / sub;
    final omega = calm ? 12.0 : 9.5;
    final zeta = (calm || !effects) ? 1.0 : 0.32;
    for (var i = 0; i < sub; i++) {
      var diff = targetAngle - angle;
      // Shortest way round: crossing +-pi never makes the liquid jump.
      diff = (diff + math.pi) % (2 * math.pi) - math.pi;
      final acc = omega * omega * diff - 2 * zeta * omega * angularVelocity;
      angularVelocity += acc * h;
      angle += angularVelocity * h;
    }
    angle = (angle + math.pi) % (2 * math.pi) - math.pi;
    _updateProjections();

    // Waves: excited by how fast the surface turns, then damped.
    final amplitudeCap = size.height * 0.018;
    if (effects && !calm) {
      waveAmp += angularVelocity.abs() * size.height * 0.012 * dt * 3;
      waveAmp = math.min(waveAmp, amplitudeCap);
    }
    waveAmp *= math.exp(-1.7 * dt);
    _phase += dt * (3.2 + waveAmp * 0.05);

    // Refill (smooth) or pour out through the mouth.
    if (refilling) {
      volume = math.min(initialFill, volume + 0.4 * dt);
      if (volume >= initialFill) refilling = false;
    }
    final cap = capacity();
    final excess = volume - cap;
    pouring = excess > 0.0005 && !refilling;
    if (pouring) {
      final tilt = (angle.abs() / (math.pi / 2)).clamp(0.0, 1.0).toDouble();
      final rate = 0.05 + 0.55 * tilt;
      volume -= math.min(excess, rate * dt + excess * 1.5 * dt);
      if (volume < 0.0005) volume = 0;
    }
    level = levelFor(volume);

    _stepBubbles(dt);
    notifyListeners();
  }

  // ---- Bubbles -------------------------------------------------------------

  void _respawn(int i, {bool anywhere = false}) {
    final w = size.width, h = size.height;
    for (var tries = 0; tries < 6; tries++) {
      final x = _rand.nextDouble() * w;
      final y = _rand.nextDouble() * h;
      final depth = nx * x + ny * y - level;
      if (depth > 10) {
        _bx[i] = x;
        _by[i] = y;
        final big = _rand.nextDouble();
        _br[i] = 0.7 + big * big * big * 2.3;
        _bs[i] = 18 + _rand.nextDouble() * 70;
        _bp[i] = _rand.nextDouble() * 6.28;
        _balive[i] = 1;
        return;
      }
    }
    _balive[i] = 0;
  }

  void _stepBubbles(double dt) {
    final active = (effects ? activeBubbles : 0);
    final nx = this.nx, ny = this.ny;
    for (var i = 0; i < bubbleCount; i++) {
      if (i >= active) {
        _balive[i] = 0;
        continue;
      }
      if (_balive[i] == 0) {
        if (!isEmpty) _respawn(i);
        continue;
      }
      // Bubbles rise against gravity, with a slight sideways wobble.
      final speed = _bs[i] * (calm ? 0.5 : 1.0) * (0.6 + _br[i] * 0.15);
      final wob = math.sin(_time * 2.2 + _bp[i]) * 6;
      _bx[i] += (-nx * speed + ny * wob) * dt;
      _by[i] += (-ny * speed - nx * wob) * dt;
      final depth = nx * _bx[i] + ny * _by[i] - level;
      final out = _bx[i] < -8 ||
          _bx[i] > size.width + 8 ||
          _by[i] < -8 ||
          _by[i] > size.height + 8;
      if (depth < _br[i] + 2 || out) _respawn(i);
    }
  }
}
