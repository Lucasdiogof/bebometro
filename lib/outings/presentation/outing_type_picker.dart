import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../domain/outing.dart';

/// Visual picker for the kind of outing/place: icon and name, three per row.
class OutingTypePicker extends StatelessWidget {
  const OutingTypePicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OutingType selected;
  final ValueChanged<OutingType> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const gap = AppSpace.sm;
      final width = (constraints.maxWidth - gap * 2) / 3;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final t in OutingType.values)
            SizedBox(
              width: width,
              child: Semantics(
                button: true,
                selected: selected == t,
                label: t.label,
                child: SurfaceCard(
                  selected: selected == t,
                  onTap: () => onSelected(t),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpace.md, horizontal: AppSpace.xs),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.icon,
                        size: 26,
                        color: selected == t
                            ? AppColors.amber
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        t.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected == t
                              ? AppColors.text
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
