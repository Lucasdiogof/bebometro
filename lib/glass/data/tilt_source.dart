import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Turns the accelerometer (which includes gravity) into the direction of
/// "down" in the plane of the screen.
///
/// The portrait screen is assumed to be locked while this is running, so the
/// device axes are the screen axes: x to the right, y towards the top edge,
/// z out of the screen. At rest the accelerometer reads the reaction to
/// gravity (about +9.8 on y when upright), so gravity in screen coordinates
/// (x right, y down) is `(-ax, +ay)`. Linear acceleration with gravity removed
/// is never used.
class TiltSource {
  /// Seconds of the low-pass filter: removes hand tremor, keeps real tilts.
  static const _tau = 0.09;

  /// Share of the in-plane gravity below which the phone is "nearly flat" and
  /// the direction stops being trustworthy.
  static const _flatLow = 0.12;
  static const _flatHigh = 0.32;

  StreamSubscription<AccelerometerEvent>? _sub;
  final _clock = Stopwatch()..start();
  double _lastAt = 0;
  double _fx = 0, _fy = 9.8, _fz = 0;
  bool _seeded = false;
  double _stableAngle = 0;
  double _ramp = 0;

  /// Called when the sensor is missing or reports an error.
  VoidCallback? onUnavailable;

  /// True once at least one reading arrived.
  bool hasData = false;

  /// Smoothed angle of "down" (see BeerSim.angle), already faded towards
  /// level when the phone is nearly flat and eased in after start.
  double angle = 0;

  bool get running => _sub != null;

  void start() {
    if (_sub != null) return;
    _lastAt = _clock.elapsedMicroseconds / 1e6;
    _ramp = 0;
    try {
      _sub = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(_onEvent, onError: (Object _) => _fail(), cancelOnError: true);
    } catch (_) {
      _fail();
    }
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    // After a pause the first reading must not be blended with an old one.
    _seeded = false;
  }

  void dispose() => stop();

  void _fail() {
    stop();
    onUnavailable?.call();
  }

  void _onEvent(AccelerometerEvent e) {
    final now = _clock.elapsedMicroseconds / 1e6;
    final dt = (now - _lastAt).clamp(0.0, 0.2).toDouble();
    _lastAt = now;
    if (!_seeded) {
      _fx = e.x;
      _fy = e.y;
      _fz = e.z;
      _seeded = true;
    } else {
      final k = 1 - math.exp(-dt / _tau);
      _fx += (e.x - _fx) * k;
      _fy += (e.y - _fy) * k;
      _fz += (e.z - _fz) * k;
    }
    hasData = true;

    final norm = math.sqrt(_fx * _fx + _fy * _fy + _fz * _fz);
    // Free fall or a violent shake: gravity is not readable, keep the last.
    if (norm < 3) return;

    final gx = -_fx, gy = _fy; // gravity in screen coordinates
    final inPlane = math.sqrt(gx * gx + gy * gy);
    final share = inPlane / norm;
    if (share > _flatLow) _stableAngle = math.atan2(gx, gy);
    // Nearly flat: fade to level instead of trusting a tiny, noisy vector.
    final trust = _smoothstep(_flatLow, _flatHigh, share);
    // Ease in after start so the liquid does not jump.
    _ramp = math.min(1, _ramp + dt / 0.9);
    angle = _stableAngle * trust * _smoothstep(0, 1, _ramp);
  }

  static double _smoothstep(double a, double b, double x) {
    final t = ((x - a) / (b - a)).clamp(0.0, 1.0).toDouble();
    return t * t * (3 - 2 * t);
  }
}
