import 'package:flutter_test/flutter_test.dart';
import 'package:bebometro/settings/presentation/legal_links_section.dart';

void main() {
  test('legal links point to the published pages', () {
    expect(
      LegalLinks.privacy,
      'https://lucksrei.com/projects/bebometro/privacy/',
    );
    expect(LegalLinks.terms, 'https://lucksrei.com/projects/bebometro/terms/');
    expect(
      LegalLinks.support,
      'https://lucksrei.com/projects/bebometro/support/',
    );
    expect(
      LegalLinks.dataDeletion,
      'https://lucksrei.com/projects/bebometro/data-deletion/',
    );
    for (final u in [
      LegalLinks.privacy,
      LegalLinks.terms,
      LegalLinks.support,
      LegalLinks.dataDeletion,
    ]) {
      expect(Uri.parse(u).scheme, 'https');
    }
  });
}
