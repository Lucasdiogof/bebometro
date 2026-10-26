// On the web (JavaScript) Dart bit shifts are 32-bit: `1 << 40` is 0 there. A
// shift in money math therefore breaks only in the published site. This scans
// the money code for shifts so the mistake cannot come back unnoticed.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no bit shifts in the code that computes money', () {
    final shift = RegExp(r'[\w)\]]\s*(<<|>>>?)\s*[\w(]');
    final offenders = <String>[];
    for (final dir in ['lib/tab', 'lib/outings/domain', 'lib/drinks/domain']) {
      for (final f in Directory(dir).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final code = lines[i].split('//').first;
          // `>>` closing nested generics (List<List<int>>) is not a shift.
          if (shift.hasMatch(code) && !RegExp(r'<[^<>]*<[^<>]*>>').hasMatch(code)) {
            offenders.add('${f.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
