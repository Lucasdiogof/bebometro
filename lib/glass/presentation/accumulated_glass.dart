import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../domain/glass_math.dart';
import '../../l10n/l10n.dart';

/// Optional picture of the known volume registered so far: a glass with the
/// total on an explicit scale. It is not alcohol in the body, a capacity or a
/// goal, and there are no thresholds, colours or rewards by amount.
class AccumulatedGlass extends StatelessWidget {
  const AccumulatedGlass({
    super.key,
    required this.alcoholicMl,
    required this.otherMl,
    required this.unknownVolumeCount,
  });

  /// Known volume of drinks that contain alcohol.
  final int alcoholicMl;

  /// Known volume of water and non-alcoholic drinks.
  final int otherMl;

  /// Records without a known volume: not counted, and not counted as zero.
  final int unknownVolumeCount;

  @override
  Widget build(BuildContext context) {
    final total = alcoholicMl + otherMl;
    final scale = glassScaleMl(total);
    return Semantics(
      label: tr.glassSemantics(
        formatVolume(total),
        formatVolume(scale),
        unknownVolumeCount,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            height: 200,
            child: CustomPaint(
              painter: _GlassPainter(
                alcoholicMl: alcoholicMl,
                otherMl: otherMl,
                scaleMl: scale,
              ),
            ),
          ),
          const SizedBox(width: AppSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr.glassVolumeReported, style: AppText.caption),
                Text(formatVolume(total), style: AppText.headline),
                const SizedBox(height: AppSpace.xs),
                Text(
                  tr.glassScale(formatVolume(scale)),
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpace.md),
                _Legend(
                  color: AppColors.amber,
                  text: tr.glassAlcoholic(formatVolume(alcoholicMl)),
                ),
                const SizedBox(height: AppSpace.xs),
                _Legend(
                  color: const Color(0xFF6EC1E4),
                  text: tr.glassOther(formatVolume(otherMl)),
                ),
                if (unknownVolumeCount > 0) ...[
                  const SizedBox(height: AppSpace.md),
                  InfoPill(
                    tr.glassNoVolume('$unknownVolumeCount'),
                    icon: Icons.opacity_outlined,
                    warning: true,
                  ),
                ],
                const SizedBox(height: AppSpace.md),
                Text(tr.glassNote, style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: AppSpace.sm),
      Expanded(child: Text(text, style: AppText.caption)),
    ],
  );
}

class _GlassPainter extends CustomPainter {
  const _GlassPainter({
    required this.alcoholicMl,
    required this.otherMl,
    required this.scaleMl,
  });

  final int alcoholicMl;
  final int otherMl;
  final int scaleMl;

  @override
  void paint(Canvas canvas, Size size) {
    // Glass body leaves room on the left for the scale labels.
    final left = 40.0;
    final top = 8.0;
    final bottom = size.height - 6;
    final w = size.width - left - 4;
    final glass = Path()
      ..moveTo(left, top)
      ..lineTo(left + w, top)
      ..lineTo(left + w - 10, bottom - 4)
      ..quadraticBezierTo(left + w - 10, bottom, left + w - 16, bottom)
      ..lineTo(left + 16, bottom)
      ..quadraticBezierTo(left + 10, bottom, left + 10, bottom - 4)
      ..close();

    canvas.drawPath(
      glass,
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );

    final h = bottom - top;
    double yFor(int ml) => bottom - h * (ml / scaleMl).clamp(0.0, 1.0);

    canvas.save();
    canvas.clipPath(glass);
    final otherTop = yFor(otherMl);
    if (otherMl > 0) {
      canvas.drawRect(
        Rect.fromLTRB(left, otherTop, left + w, bottom),
        Paint()..color = const Color(0xFF6EC1E4).withValues(alpha: 0.85),
      );
    }
    if (alcoholicMl > 0) {
      canvas.drawRect(
        Rect.fromLTRB(left, yFor(otherMl + alcoholicMl), left + w, otherTop),
        Paint()..color = AppColors.amber.withValues(alpha: 0.92),
      );
    }
    canvas.restore();

    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.6),
    );

    // Explicit scale: quarters of the maximum.
    final tick = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final ml = scaleMl * i ~/ 4;
      final y = yFor(ml);
      canvas.drawLine(Offset(left - 6, y), Offset(left, y), tick);
      final tp = TextPainter(
        text: TextSpan(
          text: formatVolume(ml),
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(left - 8 - tp.width, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.alcoholicMl != alcoholicMl ||
      old.otherMl != otherMl ||
      old.scaleMl != scaleMl;
}
