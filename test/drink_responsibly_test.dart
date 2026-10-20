import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:bebometro/l10n/generated/app_localizations.dart';

void main() {
  test('the summary reminder exists in every language', () async {
    final pt = await AppLocalizations.delegate.load(const Locale('pt'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final es = await AppLocalizations.delegate.load(const Locale('es'));
    expect(pt.drinkResponsibly, 'Beba com moderação. Se beber, não dirija.');
    expect(
      en.drinkResponsibly,
      "Drink responsibly. If you drink, don't drive.",
    );
    expect(es.drinkResponsibly, 'Bebe con moderación. Si bebes, no conduzcas.');
  });
}
