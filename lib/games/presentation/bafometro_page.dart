import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../outings/data/outing_repository.dart';
import '../../tab/data/tab_repository.dart';
import '../../l10n/l10n.dart';
import '../data/breath_input.dart';
import '../domain/breath_toy.dart';

/// "Bafômetro de brincadeira": a made-up party toy. It measures nothing, shows
/// no number about the body, never touches the registered consumption, and
/// saves nothing (no ranking, no history). The microphone, when allowed, only
/// gives the intensity of the sound as a way to "blow"; the audio is not
/// recorded or sent. Without it (or by choice) a held button does the same.
class BafometroPage extends StatefulWidget {
  const BafometroPage({super.key, this.inputFactory = MicBreathInput.new});

  /// Where the "blowing" level comes from (replaced in tests).
  final BreathInput Function() inputFactory;

  @override
  State<BafometroPage> createState() => _BafometroPageState();
}

enum _Mode { mic, manual }

class _BafometroPageState extends State<BafometroPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _toy = BreathToy();
  late final Ticker _ticker;
  late final AnimationController _reveal;

  BreathPhase _phase = BreathPhase.ready;
  _Mode _mode = _Mode.mic;
  BreathInput? _input;
  StreamSubscription<double>? _sub;
  double _level = 0;
  bool _held = false;
  Duration _last = Duration.zero;
  double _needle = 0;
  double _needleFrom = 0;
  int? _result;
  int? _previous;
  String? _who;
  String? _micMessage;
  bool _starting = false;

  /// Names at the running outing's table, offered by choice (never saved).
  late final List<String> _people = _loadPeople();

  static List<String> _loadPeople() {
    try {
      final outing = getIt<OutingRepository>().active;
      if (outing == null) return const [];
      final doc = getIt<TabRepository>().load(outing.id);
      return [for (final p in doc.present) p.displayName];
    } catch (_) {
      return const [];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick);
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(_onReveal);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _reveal.dispose();
    unawaited(_releaseMic());
    super.dispose();
  }

  /// The microphone is released as soon as the app leaves the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    unawaited(_releaseMic());
    if (_phase == BreathPhase.blowing) _backToReady();
  }

  Future<void> _releaseMic() async {
    final sub = _sub;
    final input = _input;
    _sub = null;
    _input = null;
    _level = 0;
    // Cancelling the listener needs no waiting; the microphone itself is
    // released (and awaited) by stop().
    unawaited(sub?.cancel());
    await input?.stop();
  }

  // ----------------------------------------------------------------- actions

  /// The permission is asked only now, after the tap on "Começar".
  Future<void> _startMic() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _micMessage = null;
    });
    final input = widget.inputFactory();
    _input = input;
    final started = await input.start();
    if (!mounted) {
      await input.stop();
      return;
    }
    if (started != BreathStart.started) {
      await _releaseMic();
      setState(() {
        _starting = false;
        _micMessage = started == BreathStart.denied
            ? tr.bafoDenied
            : tr.bafoUnsupported;
      });
      return;
    }
    _sub = input.levels.listen((l) => _level = l);
    setState(() {
      _starting = false;
      _mode = _Mode.mic;
    });
    _beginBlowing();
  }

  void _startManual() {
    setState(() {
      _mode = _Mode.manual;
      _micMessage = null;
    });
    _beginBlowing();
  }

  void _beginBlowing() {
    _toy.reset();
    _held = false;
    _level = 0;
    _last = Duration.zero;
    _needle = 0;
    setState(() => _phase = BreathPhase.blowing);
    _ticker.stop();
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    final level = _mode == _Mode.manual ? (_held ? 1.0 : 0.0) : _level;
    _toy.update(level, dt);
    setState(() => _needle = _toy.fill);
    if (_toy.full) unawaited(_finishBlowing());
  }

  Future<void> _finishBlowing() async {
    _ticker.stop();
    await _releaseMic();
    if (!mounted) return;
    final index = _toy.pickResult(previous: _previous);
    _previous = index;
    _result = index;
    final target = BreathToy.needleFor(index);
    if (reduceMotion(context)) {
      setState(() {
        _needle = target;
        _phase = BreathPhase.result;
      });
      return;
    }
    _needleFrom = _needle;
    setState(() => _phase = BreathPhase.revealing);
    await _reveal.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _needle = target;
      _phase = BreathPhase.result;
    });
  }

  void _onReveal() {
    final target = BreathToy.needleFor(_result ?? 0);
    final t = Curves.elasticOut.transform(_reveal.value);
    setState(() => _needle = _needleFrom + (target - _needleFrom) * t);
  }

  void _backToReady() {
    _ticker.stop();
    _reveal.stop();
    unawaited(_releaseMic());
    setState(() {
      _phase = BreathPhase.ready;
      _needle = 0;
      _held = false;
    });
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr.bafoTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter,
                0,
                AppSpace.gutter,
                AppSpace.xl,
              ),
              children: [
                SurfaceCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.theater_comedy_outlined,
                        color: AppColors.amber,
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Text(tr.bafoDisclaimer, style: AppText.caption),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                Semantics(
                  label: tr.bafoDialSemantics,
                  child: ExcludeSemantics(
                    child: AspectRatio(
                      aspectRatio: 2 / 1.25,
                      child: CustomPaint(
                        painter: _DialPainter(
                          needle: _needle,
                          shake: _phase == BreathPhase.blowing &&
                              !reduceMotion(context),
                          segments: BreathToy.resultCount,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                ..._body(),
              ],
            ),
          ),
          BottomActionBar(child: _actions()),
        ],
      ),
    );
  }

  List<Widget> _body() {
    switch (_phase) {
      case BreathPhase.ready:
        return [
          if (_people.isNotEmpty) ...[
            SectionTitle(tr.bafoWho),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final n in _people)
                  ChoiceChip(
                    label: Text(n),
                    selected: _who == n,
                    showCheckmark: false,
                    onSelected: (v) => setState(() => _who = v ? n : null),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
          ],
          if (_micMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: Text(
                _micMessage!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          Text(tr.bafoMicNote, style: AppText.caption),
        ];
      case BreathPhase.blowing:
        return [
          Text(
            _mode == _Mode.mic ? tr.bafoBlowPrompt : tr.bafoHoldPrompt,
            textAlign: TextAlign.center,
            style: AppText.title,
          ),
          const SizedBox(height: AppSpace.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: LinearProgressIndicator(
              value: _toy.fill,
              minHeight: 14,
              color: AppColors.amber,
              backgroundColor: AppColors.surfaceHigh,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          if (_mode == _Mode.manual)
            Text(
              tr.bafoHoldNote,
              textAlign: TextAlign.center,
              style: AppText.caption,
            )
          else if (_toy.quietSeconds > 5)
            Text(
              tr.bafoHintLouder,
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
        ];
      case BreathPhase.revealing:
        return [
          Text(
            tr.bafoReveal,
            textAlign: TextAlign.center,
            style: AppText.title,
          ),
        ];
      case BreathPhase.result:
        final i = (_result ?? 0) + 1;
        return [
          Semantics(
            liveRegion: true,
            child: SurfaceCard(
              highlight: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _who == null
                        ? tr.bafoResultAnon
                        : tr.bafoResultFor(_who!),
                    style: AppText.caption.copyWith(color: AppColors.amber),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(_resultTitle(i), style: AppText.headline),
                  const SizedBox(height: AppSpace.xs),
                  Text(_resultLine(i), style: AppText.body),
                  const SizedBox(height: AppSpace.md),
                  Text(tr.bafoFictional, style: AppText.caption),
                ],
              ),
            ),
          ),
        ];
    }
  }

  Widget _actions() {
    switch (_phase) {
      case BreathPhase.ready:
        final blocked = _micMessage != null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (blocked)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _startManual,
                  child: Text(tr.bafoHoldButton),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _starting ? null : _startMic,
                  child: Text(tr.bafoStart),
                ),
              ),
            if (!blocked)
              TextButton(
                onPressed: _starting ? null : _startManual,
                child: Text(tr.bafoHoldOption),
              ),
          ],
        );
      case BreathPhase.blowing:
        if (_mode == _Mode.manual) {
          return Listener(
            onPointerDown: (_) => _held = true,
            onPointerUp: (_) => _held = false,
            onPointerCancel: (_) => _held = false,
            child: Semantics(
              button: true,
              label: tr.bafoHoldButton,
              child: Container(
                height: 64,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _held ? AppColors.amberDeep : AppColors.amber,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  tr.bafoHoldButton,
                  style: const TextStyle(
                    color: Color(0xFF241800),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          );
        }
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _backToReady,
            child: Text(tr.bafoStop),
          ),
        );
      case BreathPhase.revealing:
        return const SizedBox(height: 48);
      case BreathPhase.result:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _backToReady,
                child: Text(tr.bafoAgain),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(tr.bafoDone),
              ),
            ),
          ],
        );
    }
  }

  String _resultTitle(int i) => switch (i) {
    1 => tr.bafoR1T,
    2 => tr.bafoR2T,
    3 => tr.bafoR3T,
    4 => tr.bafoR4T,
    5 => tr.bafoR5T,
    6 => tr.bafoR6T,
    7 => tr.bafoR7T,
    _ => tr.bafoR8T,
  };

  String _resultLine(int i) => switch (i) {
    1 => tr.bafoR1L,
    2 => tr.bafoR2L,
    3 => tr.bafoR3L,
    4 => tr.bafoR4L,
    5 => tr.bafoR5L,
    6 => tr.bafoR6L,
    7 => tr.bafoR7L,
    _ => tr.bafoR8L,
  };
}

