import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Simple beer glass: amber liquid, foam on top. [fill] animates between
/// 0 (empty) and 1 (full). Also used, full, as the provisional app mark.
class BeerGlass extends StatelessWidget {
  const BeerGlass({super.key, this.size = 96, this.fill = 0.8});

  final double size;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: fill.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => CustomPaint(
        size: Size(size * 0.78, size),
        painter: _GlassPainter(value),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  _GlassPainter(this.fill);

  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topInset = w * 0.02;
    final bottomInset = w * 0.16;

    // Glass body (slightly tapered), leaving room on the right for a handle.
    final bodyRight = w * 0.82;
    final body = Path()
      ..moveTo(topInset, h * 0.08)
      ..lineTo(bodyRight - topInset, h * 0.08)
      ..lineTo(bodyRight - bottomInset, h * 0.96)
      ..quadraticBezierTo(
          bodyRight - bottomInset, h, bodyRight - bottomInset - 6, h)
      ..lineTo(bottomInset + 6, h)
      ..quadraticBezierTo(bottomInset, h, bottomInset, h * 0.96)
      ..close();

    // Handle.
    final handle = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;
    canvas.drawArc(
      Rect.fromLTWH(bodyRight - w * 0.14, h * 0.22, w * 0.3, h * 0.46),
      -1.4,
      2.8,
      false,
      handle,
    );

    canvas.drawPath(
      body,
      Paint()..color = AppColors.surfaceHigh,
    );

    canvas.save();
    canvas.clipPath(body);

    final liquidTop = h * 0.08 + (h * 0.88) * (1 - fill);
    final liquid = Rect.fromLTRB(0, liquidTop, w, h);
    canvas.drawRect(
      liquid,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.amber, AppColors.amberDeep],
        ).createShader(liquid),
    );

    // Foam sits on top of the liquid.
    if (fill > 0.05) {
      final foam = Paint()..color = AppColors.foam;
      final foamY = liquidTop;
      final r = w * 0.13;
      for (var i = 0; i < 5; i++) {
        canvas.drawCircle(
          Offset(w * 0.1 + i * (bodyRight - w * 0.2) / 4, foamY),
          r,
          foam,
        );
      }
      canvas.drawRect(
        Rect.fromLTRB(0, foamY - r * 0.4, bodyRight, foamY + r * 0.7),
        foam,
      );
    }

    // Soft highlight.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.3, w * 0.06, h * 0.45),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.restore();

    canvas.drawPath(
      body,
      Paint()
        ..color = AppColors.textMuted.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_GlassPainter old) => old.fill != fill;
}
