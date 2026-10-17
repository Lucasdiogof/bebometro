import 'package:bebometro/account/application/auth_callback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasAuthCallbackParams', () {
    test('a plain page load is not a callback', () {
      expect(hasAuthCallbackParams(Uri.parse('http://localhost:8080/')), isFalse);
      expect(hasAuthCallbackParams(Uri.parse('http://localhost:8080/#/home')),
          isFalse);
    });

    test('a PKCE code in the query is a callback', () {
      expect(hasAuthCallbackParams(Uri.parse('http://localhost:8080/?code=abc')),
          isTrue);
    });

    test('tokens and errors in the fragment are callbacks', () {
      expect(
          hasAuthCallbackParams(
              Uri.parse('http://localhost:8080/#access_token=a&type=recovery')),
          isTrue);
      expect(
          hasAuthCallbackParams(
              Uri.parse('http://localhost:8080/#error_code=otp_expired')),
          isTrue);
    });

    test('unrelated query parameters are ignored', () {
      expect(hasAuthCallbackParams(Uri.parse('http://localhost:8080/?lang=en')),
          isFalse);
    });
  });
}
