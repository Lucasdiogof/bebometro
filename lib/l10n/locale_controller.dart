import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../core/data/device_store.dart';
import 'l10n.dart';

/// What the person picked in Settings.
enum LanguageChoice {
  system('system'),
  pt('pt'),
  en('en'),
  es('es');

  const LanguageChoice(this.code);

  /// Stored value (device preference; never translated).
  final String code;

  static LanguageChoice fromCode(String? code) => LanguageChoice.values
      .firstWhere((c) => c.code == code, orElse: () => LanguageChoice.system);
}

/// The app's language: a device preference (no account, no connection
/// needed). "System" follows the phone when it is Portuguese, English or
/// Spanish; anything else falls back to Brazilian Portuguese.
///
/// Changing it never restarts the app: [locale] changes, [tr] is switched
/// first, and the app root rebuilds every element in place, so forms, the
/// running outing and a game in progress keep their state.
class LocaleController extends ChangeNotifier with WidgetsBindingObserver {
  LocaleController(this._device) {
    _choice = LanguageChoice.fromCode(_device.getString(_key));
    _locale = _resolve();
    setCurrentLocale(_locale);
    WidgetsBinding.instance.addObserver(this);
  }

  static const _key = 'app.language';
  static const supported = ['pt', 'en', 'es'];

  final DeviceStore _device;
  late LanguageChoice _choice;
  late Locale _locale;

  LanguageChoice get choice => _choice;

  /// Locale in use. Portuguese is always pt-BR.
  Locale get locale => _locale;

  Locale _resolve() {
    final code = _choice == LanguageChoice.system
        ? PlatformDispatcher.instance.locale.languageCode
        : _choice.code;
    return switch (code) {
      'en' => const Locale('en'),
      'es' => const Locale('es'),
      _ => const Locale('pt', 'BR'),
    };
  }

  Future<void> setChoice(LanguageChoice choice) async {
    _choice = choice;
    await _device.setString(_key, choice.code);
    _apply();
  }

  void _apply() {
    final next = _resolve();
    if (next == _locale) return;
    _locale = next;
    setCurrentLocale(next);
    notifyListeners();
  }

  /// The phone's language changed while "System" is selected.
  @override
  void didChangeLocales(List<Locale>? locales) {
    if (_choice == LanguageChoice.system) _apply();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// Marks every element below [context] for rebuild, keeping all State
/// objects. Used once per language change so texts produced through [tr]
/// (outside `Localizations.of`) are rebuilt too.
void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}
