import 'package:bebometro/core/data/local_store.dart';
import 'package:bebometro/drinks/data/drink_repository.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/tab/data/tab_repository.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:bebometro/table/domain/order_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The numbers of the QA brief (Você + Ana), checked on the real repositories
/// (the same local store the app syncs from), including edits, repeats,
/// pending prices and delete/undo.
const _me = Participant(id: 'p-me', name: 'Você', isMe: true);
const _ana = Participant(id: 'p-ana', name: 'Ana');
final _t = DateTime(2026, 10, 24, 21);
const _o = 'qa-outing';

late DrinkRepository drinks;
late TabRepository tabs;

Future<void> _setup() async {
  SharedPreferences.setMockInitialValues({});
  final store = await LocalStore.openAccount('u-qa');
  drinks = DrinkRepository(store, const []);
  tabs = TabRepository(store, drinks);
  await tabs.update(
    _o,
    (_) => TabDoc.forTable(
      _o,
      _me,
    ).copyWith(participants: [_me, _ana], equalIds: [_me.id, _ana.id]),
  );
}

OrderInput _in(
  String name, {
  required List<String> consumers,
  required List<String> payers,
  int? cents,
  PriceKind kind = PriceKind.informed,
  int quantity = 1,
  PriceBasis basis = PriceBasis.unit,
  Map<String, int>? payerCents,
  OrderKind orderKind = OrderKind.alcoholic,
  List<DrinkEntry> existing = const [],
  TabExtra? existingExtra,
}) => OrderInput(
  outingId: _o,
  name: name,
  kind: orderKind,
  ownerId: _me.id,
  at: _t,
  quantity: quantity,
  consumers: consumers,
  payers: payers,
  payerCents: payerCents,
  priceKind: kind,
  priceCents: cents,
  basis: basis,
  existing: existing,
  existingExtra: existingExtra,
);

/// What OrderPage does on save for drinks / extras.
Future<List<DrinkEntry>> _save(OrderInput i) async {
  final r = OrderBuilder.build(i, newId: drinks.newId);
  if (r.extra != null) {
    final x = r.extra!;
    await tabs.update(
      _o,
      (d) => d.copyWith(
        extras: [
          for (final e in d.extras) e.id == x.id ? x : e,
          if (!d.extras.any((e) => e.id == x.id)) x,
        ],
      ),
    );
    return const [];
  }
  await drinks.saveAll(r.entries);
  final kept = {for (final e in r.entries) e.id};
  for (final e in i.existing) {
    if (!kept.contains(e.id)) await drinks.delete(e.id);
  }
  return r.entries;
}

Future<void> _scenario() async {
  await _save(
    _in(
      'Heineken 600',
      consumers: [_me.id, _ana.id],
      payers: [_me.id],
      cents: 2000,
    ),
  );
  await _save(
    _in('Drink da Ana', consumers: [_ana.id], payers: [_me.id], cents: 3000),
  );
  await _save(
    _in(
      'Batata',
      orderKind: OrderKind.food,
      consumers: [_me.id, _ana.id],
      payers: [_me.id, _ana.id],
      cents: 6000,
    ),
  );
}

TabResult _r() => tabs.compute(_o);

