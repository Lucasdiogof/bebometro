import 'dart:math';

/// Phases of the Bafômetro.
enum BreathPhase { ready, blowing, revealing, result }

/// Pure logic of the blow: a bar that fills while somebody "blows" (sound
/// level from the microphone, or a held button).
///
/// The sound is only an interaction: its strength or length decides nothing
/// about the level that is shown (see `PartyMeter`). About one second of
/// enough sound fills the bar, and a normal short blow is enough.
class BreathToy {
  BreathToy({this.threshold = 0.25, this.fillSeconds = 1.0});

  /// Interaction level (0..1) above which the bar fills. Low on purpose: a
  /// normal, short blow close to the phone has to be enough.
  final double threshold;

  /// Seconds of enough sound needed to fill the bar.
  final double fillSeconds;

  double _fill = 0;
  double _quiet = 0;

  /// 0..1, only drives the bar.
  double get fill => _fill;

  /// Seconds in a row below the threshold (for a "get closer" hint).
  double get quietSeconds => _quiet;

  bool get full => _fill >= 0.999;

  void reset() {
    _fill = 0;
    _quiet = 0;
  }

  /// [level] is 0..1 sound intensity; [dt] the seconds since the last call.
  /// Any sound above the threshold fills at the same speed; a pause drains
  /// the bar slowly so a breath taken in the middle does not start over.
  void update(double level, double dt) {
    if (level.clamp(0.0, 1.0) >= threshold) {
      _quiet = 0;
      _fill = min(1.0, _fill + dt / fillSeconds);
    } else {
      _quiet += dt;
      _fill = max(0.0, _fill - dt * 0.5);
    }
  }
}
