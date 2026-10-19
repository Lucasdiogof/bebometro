import 'dart:math';

/// Phases of the "bafômetro de brincadeira".
enum BreathPhase { ready, blowing, revealing, result }

/// Pure logic of the toy: a bar that fills while somebody "blows" (sound level
/// from the microphone, or a held button) and a RANDOM, fictional result.
///
/// Nothing here measures anything. No unit, percentage or number about the
/// body is ever produced, the result does not depend on drinks or on any
/// record, and nothing is stored.
class BreathToy {
  BreathToy({Random? random, this.threshold = 0.5, this.fillSeconds = 2.5})
    : _rng = random ?? Random();

  final Random _rng;

  /// Interaction level (0..1) above which the bar fills.
  final double threshold;

  /// Seconds of steady blowing needed to fill the bar.
  final double fillSeconds;

  /// How many fictional results exist (texts live in the ARB files).
  static const resultCount = 8;

  double _fill = 0;
  double _quiet = 0;

  /// 0..1, only drives the bar and the needle.
  double get fill => _fill;

  /// Seconds in a row below the threshold (for a "get closer" hint).
  double get quietSeconds => _quiet;

  bool get full => _fill >= 1;

  void reset() {
    _fill = 0;
    _quiet = 0;
  }

  /// [level] is 0..1 interaction intensity; [dt] the seconds since the last
  /// call. Louder blowing fills faster; silence slowly drains the bar.
  void update(double level, double dt) {
    final l = level.clamp(0.0, 1.0);
    if (l >= threshold) {
      _quiet = 0;
      _fill = min(1.0, _fill + dt / fillSeconds * (0.5 + 0.5 * l));
    } else {
      _quiet += dt;
      _fill = max(0.0, _fill - dt * 0.2);
    }
  }

  /// Index of the fictional result, never the same twice in a row.
  int pickResult({int? previous}) {
    if (resultCount < 2 || previous == null) return _rng.nextInt(resultCount);
    final i = _rng.nextInt(resultCount - 1);
    return i >= previous ? i + 1 : i;
  }

  /// Where the needle lands for result [index]: the middle of its dial
  /// segment, as a fraction of the dial (0 = far left, 1 = far right).
  static double needleFor(int index) => (index + 0.5) / resultCount;
}
