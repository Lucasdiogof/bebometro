import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../l10n/l10n.dart';
import '../data/bafo_roster.dart';
import '../data/breath_input.dart';
import '../domain/breath_toy.dart';
import '../domain/party_meter.dart';

/// Bafômetro: a party toy inside the Resenha. The people are the ones of the
/// running outing (or of the last one); one blows, and a meter shows a
/// recreational level taken from that person's own records (see
/// [PartyMeter]). It measures nothing, shows no unit or number about the
/// body, says nothing about driving, never changes any record and saves
/// nothing. The microphone, when allowed, only gives the intensity of the
/// sound as a way to "blow"; the audio is not recorded or sent. Without it (or
/// by choice) a held button does the same.
class BafometroPage extends StatefulWidget {
  const BafometroPage({
    super.key,
    this.inputFactory = MicBreathInput.new,
    this.rosterLoader = loadBafoRoster,
  });

  /// Where the "blowing" level comes from (replaced in tests).
  final BreathInput Function() inputFactory;

  /// Who can blow (replaced in tests).
  final BafoRoster Function() rosterLoader;

  @override
  State<BafometroPage> createState() => _BafometroPageState();
}

enum _Mode { mic, manual }

class _BafometroPageState extends State<BafometroPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _toy = BreathToy();
  late final Ticker _ticker;
  late final AnimationController _reveal;
  late final BafoRoster _roster = widget.rosterLoader();

  BreathPhase _phase = BreathPhase.ready;
  _Mode _mode = _Mode.mic;
  BreathInput? _input;
  StreamSubscription<double>? _sub;
  double _level = 0;
  bool _held = false;
  Duration _last = Duration.zero;
  double _needle = 0;
  double _needleFrom = 0;
  String? _picked;
  String? _micMessage;
  bool _starting = false;

  /// The person who blows: the only one there is, or the one chosen.
  BafoPerson? get _person {
    final people = _roster.people;
    if (people.length == 1) return people.first;
    for (final p in people) {
      if (p.id == _picked) return p;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick);
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    if (_starting || _person == null) return;
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
    if (_person == null) return;
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
    setState(() {});
    if (_toy.full) unawaited(_finishBlowing());
  }

  Future<void> _finishBlowing() async {
    _ticker.stop();
    await _releaseMic();
    final person = _person;
    if (!mounted || person == null) return;
    final target = person.level;
    if (reduceMotion(context)) {
      setState(() {
        _needle = target;
        _phase = BreathPhase.result;
      });
      return;
    }
    _needleFrom = 0;
    setState(() => _phase = BreathPhase.revealing);
    await _reveal.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _needle = target;
      _phase = BreathPhase.result;
    });
  }

  void _onReveal() {
    final target = _person?.level ?? 0;
    final t = Curves.easeOutCubic.transform(_reveal.value);
    setState(() => _needle = _needleFrom + (target - _needleFrom) * t);
  }

  void _backToReady({bool choose = false}) {
    _ticker.stop();
    _reveal.stop();
    unawaited(_releaseMic());
    setState(() {
      _phase = BreathPhase.ready;
      _needle = 0;
      _held = false;
      if (choose) _picked = null;
    });
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr.bafoTitle)),
      body: _roster.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSpace.gutter),
              child: EmptyView(
                icon: Icons.groups_2_outlined,
                title: tr.bafoEmptyTitle,
                message: tr.bafoEmptyBody,
              ),
            )
          : Column(
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
                      if (_phase == BreathPhase.result ||
                          _phase == BreathPhase.revealing ||
                          _person != null)
                        _PersonHeader(
                          name: _person?.name ?? '',
                          showSimulation: _phase == BreathPhase.result,
                        ),
                      const SizedBox(height: AppSpace.md),
                      Semantics(
                        label: tr.bafoMeterSemantics(_person?.name ?? ''),
                        child: ExcludeSemantics(
                          child: AspectRatio(
                            aspectRatio: 2 / 1.25,
                            child: CustomPaint(
                              painter: _DialPainter(
                                needle: _needle,
                                shake:
                                    _phase == BreathPhase.blowing &&
                                    !reduceMotion(context),
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
          if (_roster.people.length > 1) ...[
            SectionTitle(tr.bafoWho),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final p in _roster.people)
                  ChoiceChip(
                    key: ValueKey('bafo-${p.id}'),
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    selected: _picked == p.id,
                    showCheckmark: false,
                    onSelected: (v) =>
                        setState(() => _picked = v ? p.id : null),
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
          if (_mode == _Mode.mic && _toy.quietSeconds > 4) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              tr.bafoHintLouder,
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
          ],
        ];
      case BreathPhase.revealing:
      case BreathPhase.result:
        return const [];
    }
  }

  Widget _actions() {
    switch (_phase) {
      case BreathPhase.ready:
        final blocked = _micMessage != null;
        final ready = _person != null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (blocked)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: ready ? _startManual : null,
                  child: Text(tr.bafoHoldButton),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _starting || !ready ? null : _startMic,
                  child: Text(tr.bafoStart),
                ),
              ),
            if (!blocked)
              TextButton(
                onPressed: _starting || !ready ? null : _startManual,
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
        final several = _roster.people.length > 1;
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('bafo-next'),
                onPressed: () => _backToReady(choose: several),
                child: Text(several ? tr.bafoAnother : tr.bafoAgain),
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
}

/// The name of the person, with "Simulação" small next to the result.
class _PersonHeader extends StatelessWidget {
  const _PersonHeader({required this.name, required this.showSimulation});

  final String name;
  final bool showSimulation;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            name,
            key: const ValueKey('bafo-name'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.headline,
          ),
        ),
        if (showSimulation) ...[
          const SizedBox(width: AppSpace.sm),
          Text(
            tr.bafoSimulation,
            key: const ValueKey('bafo-simulation'),
            style: AppText.caption.copyWith(color: AppColors.amber),
          ),
        ],
      ],
    );
  }
}

/// A plain dial: one neutral track, the level in amber and a needle. No
/// colour bands, ticks or labels, so nothing reads as a scale or a limit.
/// [shake] adds a small tremble while somebody blows.
class _DialPainter extends CustomPainter {
  _DialPainter({required this.needle, required this.shake});

  final double needle;
  final bool shake;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = min(size.width / 2 - 8, size.height * 0.86);
    final stroke = radius * 0.22;
    final arc = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = AppColors.surfaceHigh;
    canvas.drawArc(arc, pi, pi, false, track);
    final level = needle.clamp(0.0, 1.0);
    if (level > 0) {
      canvas.drawArc(
        arc,
        pi,
        pi * level,
        false,
        track..color = AppColors.amber,
      );
    }
    final jitter = shake ? sin(needle * 90) * 0.012 : 0.0;
    final angle = pi + (level + jitter) * pi;
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
    canvas.drawCircle(
      center,
      radius * 0.045,
      Paint()..color = AppColors.background,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.needle != needle || old.shake != shake;
}
