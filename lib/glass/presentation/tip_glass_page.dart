import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/data/device_store.dart';
import '../../core/di/injector.dart';
import '../../core/widgets/common.dart';
import '../data/tilt_source.dart';
import '../domain/beer_sim.dart';
import 'beer_painter.dart';

/// "Virar o copo": the whole screen is a glass of beer. It is a visual toy
/// with its own fill level: it does not read, write or change any drink
/// record, statistic or goal, and filling it up is not a target.
///
/// Input is the accelerometer on Android/iOS. On the web, on devices without
/// the sensor, when motion is switched off, or with reduce-motion on, dragging
/// tilts the same simulation instead.
class TipGlassPage extends StatefulWidget {
  const TipGlassPage({super.key});

  @override
  State<TipGlassPage> createState() => _TipGlassPageState();
}

class _TipGlassPageState extends State<TipGlassPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _hintKey = 'glass.motion_hint_seen';

  final _sim = BeerSim();
  final _tilt = TiltSource();
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  /// Overlay state that changes rarely; the painter never rebuilds the tree.
  final _empty = ValueNotifier<bool>(false);
  final _hint = ValueNotifier<String?>(null);
  Timer? _hintTimer;
  Timer? _sensorWatch;

  /// User switch: react to the phone's movement.
  bool _motion = !kIsWeb;
  bool _sensorFailed = kIsWeb;
  double _manualAngle = 0;
  bool _dragged = false;
  bool _started = false;
  bool _visible = true; // route not covered by another one
  bool _foreground = true; // app not in the background

  bool get _usingSensor => _motion && !_sensorFailed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    _tilt.onUnavailable = () {
      if (!mounted) return;
      setState(() => _sensorFailed = true);
      _syncRunning();
      _showHint('Sem sensor de movimento. Arraste para inclinar.');
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = reduceMotion(context);
    _sim.calm = reduce;
    if (!_started) {
      _started = true;
      // Reduce motion: start in the static, drag-driven mode.
      if (reduce) _motion = false;
      _initialHint();
    }
    // Hidden behind another route: stop both the ticker and the sensor.
    _visible = TickerMode.valuesOf(context).enabled;
    _syncRunning();
  }

  void _initialHint() {
    if (_usingSensor) {
      var seen = false;
      try {
        seen = getIt<DeviceStore>().getString(_hintKey) == '1';
      } catch (_) {}
      if (!seen) {
        _showHint('Incline o celular para mexer a cerveja.');
        try {
          getIt<DeviceStore>().setString(_hintKey, '1');
        } catch (_) {}
      }
    } else {
      _showHint('Arraste para inclinar.', long: true);
    }
  }

  void _showHint(String text, {bool long = false}) {
    _hint.value = text;
    _hintTimer?.cancel();
    _hintTimer = Timer(Duration(seconds: long ? 8 : 5), () {
      _hint.value = null;
    });
  }

  /// Starts or stops ticker and sensor according to visibility and settings.
  void _syncRunning() {
    if (_visible && _foreground) {
      if (!_ticker.isActive) {
        _last = Duration.zero; // first frame after a pause is not a long step
        _ticker.start();
      }
      if (_usingSensor) {
        if (!_tilt.running) {
          _tilt.start();
          _watchSensor();
        }
      } else {
        _tilt.stop();
      }
    } else {
      if (_ticker.isActive) _ticker.stop();
      _tilt.stop();
      _sensorWatch?.cancel();
    }
  }

  /// A device without the sensor may open the stream and never deliver.
  void _watchSensor() {
    _sensorWatch?.cancel();
    _sensorWatch = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _usingSensor && !_tilt.hasData) {
        setState(() => _sensorFailed = true);
        _syncRunning();
        _showHint('Sem leitura de movimento. Arraste para inclinar.');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncRunning();
  }

  void _onTick(Duration elapsed) {
    // Real time between frames; BeerSim clamps a long gap (resume).
    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _sim.step(dt, _usingSensor ? _tilt.angle : _manualAngle);
    final empty = _sim.isEmpty;
    if (empty != _empty.value) _empty.value = empty;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _tilt.dispose();
    _hintTimer?.cancel();
    _sensorWatch?.cancel();
    _sim.dispose();
    _empty.dispose();
    _hint.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  // ---- Actions -------------------------------------------------------------

  void _refill() {
    _sim.refill();
    _empty.value = false;
  }

  void _level() {
    _manualAngle = 0;
    _sim.settle();
  }

  void _onPan(DragUpdateDetails d, Size size) {
    if (_usingSensor) return;
    // Rotates the glass around the screen centre, like turning a dial.
    final p = d.localPosition - Offset(size.width / 2, size.height / 2);
    final r2 = math.max(p.distanceSquared, 80.0 * 80.0);
    final cross = p.dx * d.delta.dy - p.dy * d.delta.dx;
    _manualAngle = (_manualAngle + cross / r2 + math.pi) % (2 * math.pi) -
        math.pi;
    if (!_dragged) {
      _dragged = true;
      _hint.value = null;
    }
  }

  void _setMotion(bool on) {
    setState(() {
      _motion = on;
      if (on && !kIsWeb) _sensorFailed = false;
      // Hold the current tilt as the manual one: no jump when switching.
      if (!on) _manualAngle = _sim.angle;
    });
    _syncRunning();
    if (!_usingSensor && !_dragged) _showHint('Arraste para inclinar.', long: true);
  }

  Future<void> _options() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1408),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Reagir ao movimento'),
                  subtitle: Text(kIsWeb
                      ? 'Não disponível no navegador: arraste para inclinar.'
                      : 'Desligado, você arrasta o dedo para inclinar.'),
                  value: _usingSensor,
                  onChanged: kIsWeb
                      ? null
                      : (v) {
                          _setMotion(v);
                          setSheet(() {});
                        },
                ),
                SwitchListTile(
                  title: const Text('Bolhas e ondas'),
                  subtitle: const Text('Desligue para uma cerveja mais calma.'),
                  value: _sim.effects,
                  onChanged: (v) {
                    _sim.effects = v;
                    setSheet(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.straighten_rounded),
                  title: const Text('Nivelar'),
                  onTap: () {
                    _level();
                    Navigator.pop(ctx);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(
                    'Só visual: o copo não mede nem registra consumo, e encher '
                    'não é meta.',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF241608),
        body: LayoutBuilder(
          builder: (context, box) {
            final size = box.biggest;
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) => _onPan(d, size),
                  child: Semantics(
                    label: 'Cerveja que ocupa a tela. Incline o celular para '
                        'mexer o líquido. Só visual, não registra consumo.',
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: BeerPainter(_sim),
                        size: size,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(children: [
                        _RoundButton(
                          icon: Icons.close_rounded,
                          tooltip: 'Fechar',
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        _RoundButton(
                          icon: Icons.refresh_rounded,
                          tooltip: 'Reencher',
                          onPressed: _refill,
                        ),
                        const SizedBox(width: 8),
                        _RoundButton(
                          icon: Icons.tune_rounded,
                          tooltip: 'Opções',
                          onPressed: _options,
                        ),
                      ]),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _empty,
                        builder: (context, empty, _) => empty
                            ? FilledButton.icon(
                                onPressed: _refill,
                                icon: const Icon(Icons.local_drink_rounded),
                                label: const Text('Encher novamente'),
                              )
                            : ValueListenableBuilder<String?>(
                                valueListenable: _hint,
                                builder: (context, text, _) => AnimatedOpacity(
                                  opacity: text == null ? 0 : 1,
                                  duration: const Duration(milliseconds: 300),
                                  child: IgnorePointer(
                                    child: _Pill(text ?? ''),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x66000000),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }
}