/// A dial with unlabelled colour segments (nothing to read as a measurement)
/// and a needle. [shake] adds a small tremble while somebody blows.
class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.needle,
    required this.shake,
    required this.segments,
  });

  final double needle;
  final bool shake;
  final int segments;

  static const _colors = [
    Color(0xFF8BC98F),
    Color(0xFFA7CF7E),
    Color(0xFFC6D26E),
    Color(0xFFE6CB5C),
    Color(0xFFF2A81D),
    Color(0xFFEB8A2B),
    Color(0xFFE56E3F),
    Color(0xFFE5604D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = min(size.width / 2 - 8, size.height * 0.86);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final stroke = radius * 0.22;
    final sweep = pi / segments;
    for (var i = 0; i < segments; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = _colors[i % _colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - stroke / 2),
        pi + i * sweep + 0.012,
        sweep - 0.024,
        false,
        paint,
      );
    }
    // Outer rim and a few unlabelled ticks.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.outline;
    canvas.drawArc(rect, pi, pi, false, rim);
    final jitter = shake ? sin(needle * 90) * 0.012 : 0.0;
    final angle = pi + (needle.clamp(0.0, 1.0) + jitter) * pi;
    final tip = Offset(
      center.dx + cos(angle) * (radius - stroke * 0.35),
      center.dy + sin(angle) * (radius - stroke * 0.35),
    );
    final needlePaint = Paint()
      ..color = AppColors.foam
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, needlePaint);
    canvas.drawCircle(center, radius * 0.09, Paint()..color = AppColors.foam);
    canvas.drawCircle(center, radius * 0.045, Paint()..color = AppColors.background);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.needle != needle || old.shake != shake;
}
