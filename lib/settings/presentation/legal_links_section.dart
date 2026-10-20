import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../l10n/l10n.dart';
import '../../places/presentation/open_in_maps.dart' show openLink;

/// Public pages of the app, kept in one place so a store review (and a test)
/// can see exactly where each link goes.
class LegalLinks {
  const LegalLinks._();

  static const base = 'https://lucksrei.com/projects/bebometro/';
  static const privacy = '${base}privacy/';
  static const terms = '${base}terms/';
  static const support = '${base}support/';
  static const dataDeletion = '${base}data-deletion/';
}

/// Privacy policy, terms, support and account deletion, opened in the browser.
class LegalLinksSection extends StatelessWidget {
  const LegalLinksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.privacy_tip_outlined, tr.settingsLegalPrivacy, LegalLinks.privacy),
      (Icons.description_outlined, tr.settingsLegalTerms, LegalLinks.terms),
      (
        Icons.support_agent_rounded,
        tr.settingsLegalSupport,
        LegalLinks.support,
      ),
      (
        Icons.delete_outline_rounded,
        tr.settingsLegalDeletion,
        LegalLinks.dataDeletion,
      ),
    ];
    return Column(
      children: [
        for (final r in rows) ...[
          SurfaceCard(
            onTap: () => openLink(r.$3),
            child: Row(
              children: [
                Icon(r.$1, color: AppColors.amber),
                const SizedBox(width: AppSpace.md),
                Expanded(child: Text(r.$2, style: AppText.subtitle)),
                const Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.sm),
        ],
      ],
    );
  }
}
