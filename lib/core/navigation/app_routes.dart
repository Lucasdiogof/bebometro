import 'package:flutter/material.dart';

import '../../settings/presentation/settings_page.dart';
import '../../l10n/l10n.dart';

/// Shared entry points that must never stack twice (e.g. tapping the settings
/// icon repeatedly).
class AppRoutes {
  const AppRoutes._();

  static bool _settingsOpen = false;

  static Future<void> openSettings(BuildContext context) async {
    if (_settingsOpen) return;
    _settingsOpen = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    } finally {
      _settingsOpen = false;
    }
  }
}

/// The settings icon used in the header of the main tabs.
class SettingsAction extends StatelessWidget {
  const SettingsAction({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tr.settingsTitle,
        onPressed: () => AppRoutes.openSettings(context),
        icon: const Icon(Icons.settings_outlined),
      );
}
