import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../l10n/l10n.dart';
import '../../l10n/locale_controller.dart';

/// "Idioma": system, Portuguese (Brazil), English, Spanish. A device choice,
/// available without connection; applied at once, without restarting.
class LanguageSettingsSection extends StatelessWidget {
  const LanguageSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = getIt<LocaleController>();
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        String label(LanguageChoice c) => switch (c) {
              LanguageChoice.system => tr.languageSystem,
              LanguageChoice.pt => tr.languagePt,
              LanguageChoice.en => tr.languageEn,
              LanguageChoice.es => tr.languageEs,
            };
        return SurfaceCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.sm, vertical: AppSpace.xs),
          child: RadioGroup<LanguageChoice>(
            groupValue: controller.choice,
            onChanged: (c) {
              if (c != null) controller.setChoice(c);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in LanguageChoice.values)
                  RadioListTile<LanguageChoice>(
                    value: c,
                    activeColor: AppColors.amber,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: AppSpace.sm),
                    title: Text(label(c)),
                    subtitle: c == LanguageChoice.system
                        ? Text(tr.languageSystemHint)
                        : null,
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpace.md, 0, AppSpace.md, AppSpace.sm),
                  child: Text(tr.languageMoneyNote, style: AppText.caption),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