void main() {
  setUp(_setup);

  test(
    'A+B+C: mesa R\$ 110, você R\$ 80, Ana R\$ 30; com serviço 121 / 88 / 33',
    () async {
      await _scenario();
      var r = _r();
      expect(r.total, 11000);
      expect(r.shareOf(_me.id), 8000);
      expect(r.shareOf(_ana.id), 3000);
      await tabs.update(
        _o,
        (d) => d.copyWith(serviceOn: true, serviceBp: 1000),
      );
      r = _r();
      expect(r.total, 12100);
      expect(r.shareOf(_me.id), 8800);
      expect(r.shareOf(_ana.id), 3300);

      // A payment of R$ 121 by Você settles the venue and reassigns nothing.
      await tabs.update(
        _o,
        (d) => d.copyWith(
          payments: [
            TabPayment(id: 'p', participantId: _me.id, cents: 12100, at: _t),
          ],
        ),
      );
      r = _r();
      expect(r.venueSettled, isTrue);
      expect(r.venueDueCents, 0);
      expect(r.shareOf(_me.id), 8800);
      expect(r.shareOf(_ana.id), 3300);
      expect(r.paidBy(_ana.id), 0);
      final c = TabCalculator.consumption(
        tabs.load(_o),
        tabs.entriesOf(_o).values,
      );
      expect(c[_ana.id]!.individualCount, 1);
      expect(c[_ana.id]!.sharedCount, 1);
      expect(c[_me.id]!.sharedCount, 1);
    },
  );

  test('editing the Heineken to R\$ 24: 114 / 84 / 30, with service 125,40 / 92,40 / 33', () async {
    await _scenario();
    await tabs.update(
      _o,
      (d) => d.copyWith(
        payments: [
          TabPayment(id: 'p', participantId: _me.id, cents: 5000, at: _t),
        ],
      ),
    );
    final before = tabs
        .entriesOf(_o)
        .values
        .firstWhere((e) => e.name == 'Heineken 600');
    final saved = await _save(
      _in(
        'Heineken 600',
        consumers: [_me.id, _ana.id],
        payers: [_me.id],
        cents: 2400,
        existing: [before],
      ),
    );
    expect(saved.single.id, before.id); // same record
    expect(saved.single.portions, before.portions); // consumers kept
    expect(saved.single.payers, before.payers); // payers kept
    var r = _r();
    expect(r.total, 11400);
    expect(r.shareOf(_me.id), 8400);
    expect(r.shareOf(_ana.id), 3000);
    expect(r.paidBy(_me.id), 5000); // payment untouched
    await tabs.update(_o, (d) => d.copyWith(serviceOn: true, serviceBp: 1000));
    r = _r();
    expect(r.total, 12540);
    expect(r.shareOf(_me.id), 9240);
    expect(r.shareOf(_ana.id), 3300);
  });

  test(
    'price edit of a shared order with independent payers (records and tab)',
    () async {
      await _scenario();
      final h = tabs
          .entriesOf(_o)
          .values
          .firstWhere((e) => e.name == 'Heineken 600');
      expect(h.isShared, isTrue);
      // through the record API used by "fill price" / price fix
      await drinks.applyPrices({
        h.id: (kind: PriceKind.informed, paidCents: 2400),
      });
      var e = drinks.entryById(h.id)!;
      expect(e.billTotalCents, 2400); // whole order, not the owner share
      expect(e.paidCents, 2400); // owner pays it all
      expect(e.payers, h.payers);
      expect(e.portions, h.portions);
      expect(e.ownerCostCents, 2400);
      // payers Você + Ana: the bill total is split by the payers
      final both = await _save(
        _in(
          'Heineken 600',
          consumers: [_me.id, _ana.id],
          payers: [_me.id, _ana.id],
          cents: 2400,
          existing: [e],
        ),
      );
      await drinks.applyPrices({
        both.single.id: (kind: PriceKind.informed, paidCents: 3000),
      });
      e = drinks.entryById(h.id)!;
      expect(e.billTotalCents, 3000);
      expect(e.paidCents, 1500); // the owner's half
      expect(e.payers, {ownerPortionKey: 1, _ana.id: 1});
      expect(e.portions!.keys, unorderedEquals([ownerPortionKey, _ana.id]));
      await drinks.setBillTotal(h.id, 4000);
      e = drinks.entryById(h.id)!;
      expect(e.paidCents, 2000);
      expect(e.billTotalCents, 4000);
      expect(_r().subtotal, 4000 + 3000 + 6000);
    },
  );

  test('only the consumers change: payers stay; only the payers change: consumers stay', () async {
    await _scenario();
    final h = tabs
        .entriesOf(_o)
        .values
        .firstWhere((e) => e.name == 'Heineken 600');
    final consumersOnly = (await _save(
      _in(
        'Heineken 600',
        consumers: [_me.id],
        payers: [_me.id],
        cents: 2000,
        existing: [h],
      ),
    )).single;
    expect(consumersOnly.payers, h.payers);
    expect(consumersOnly.isShared, isFalse);
    final payersOnly = (await _save(
      _in(
        'Heineken 600',
        consumers: [_me.id],
        payers: [_ana.id],
        cents: 2000,
        existing: [consumersOnly],
      ),
    )).single;
    expect(payersOnly.consumerId, isNull); // still Você's drink
    expect(payersOnly.payers, {_ana.id: 1});
    expect(_r().shareOf(_ana.id), 5000); // heineken 20 + half the food
  });

  test(
    'repeating the Ana drink keeps her as consumer and Você as payer',
    () async {
      await _scenario();
      final gin = tabs
          .entriesOf(_o)
          .values
          .firstWhere((e) => e.name == 'Drink da Ana');
      final again = gin.repeated(newId: drinks.newId(), at: _t);
      await drinks.save(again);
      final back = drinks.entryById(again.id)!;
      expect(back.consumerId, _ana.id);
      expect(back.payers, {ownerPortionKey: 1});
      expect(_r().shareOf(_ana.id), 3000); // her food half only
      expect(_r().shareOf(_me.id), 8000 + 3000);
    },
  );

  test('no price: payers survive, then the price is informed', () async {
    await _scenario();
    final x = (await _save(
      _in(
        'Mistério',
        consumers: [_ana.id],
        payers: [_me.id, _ana.id],
        kind: PriceKind.unknown,
      ),
    )).single;
    expect(_r().isPartial, isTrue);
    var e = drinks.entryById(x.id)!;
    expect(e.payers, {ownerPortionKey: 1, _ana.id: 1});
    await drinks.applyPrices({
      x.id: (kind: PriceKind.informed, paidCents: 1001),
    });
    e = drinks.entryById(x.id)!;
    expect(e.payers, {ownerPortionKey: 1, _ana.id: 1});
    expect(e.consumerId, _ana.id);
    final r = _r();
    expect(r.isPartial, isFalse);
    expect(r.total, 11000 + 1001);
    expect(r.shareOf(_me.id) + r.shareOf(_ana.id), r.total);
  });

  test('courtesy and typed amounts with cents', () async {
    await _scenario();
    final free = (await _save(
      _in(
        'Brinde',
        consumers: [_me.id],
        payers: [_me.id],
        kind: PriceKind.complimentary,
      ),
    )).single;
    expect(free.priceKind, PriceKind.complimentary);
    expect(_r().total, 11000); // zero, and not "unknown"
    expect(_r().isPartial, isFalse);
    await _save(
      _in(
        'Rodada',
        consumers: [_me.id, _ana.id],
        payers: [_me.id, _ana.id],
        cents: 10001,
        payerCents: const {'p-me': 6001, 'p-ana': 4000},
      ),
    );
    final r = _r();
    expect(r.total, 11000 + 10001);
    expect(r.shareOf(_ana.id), 3000 + 4000);
    expect(r.shareOf(_me.id), 8000 + 6001);
  });

  test('quantity above 1: unit price and total price count once', () async {
    await _setupFresh();
    final unit = await _save(
      _in(
        'Chopp',
        consumers: [_me.id],
        payers: [_me.id],
        cents: 1000,
        quantity: 3,
      ),
    );
    expect(unit, hasLength(3));
    expect(_r().total, 3000); // not 9000
    await _setupFresh();
    final total = await _save(
      _in(
        'Chopp',
        consumers: [_me.id],
        payers: [_me.id],
        cents: 3000,
        quantity: 3,
        basis: PriceBasis.total,
      ),
    );
    expect(total.map((e) => e.paidCents).toList(), [1000, 1000, 1000]);
    expect(_r().total, 3000); // not 9000
    await _setupFresh();
    await _save(
      _in(
        'Prato',
        orderKind: OrderKind.food,
        consumers: [_me.id, _ana.id],
        payers: [_me.id],
        cents: 2000,
        quantity: 2,
      ),
    );
    expect(_r().total, 4000);
    await _setupFresh();
    await _save(
      _in(
        'Prato',
        orderKind: OrderKind.food,
        consumers: [_me.id, _ana.id],
        payers: [_me.id],
        cents: 4000,
        quantity: 2,
        basis: PriceBasis.total,
      ),
    );
    expect(_r().total, 4000);
  });

  test('delete and undo never bring back what was deleted before', () async {
    await _scenario();
    final all = tabs.entriesOf(_o).values.toList();
    final heineken = all.firstWhere((e) => e.name == 'Heineken 600');
    final gin = all.firstWhere((e) => e.name == 'Drink da Ana');
    final earlier = DateTime(2026, 10, 24, 22);
    await drinks.delete(heineken.id, at: earlier); // deleted before
    final later = DateTime(2026, 10, 24, 23);
    await drinks.delete(gin.id, at: later);
    expect(_r().total, 6000);
    // undo of the later deletion only
    expect(await drinks.restoreDeletedAt(gin.id, later), isTrue);
    expect(_r().total, 9000);
    expect(drinks.entryById(heineken.id)!.isDeleted, isTrue);
    // a stale undo (other stamp) restores nothing
    expect(await drinks.restoreDeletedAt(heineken.id, later), isFalse);
    expect(drinks.entryById(heineken.id)!.isDeleted, isTrue);
    // undo of an already live record is a no-op
    await drinks.restore(gin.id);
    expect(_r().total, 9000);
    // the payers survive the whole trip
    expect(drinks.entryById(gin.id)!.payers, {ownerPortionKey: 1});
  });

  test(
    'the stored row carries payers and the tab carries consumers (schema 3)',
    () async {
      await _scenario();
      final h = tabs
          .entriesOf(_o)
          .values
          .firstWhere((e) => e.name == 'Heineken 600');
      final row = h.toJson();
      expect(row['payers'], {ownerPortionKey: 1});
      final x = tabs.load(_o).extras.single;
      expect(x.consumers, [_me.id, _ana.id]);
      expect(x.assign, {_me.id: 1, _ana.id: 1});
      expect(TabRepository.schemaVersion, 3);
      final back = TabDoc.fromJson(_o, tabs.load(_o).toJson());
      expect(back.extras.single.consumers, [_me.id, _ana.id]);
    },
  );
}

Future<void> _setupFresh() => _setup();
