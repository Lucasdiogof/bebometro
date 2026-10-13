import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../application/tracking_coordinator.dart';
import '../../l10n/l10n.dart';

/// "Rolê na tela bloqueada" in the settings. The status line comes from the
/// coordinator, which confirms with the native side; "Ativo" is never claimed
/// just because a switch is on.
class TrackingSettingsSection extends StatefulWidget {
  const TrackingSettingsSection({super.key});

  @override
  State<TrackingSettingsSection> createState() =>
      _TrackingSettingsSectionState();
}

class _TrackingSettingsSectionState extends State<TrackingSettingsSection> {
  final _coordinator = getIt<TrackingCoordinator>();
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _coordinator.prefs.changes.listen((_) {
      if (mounted) setState(() {});
    });
    // Refresh what the system says (permission or Live Activities may have
    // been changed in the system settings).
    _coordinator.schedule(immediate: true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _statusText(TrackingStatus s) {
    switch (s) {
      case TrackingStatus.unsupported:
        if (!_coordinator.platform.isNativePlatform) {
          return tr.trackingWeb;
        }
        return _coordinator.platform.isIos
            ? tr.trackingIosOld
            : tr.trackingUnsupported;
      case TrackingStatus.disabled:
        return tr.trackingDisabled;
      case TrackingStatus.permissionDenied:
        return tr.trackingPermission;
      case TrackingStatus.systemOff:
        return _coordinator.platform.isIos
            ? tr.trackingSystemOffIos
            : tr.trackingSystemOffAndroid;
      case TrackingStatus.noOuting:
        return tr.trackingNoOuting;
      case TrackingStatus.hidden:
        return tr.trackingHidden(tr.outingShowOnLock);
      case TrackingStatus.dismissed:
        return tr.trackingDismissed(tr.outingShowOnLock);
      case TrackingStatus.active:
        return tr.trackingActive;
      case TrackingStatus.pending:
        return tr.trackingPending;
    }
  }

  Future<void> _toggle(bool on) async {
    if (on) {
      final result = await _coordinator.enable();
      if (!mounted) return;
      if (result == TrackingStatus.permissionDenied) {
        showToast(context, tr.trackingNoPermissionToast);
      }
    } else {
      await _coordinator.disable();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _coordinator.prefs;
    return ValueListenableBuilder<TrackingStatus>(
      valueListenable: _coordinator.status,
      builder: (context, status, _) {
        final available = status != TrackingStatus.unsupported;
        return SurfaceCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg, vertical: AppSpace.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr.trackingEnable),
                subtitle: Text(tr.trackingEnableHint),
                value: prefs.enabled && available,
                onChanged: available ? _toggle : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr.trackingShowSpend),
                subtitle: Text(tr.trackingShowSpendHint),
                value: prefs.showSpend,
                onChanged: available && prefs.enabled
                    ? (v) => prefs.setShowSpend(v)
                    : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr.trackingShowPlace),
                subtitle: Text(tr.trackingShowPlaceHint),
                value: prefs.showPlace,
                onChanged: available && prefs.enabled
                    ? (v) => prefs.setShowPlace(v)
                    : null,
              ),
              const Divider(height: 20),
              Text(_statusText(status), style: AppText.body),
              const SizedBox(height: AppSpace.xs),
              Text(tr.trackingCountNote, style: AppText.caption),
            ],
          ),
        );
      },
    );
  }
}
