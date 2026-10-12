import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../outings/domain/outing.dart';

sealed class FeedbackResult {
  const FeedbackResult();
}

class FeedbackAnswered extends FeedbackResult {
  const FeedbackAnswered(this.mood);

  final FeedbackMood mood;
}

class FeedbackSnoozed extends FeedbackResult {
  const FeedbackSnoozed();
}

class FeedbackDismissed extends FeedbackResult {
  const FeedbackDismissed();
}

/// "Como foi o último rolê?" It is a personal account, not a measurement.
class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({super.key, required this.outing});

  final Outing outing;

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  FeedbackMood? _selected;

  @override
  Widget build(BuildContext context) {
    final outing = widget.outing;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Como foi o último rolê?', style: AppText.title),
            const SizedBox(height: AppSpace.sm),
            SurfaceCard(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Row(children: [
                Icon(outing.type.icon, color: AppColors.amber, size: 20),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(outing.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.subtitle),
                      Text(
                        '${formatDate(outing.startedAt)} · '
                        '${formatDuration(outing.durationAt(DateTime.now()))}',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: AppSpace.lg),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpace.md,
              crossAxisSpacing: AppSpace.md,
              childAspectRatio: 2.3,
              children: [
                for (final mood in FeedbackMood.values)
                  _MoodTile(
                    mood: mood,
                    selected: _selected == mood,
                    onTap: () => setState(() => _selected = mood),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            const Text(
              'É só o seu relato de como foi a noite. Não mede nada e não '
              'indica quanto é seguro beber.',
              style: AppText.caption,
            ),
            const SizedBox(height: AppSpace.lg),
            FilledButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, FeedbackAnswered(_selected!)),
              child: const Text('Salvar relato'),
            ),
            const SizedBox(height: AppSpace.xs),
            Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const FeedbackSnoozed()),
                  child: const Text('Depois'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const FeedbackDismissed()),
                  child: const Text('Não perguntar',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final FeedbackMood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: mood.label,
      child: SurfaceCard(
        selected: selected,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(mood.icon,
                color: selected ? AppColors.amber : AppColors.textMuted),
            const SizedBox(width: AppSpace.sm),
            Flexible(
              child: Text(
                mood.label,
                overflow: TextOverflow.ellipsis,
                style: AppText.subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
