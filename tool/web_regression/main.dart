// Runs the money checks that broke on the web INSIDE the compiled JavaScript
// (where Dart bit shifts are 32-bit), because the Dart VM cannot show that
// defect. Build and open it in a browser:
//   flutter build web -t tool/web_regression/main.dart -o build/web_regression
//   (serve build/web_regression and open it; the result is in the page title
//   and in the console as "WEBREG ...")
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:flutter/widgets.dart';

@JS('document')
external JSObject get _document;

final _t = DateTime(2026, 10, 26, 20);

TabDoc _doc(
  int extraCents,
  int paid, {
  SplitMode mode = SplitMode.equal,
  Map<String, int> custom = const {},
}) => TabDoc(
  outingId: 'o',
  participants: const [
    Participant(id: 'a', name: 'Ana', isMe: true),
    Participant(id: 'b', name: 'Bia'),
  ],
  extras: [
    TabExtra(
      id: 'e',
      description: 'x',
      category: ExtraCategory.food,
      createdAt: _t,
      priceKind: PriceKind.informed,
      cents: extraCents,
      service: false,
    ),
  ],
  mode: mode,
  equalIds: const ['a', 'b'],
  custom: custom,
  payments: [TabPayment(id: 'p', participantId: 'a', cents: paid, at: _t)],
);

void main() {
  final results = <String, Object?>{};
  void check(String name, Object? got, Object? want) =>
      results[name] = got == want ? 'ok' : 'FAIL got=$got want=$want';

  final due = TabCalculator.compute(_doc(10000, 1000), {});
  check('venueDue 100-10', due.venueDueCents, 9000);
  final over = TabCalculator.compute(_doc(10000, 12500), {});
  check('overpaid 125-100', over.overpaidCents, 2500);
  final forOthers = TabCalculator.compute(_doc(10000, 10000), {});
  check('paidForOthers Ana', forOthers.paidForOthers('a'), 5000);
  final custom = TabCalculator.compute(
    _doc(10000, 0, mode: SplitMode.custom, custom: const {'a': 7000, 'b': 3000}),
    {},
  );
  check('custom share a', custom.shareOf('a'), 7000);
  check('custom share b', custom.shareOf('b'), 3000);
  final big = TabCalculator.compute(_doc(5000000000, 1000), {});
  check('venueDue 5e9', big.venueDueCents, 5000000000 - 1000);
  // The old bound, evaluated here at run time, to show what the platform does.
  // ignore: unused_local_variable
  final shiftNow = int.parse('1') << int.parse('40');
  results['info 1<<40 on this platform'] = shiftNow;

  final failed = results.values.any((v) => v is String && v.startsWith('FAIL'));
  final line = '${failed ? 'FAIL' : 'PASS'} $results';
  // ignore: avoid_print
  print('WEBREG $line');
  _document.setProperty('title'.toJS, 'WEBREG $line'.toJS);
  runApp(const SizedBox());
}
