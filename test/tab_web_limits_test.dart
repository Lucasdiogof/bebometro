// Run on the VM and on the web (`flutter test --platform chrome`). On the web
// Dart ints are JavaScript numbers: bit shifts are 32-bit, so a bound written as
// `1 << 40` is 0 there and every `clamp(0, bound)` returned 0 (the bar's "due"
// amount was always R$ 0,00). These tests fail with the old bound on the web.
import 'package:bebometro/core/data/local_store.dart';
import 'package:bebometro/drinks/data/drink_repository.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/tab/data/tab_repository.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _t = DateTime(2026, 10, 26, 20);

TabDoc _doc({
  required List<int> extraCents,
  List<int> paid = const [],
  SplitMode mode = SplitMode.equal,
  Map<String, int> custom = const {},
}) => TabDoc(
  outingId: 'o',
  participants: const [
    Participant(id: 'a', name: 'Ana', isMe: true),
    Participant(id: 'b', name: 'Bia'),
  ],
  extras: [
    for (var i = 0; i < extraCents.length; i++)
      TabExtra(
        id: 'e$i',
        description: 'x$i',
        category: ExtraCategory.food,
        createdAt: _t,
        priceKind: PriceKind.informed,
        cents: extraCents[i],
        service: false,
      ),
  ],
  mode: mode,
  equalIds: const ['a', 'b'],
  custom: custom,
  payments: [
    for (var i = 0; i < paid.length; i++)
      TabPayment(id: 'p$i', participantId: 'a', cents: paid[i], at: _t),
  ],
);

void main() {
  group('amounts that a 32-bit shift would turn into zero', () {
    test('the bar is still owed R\$ 90 after a R\$ 10 payment', () {
      final r = TabCalculator.compute(_doc(extraCents: [10000], paid: [1000]), {});
      expect(r.venueDueCents, 9000);
      expect(r.overpaidCents, 0);
    });

    test('an overpayment is reported, not dropped to zero', () {
      final r = TabCalculator.compute(_doc(extraCents: [10000], paid: [12500]), {});
      expect(r.venueDueCents, 0);
      expect(r.overpaidCents, 2500);
    });

    test('paid for the others: Ana pays all, Bia owes nothing', () {
      final r = TabCalculator.compute(_doc(extraCents: [10000], paid: [10000]), {});
      expect(r.paidForOthers('a'), 5000);
      expect(r.paidForOthers('b'), 0);
    });

    test('custom shares keep their value (they were clamped to 0)', () {
      final r = TabCalculator.compute(
        _doc(
          extraCents: [10000],
          mode: SplitMode.custom,
          custom: const {'a': 7000, 'b': 3000},
        ),
        {},
      );
      expect(r.shareOf('a'), 7000);
      expect(r.shareOf('b'), 3000);
    });

    test('values above 2^32 cents survive (more than a 32-bit bound)', () {
      const big = 5000000000; // R$ 50 million: past any 32-bit limit
      final r = TabCalculator.compute(_doc(extraCents: [big], paid: [1000]), {});
      expect(r.venueDueCents, big - 1000);
      expect(r.overpaidCents, 0);
    });
  });

  group('writing the tab', () {
    late LocalStore store;
    late TabRepository tabs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = await LocalStore.openAccount('u-tab');
      tabs = TabRepository(store, DrinkRepository(store, const []));
    });

    TabDoc withTable(TabDoc d) => d.copyWith(serviceOn: true);

    test('an update that changes nothing writes nothing', () async {
      await tabs.update('o1', withTable);
      final first = store.get(LocalStore.outingTabs, 'o1')!;
      final pending = store.pendingCount;
      final revision = store.revisionOf(LocalStore.outingTabs, 'o1');

      await tabs.update('o1', (d) => d); // same document again
      await tabs.update('o1', withTable); // sets what is already set

      final after = store.get(LocalStore.outingTabs, 'o1')!;
      expect(after['updated_at'], first['updated_at']);
      expect(store.pendingCount, pending);
      expect(store.revisionOf(LocalStore.outingTabs, 'o1'), revision);
    });

    test('a real change is still written', () async {
      await tabs.update('o1', withTable);
      final before = store.get(LocalStore.outingTabs, 'o1')!['updated_at'];
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await tabs.update('o1', (d) => d.copyWith(serviceOn: false));
      expect(tabs.load('o1').serviceOn, isFalse);
      expect(store.get(LocalStore.outingTabs, 'o1')!['updated_at'], isNot(before));
    });
  });
}
