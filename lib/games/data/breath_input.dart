import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:record/record.dart';

/// How a microphone start ended.
enum BreathStart { started, denied, unsupported }

/// Source of the "blowing" level (0..1) for the toy.
abstract class BreathInput {
  /// Asks for the microphone (the first call shows the system prompt) and
  /// starts listening. Never records to a file and never sends anything.
  Future<BreathStart> start();

  /// Intensity of the sound, 0..1. Only meaningful after [start].
  Stream<double> get levels;

  /// Releases the microphone. Safe to call more than once.
  Future<void> stop();
}

/// Sound intensity from the microphone, processed here and thrown away: the PCM
/// chunks are reduced to one number each and dropped (no file, no upload, no
/// speech or alcohol analysis).
class MicBreathInput implements BreathInput {
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _sub;
  final _controller = StreamController<double>.broadcast();

  @override
  Stream<double> get levels => _controller.stream;

  @override
  Future<BreathStart> start() async {
    final recorder = AudioRecorder();
    _recorder = recorder;
    try {
      if (!await recorder.hasPermission()) {
        await stop();
        return BreathStart.denied;
      }
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
        ),
      );
      _sub = stream.listen(
        (chunk) => _controller.add(levelOf(chunk)),
        onError: (_) {},
      );
      return BreathStart.started;
    } catch (_) {
      await stop();
      return BreathStart.unsupported;
    }
  }

  @override
  Future<void> stop() async {
    final sub = _sub;
    final recorder = _recorder;
    _sub = null;
    _recorder = null;
    await sub?.cancel();
    if (recorder != null) {
      try {
        await recorder.cancel();
      } catch (_) {}
      try {
        await recorder.dispose();
      } catch (_) {}
    }
  }

  /// Level 0..1 of a 16-bit little-endian mono PCM chunk: RMS in dB, with
  /// -50 dBFS (near silence) as 0 and 0 dBFS as 1.
  static double levelOf(Uint8List bytes) {
    final n = bytes.length ~/ 2;
    if (n == 0) return 0;
    final data = ByteData.sublistView(bytes);
    var sum = 0.0;
    for (var i = 0; i < n; i++) {
      final v = data.getInt16(i * 2, Endian.little) / 32768.0;
      sum += v * v;
    }
    final rms = sqrt(sum / n);
    if (rms <= 0) return 0;
    final db = 20 * log(rms) / ln10;
    return ((db + 50) / 50).clamp(0.0, 1.0);
  }
}
