// "Custo das suas bebidas" (Home) = what the owner BEARS on drink orders, whoever
// drank. Who drank (consumer) and who pays (payers) are independent.
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/outings/domain/outing_summary.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 10, 26, 22);
var _n = 0;

DrinkEntry order({
  String? consumer,
  Map<String, int>? payers,
  int? cents = 3000,
  bool shared = false,
}) {
  _n++;
  return DrinkEntry(
    id: 'h$_n',
    outingId: 'o',
    consumedAt: _t.add(Duration(minutes: _n)),
    name: 'Drink',
    category: DrinkCategory.cocktail,
    createdAt: _t,
    updatedAt: _t,
    priceKind: cents == null ? PriceKind.unknown : PriceKind.informed,
    paidCents: shared ? null : cents,
    billTotalCents: shared ? cents : null,
    isShared: shared,
    consumerId: consumer,
    payers: payers,
  );
}

void main() {
  test('drunk only by Ana, paid entirely by Você: the cost is Você\'s', () {
    final s = OutingSummary.of([order(consumer: 'ana', payers: {ownerPortionKey: 1})]);
    expect(s.informedCents, 3000); // not omitted
    expect(s.entryCount, 0); // but it is not one of Você's drinks
    expect(s.unpricedCount, 0);
  });

  test('drunk by Você, paid entirely by Ana: a drink of Você, no cost', () {
    final s = OutingSummary.of([order(payers: {'ana': 1})]);
    expect(s.entryCount, 1);
    expect(s.informedCents, 0);
  });

  test('split 50/50: Você bears half of an order Ana drank', () {
    final s = OutingSummary.of([
      order(consumer: 'ana', payers: {ownerPortionKey: 1, 'ana': 1}),
    ]);
    expect(s.informedCents, 1500);
  });

  test('an order with no price is flagged, never counted as zero cost', () {
    final s = OutingSummary.of([
      order(consumer: 'ana', payers: {ownerPortionKey: 1}, cents: null),
    ]);
    expect(s.unpricedCount, 1);
    expect(s.informedCents, 0);
  });

  test('the table view still sums every order', () {
    final list = [
      order(consumer: 'ana', payers: {ownerPortionKey: 1}),
      order(payers: {'ana': 1}),
    ];
    expect(OutingSummary.of(list, mineOnly: false).informedCents, 6000);
  });
}
