import 'dart:ui' show Locale;

import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Strings of the language currently on screen. Widgets, cubits and models
/// read it at the moment they build a text (never store the result as data).
/// [LocaleController] switches it before the app rebuilds, so every text is
/// produced again in the new language without losing any state.
AppLocalizations get tr => _current;

AppLocalizations _current = lookupAppLocalizations(const Locale('pt'));

/// Language code on screen ('pt', 'en' or 'es').
String get trLanguage => _language;
String _language = 'pt';

/// [original] (the catalog's own wording, in Portuguese) or its editorial
/// translation for the language on screen. Never used for text the person
/// wrote.
String localizedText(String original, Map<String, String> byLanguage) =>
    byLanguage[_language] ?? original;

/// Locale tag for `intl` formatting ('pt_BR', 'en', 'es').
String get trLocaleTag => _tag;
String _tag = 'pt_BR';

void setCurrentLocale(Locale locale) {
  _current = lookupAppLocalizations(locale);
  _language = switch (locale.languageCode) {
    'en' => 'en',
    'es' => 'es',
    _ => 'pt',
  };
  _tag = switch (locale.languageCode) {
    'en' => 'en',
    'es' => 'es',
    _ => 'pt_BR',
  };
}
