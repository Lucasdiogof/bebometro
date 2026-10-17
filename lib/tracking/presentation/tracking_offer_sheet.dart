import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../application/tracking_coordinator.dart';
import '../../l10n/l10n.dart';

/// The one-time explanation offered during the first outing. Whatever the
/// answer, it is not shown again; "Agora não" leaves the switch in Settings.
Future<void> offerTrackingIfNeeded(BuildContext context) async {
  final coordinator = getIt<TrackingCoordinator>();
  if (!await coordinator.shouldOffer()) return;
  if (!context.mounted) return;
  // Marked first: dismissing the sheet by any means counts as "not now".
  await coordinator.prefs.markOfferHandled();
  if (!context.mounted) return;
  final yes = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.xl,
          0,
          AppSpace.xl,
          AppSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.settingsLockScreen, style: AppText.title),
            const SizedBox(height: AppSpace.sm),
            Text(tr.trackingOfferBody, style: AppText.body),
            const SizedBox(height: AppSpace.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr.trackingOfferActivate),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr.commonNotNow),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (yes != true) return;
  final status = await coordinator.enable();
  if (context.mounted && status == TrackingStatus.permissionDenied) {
    showToast(context, tr.trackingNoPermissionToast);
  }
}
