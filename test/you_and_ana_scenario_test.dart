import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/games/domain/party_meter.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:bebometro/table/domain/order_builder.dart';
import 'package:bebometro/table/domain/table_orders.dart';
import 'package:flutter_test/flutter_test.dart';

/// The scenario of the product brief, end to end on the domain layer:
/// Você + Ana, consumers and payers apart, service, payments, repeat.
const _me = Participant(id: 'p-me', name: 'Você', isMe: true);
const _ana = Participant(id: 'p-ana', name: 'Ana');
final _t = DateTime(2026, 10, 24, 21);

var _n = 0;
String _id() => 'id${_n++}';

OrderInput _in({
  required String name,
  required List<String> consumers,
  required List<String> payers,
  required int cents,
  OrderKind kind = OrderKind.alcoholic,
}) => OrderInput(
  outingId: 'o',
  name: name,
  kind: kind,
  ownerId: _me.id,
  at: _t,
  consumers: consumers,
  payers: payers,
  priceKind: PriceKind.informed,
  priceCents: cents,
);

void main() {
  setUp(() => _n = 0);

  test('Você + Ana: orders, bill, service, balances, repeat and Bafômetro', () {
    // 1. Você orders a Heineken 600 for both; 2. only Você pays.
    final heineken = OrderBuilder.build(
      _in(
        name: 'Heineken 600',
        consumers: [_me.id, _ana.id],
        payers: [_me.id],
        cents: 2000,
      ),
      newId: _id,
    ).entries.single;
    // 3. Ana orders an individual drink; 4. Você pays for it as well.
    final gin = OrderBuilder.build(
      _in(
        name: 'Gin tônica',
        consumers: [_ana.id],
        payers: [_me.id],
        cents: 3000,
      ),
      newId: _id,
    ).entries.single;
    // 5. Both share a food paid by both.
    final food = OrderBuilder.build(
      _in(
        name: 'Porção',
        kind: OrderKind.food,
        consumers: [_me.id, _ana.id],
        payers: [_me.id, _ana.id],
        cents: 4001,
      ),
      newId: _id,
    ).extra!;

    var doc = TabDoc.forTable('o', _me).copyWith(
      participants: [_me, _ana],
      extras: [food],
      serviceOn: true,
      serviceBp: 1000,
    );
    final entries = {
      for (final e in [heineken, gin]) e.id: e,
    };

    // 6. Personal orders, bill, service and balances.
    final consumption = TabCalculator.consumption(doc, entries.values);
    expect(consumption[_me.id]!.individualCount, 0);
    expect(consumption[_me.id]!.sharedCount, 1);
    expect(consumption[_ana.id]!.individualCount, 1);
    expect(consumption[_ana.id]!.sharedCount, 1);

    final r = TabCalculator.compute(doc, entries);
    // heineken 2000 once + gin 3000 + food 4001 = 9001; service 10% = 900/901
    expect(r.subtotal, 9001);
    final service = TabCalculator.percentOf(9001, 1000);
    expect(r.service, service);
    expect(r.total, 9001 + service);
    // Ana pays only half the food (+ its service); Você the rest.
    expect(r.shareOf(_ana.id) + r.shareOf(_me.id), r.total);
    expect(r.shareOf(_ana.id), lessThan(r.shareOf(_me.id)));
    expect(r.splitComplete, isTrue);
    // Você's own spending: heineken + gin (both his cost) + half the food.
    expect(heineken.ownerCostCents, 2000);
    expect(gin.ownerCostCents, 3000);

    // Payments are separate from the cost and survive a correction.
    doc = doc.copyWith(
      payments: [
        TabPayment(id: 'p1', participantId: _me.id, cents: 5000, at: _t),
      ],
    );
    final paid = TabCalculator.compute(doc, entries);
    expect(paid.paidBy(_me.id), 5000);
    expect(paid.balanceOf(_me.id), paid.shareOf(_me.id) - 5000);
    // Closing the outing is independent of settling the bill.
    expect(paid.venueSettled, isFalse);

    // 7. Repeat keeps consumers, payers, price and condition; new id/origin.
    final again = heineken.repeated(
      newId: _id(),
      at: _t.add(const Duration(minutes: 30)),
    );
    expect(again.id, isNot(heineken.id));
    expect(again.portions, heineken.portions);
    expect(again.payers, heineken.payers);
    expect(again.billTotalCents, 2000);
    expect(again.priceKind, PriceKind.informed);
    expect(again.entryOrigin, isNull);
    final repeatedGin = gin.repeated(newId: _id(), at: _t);
    expect(repeatedGin.consumerId, _ana.id);
    expect(repeatedGin.payers, gin.payers);
    final all = {...entries, again.id: again, repeatedGin.id: repeatedGin};
    final rows = TableOrders.rows(doc, all, const PersonFilter.table());
    final heinekenRow = rows.firstWhere((x) => x.title.contains('Heineken'));
    expect(heinekenRow.quantity, 2); // same order, same payers: one row
    expect(heinekenRow.payerIds, [_me.id]);

    // 8. Bafômetro: each person's level comes from their own alcoholic orders.
    final c = TabCalculator.consumption(doc, all.values);
    expect(PartyMeter.level(c[_me.id]!.alcoholicCount), 0); // only shared
    expect(PartyMeter.level(c[_ana.id]!.alcoholicCount), 2 / 6); // gin x2
  });
}
