import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../domain/glass_math.dart';

/// "Virar o copo": a purely visual toy. Drag (or use the slider) to tilt the
/// glass and the liquid pours out; "Encher de novo" refills it. It does not
/// touch any record, does not ask anyone to drink, and has no goal.
///
/// Tilting by the phone's sensors is not implemented (it would need a sensors
/// package that is not a dependency); dragging and the slider work on every
/// platform.
class TipGlassPage extends StatefulWidget {
  const TipGlassPage({super.key});

  @override
  State<TipGlassPage> createState() => _TipGlassPageState();
}

class _TipState {
  const _TipState(this.fill, this.theta, this.spilled, this.pouring, this.t);

  final double fill;
  final double theta;

  /// Total poured so far (0..1 of a glass), only for the puddle drawing.
  final double spilled;
  final bool pouring;

  /// Seconds, to animate the drops.
  final double t;
}

class _TipGlassPageState extends State<TipGlassPage>
    with SingleTickerProviderStateMixin {
  static const double _w = 110;
  static const double _h = 170;
  static const double _maxTheta = 1.75;

  final _model = ValueNotifier(const _TipState(0.85, 0, 0, false, 0));
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _model.dispose();
    super.dispose();
  }

  _TipState get _s => _model.value;

  void _setTheta(double theta) {
    final t = theta.clamp(-_maxTheta, _maxTheta).toDouble();
    _model.value = _TipState(_s.fill, t, _s.spilled, _s.pouring, _s.t);
    _settle();
  }

  /// Starts pouring when the liquid is above what the tilted glass can hold.
  void _settle() {
    final limit = maxFillAtTilt(_s.theta, _w, _h);
    if (_s.fill > limit + 0.002) {
      if (reduceMotion(context)) {
        // No animation: show the settled result immediately.
        _model.value = _TipState(
            limit, _s.theta, _s.spilled + (_s.fill - limit), false, _s.t);
      } else if (!_ticker.isActive) {
        _last = Duration.zero;
        _ticker.start();
      }
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final limit = maxFillAtTilt(_s.theta, _w, _h);
    if (_s.fill <= limit + 0.002) {
      _model.value =
          _TipState(_s.fill, _s.theta, _s.spilled, false, elapsed.inMilliseconds / 1000);
      _ticker.stop();
      return;
    }
    final drop = math.min(_s.fill - limit, dt * 0.35);
    _model.value = _TipState(_s.fill - drop, _s.theta, _s.spilled + drop, true,
        elapsed.inMilliseconds / 1000);
  }

  void _refill() {
    _ticker.stop();
    _model.value = _TipState(0.85, 0, 0, false, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virar o copo')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) => _setTheta(_s.theta + d.delta.dx * 0.012),
                child: Semantics(
                  label: 'Copo para virar. Arraste para os lados ou use o '
                      'controle de inclinação.',
                  child: RepaintBoundary(
                    child: SizedBox.expand(
                      child: CustomPaint(
                        painter: _TipPainter(_model, _w, _h),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
              child: Column(children: [
                ValueListenableBuilder<_TipState>(
                  valueListenable: _model,
                  builder: (context, s, _) => Slider(
                    min: -_maxTheta,
                    max: _maxTheta,
                    value: s.theta,
                    label: 'Inclinação',
                    onChanged: _setTheta,
                  ),
                ),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _setTheta(0),
                      icon: const Icon(Icons.vertical_align_bottom_rounded),
                      label: const Text('Endireitar'),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _refill,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Encher de novo'),
                    ),
                  ),
                ]),
                const SizedBox(height: AppSpace.md),
                const Text(
                  'Brincadeira visual. Não registra nada, não tem relação com '
                  'os seus registros e não é um desafio para beber.',
                  textAlign: TextAlign.center,
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpace.md),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipPainter extends CustomPainter {
  _TipPainter(this.model, this.w, this.h) : super(repaint: model);

  final ValueListenable<_TipState> model;
  final double w;
  final double h;

  @override
  void paint(Canvas canvas, Size size) {
    final s = model.value;
    final ground = size.height - 20;
    final center = Offset(size.width / 2, ground - h / 2 - 8);

    // Table line and the puddle.
    canvas.drawLine(
      Offset(16, ground),
      Offset(size.width - 16, ground),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 2,
    );
    if (s.spilled > 0.01) {
      final width = 18 + 150 * s.spilled.clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + math.sin(s.theta) * 60, ground),
          width: width,
          height: 8,
        ),
        Paint()..color = AppColors.amber.withValues(alpha: 0.55),
      );
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(s.theta);
    canvas.translate(-w / 2, -h / 2);

    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h), const Radius.circular(10));
    canvas.drawRRect(body, Paint()..color = Colors.white.withValues(alpha: 0.08));

    final poly = liquidPolygon(s.fill, s.theta, w, h);
    if (poly.length >= 3) {
      canvas.save();
      canvas.clipRRect(body);
      final path = Path()..addPolygon(poly, true);
      canvas.drawPath(path, Paint()..color = AppColors.amber.withValues(alpha: 0.92));
      canvas.restore();
    }
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.65),
    );
    canvas.restore();

    // The stream leaves from the lower rim corner while pouring.
    if (s.pouring) {
      final cos = math.cos(s.theta);
      final sin = math.sin(s.theta);
      Offset world(Offset local) {
        final d = local - Offset(w / 2, h / 2);
        return center + Offset(d.dx * cos - d.dy * sin, d.dx * sin + d.dy * cos);
      }

      final a = world(const Offset(0, 0));
      final b = world(Offset(w, 0));
      final rim = a.dy > b.dy ? a : b;
      final stream = Paint()
        ..color = AppColors.amber.withValues(alpha: 0.85)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(rim, Offset(rim.dx, ground), stream);
      final drop = Paint()..color = AppColors.amber.withValues(alpha: 0.7);
      for (var i = 0; i < 3; i++) {
        final phase = ((s.t * 1.6) + i / 3) % 1.0;
        canvas.drawCircle(
          Offset(rim.dx + (i - 1) * 4, rim.dy + (ground - rim.dy) * phase),
          2.2,
          drop,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TipPainter old) => old.model != model;
}
