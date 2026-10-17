import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime(2026, 10, 16, 20);

TabExtra extra(
  String id,
  int? cents, {
  ExtraCategory c = ExtraCategory.food,
  bool service = true,
}) => TabExtra(
  id: id,
  description: id,
  category: c,
  createdAt: _t,
  priceKind: cents == null ? PriceKind.unknown : PriceKind.informed,
  cents: cents,
  service: service,
);

const _people = [
  Participant(id: 'a', name: 'Ana', isMe: true),
  Participant(id: 'b', name: 'Bia'),
  Participant(id: 'c', name: 'Caio'),
];

TabDoc doc({
  List<TabExtra> extras = const [],
  bool serviceOn = false,
  int bp = 1000,
  SplitMode mode = SplitMode.equal,
  Map<String, int> custom = const {},
  DiscountKind dk = DiscountKind.none,
  int dv = 0,
}) => TabDoc(
  outingId: 'o',
  participants: _people,
  extras: extras,
  serviceOn: serviceOn,
  serviceBp: bp,
  mode: mode,
  equalIds: const ['a', 'b', 'c'],
  custom: custom,
  discountKind: dk,
  discountValue: dv,
);

void main() {
  group('allocate', () {
    test('R\$ 100 among three keeps every cent', () {
      final parts = TabCalculator.allocate(10000, [1, 1, 1]);
      expect(parts.reduce((a, b) => a + b), 10000);
      expect(parts, [3334, 3333, 3333]);
    });

    test('is deterministic and sums for uneven weights', () {
      for (final total in [1, 7, 99, 10001, 123457]) {
        final w = [3, 5, 2, 7];
        final parts = TabCalculator.allocate(total, w);
        expect(parts.reduce((a, b) => a + b), total, reason: 'total $total');
        expect(parts, TabCalculator.allocate(total, w));
      }
    });
  });

  group('tab totals', () {
    test('R\$ 100 split equally among three: shares sum to the total', () {
      final r = TabCalculator.compute(doc(extras: [extra('x', 10000)]), {});
      expect(r.total, 10000);
      expect(r.shares.values.reduce((a, b) => a + b), 10000);
      expect(r.splitComplete, isTrue);
    });

    for (final bp in [500, 1000, 2000, 1234]) {
      test('service ${bp / 100}% only on eligible lines', () {
        final r = TabCalculator.compute(
          doc(
            serviceOn: true,
            bp: bp,
            extras: [
              extra('food', 10000),
              extra('taxi', 5000, c: ExtraCategory.transport, service: false),
            ],
          ),
          {},
        );
        final expected = (10000 * bp + 5000) ~/ 10000;
        expect(r.serviceBase, 10000);
        expect(r.service, expected);
        expect(r.total, 15000 + expected);
        // The transport line carries no service.
        final taxi = r.results.firstWhere((l) => l.line.id == 'taxi');
        expect(taxi.service, 0);
      });
    }

    test('turning the service off recalculates to the plain subtotal', () {
      final extras = [extra('food', 10000)];
      final on = TabCalculator.compute(
        doc(serviceOn: true, extras: extras),
        {},
      );
      final off = TabCalculator.compute(
        doc(serviceOn: false, extras: extras),
        {},
      );
      expect(on.total, 11000);
      expect(off.total, 10000);
      expect(off.service, 0);
    });

    test(
      'unknown prices make the total partial and are not counted as zero',
      () {
        final r = TabCalculator.compute(
          doc(extras: [extra('a', 3000), extra('b', null)]),
          {},
        );
        expect(r.isPartial, isTrue);
        expect(r.pendingCount, 1);
        expect(r.subtotal, 3000);
        expect(r.splitComplete, isFalse);
      },
    );

    test(
      'percent discount is applied before the service and never exceeds',
      () {
        final r = TabCalculator.compute(
          doc(
            serviceOn: true,
            bp: 1000,
            dk: DiscountKind.percent,
            dv: 1000,
            extras: [extra('food', 10000)],
          ),
          {},
        );
        expect(r.discount, 1000);
        expect(r.serviceBase, 9000);
        expect(r.service, 900);
        expect(r.total, 10000 - 1000 + 900);
      },
    );

    test('amount discount is capped at the subtotal', () {
      final r = TabCalculator.compute(
        doc(dk: DiscountKind.amount, dv: 99999, extras: [extra('a', 5000)]),
        {},
      );
      expect(r.discount, 5000);
      expect(r.total, 0);
    });

    test('custom split reports what is left unassigned', () {
      final r = TabCalculator.compute(
        doc(
          mode: SplitMode.custom,
          custom: {'a': 4000, 'b': 3000},
          extras: [extra('x', 10000)],
        ),
        {},
      );
      expect(r.unassigned, 3000);
      expect(r.splitComplete, isFalse);
    });
  });
}
