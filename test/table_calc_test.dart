import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:bebometro/table/domain/table_orders.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 10, 19, 22);

const _me = Participant(id: 'p-lucas', name: 'Lucas', isMe: true);
const _ana = Participant(id: 'p-ana', name: 'Ana');

var _n = 0;

DrinkEntry drink({
  String? id,
  String name = 'Chopp',
  DrinkCategory category = DrinkCategory.draft,
  int? containerMl = 400,
  int? personalMl,
  PriceKind kind = PriceKind.informed,
  int? cents = 1500,
  String? consumerId,
  Map<String, int?>? portions,
  bool shared = false,
  int? bill,
}) {
  _n++;
  return DrinkEntry(
    id: id ?? 'e$_n',
    outingId: 'o1',
    consumedAt: _t.add(Duration(minutes: _n)),
    name: name,
    category: category,
    createdAt: _t,
    updatedAt: _t,
    containerMl: containerMl,
    personalMl: shared ? personalMl : (personalMl ?? containerMl),
    priceKind: kind,
    paidCents: kind == PriceKind.informed ? cents : null,
    isShared: shared,
    peopleCount: portions?.length ?? 1,
    billTotalCents: bill,
    consumerId: consumerId,
    portions: portions,
  );
}

TabExtra food(int cents, List<String> ids, {String name = 'Batata'}) =>
    TabExtra(
      id: 'f-$name-$cents',
      description: name,
      category: ExtraCategory.food,
      createdAt: _t,
      priceKind: PriceKind.informed,
      cents: cents,
      assign: {for (final i in ids) i: 1},
    );

TabDoc table({
  List<Participant> people = const [_me, _ana],
  List<TabExtra> extras = const [],
  bool service = false,
  int bp = 1000,
  List<TabLink> links = const [],
  List<TabPayment> payments = const [],
  SplitMode mode = SplitMode.item,
}) => TabDoc(
  outingId: 'o1',
  participants: people,
  extras: extras,
  links: links,
  serviceOn: service,
  serviceBp: bp,
  mode: mode,
  autoLink: true,
  payments: payments,
);

Map<String, DrinkEntry> byId(List<DrinkEntry> l) => {
  for (final e in l) e.id: e,
};

void main() {
  group('A: couple at the bar', () {
    late List<DrinkEntry> entries;
    late TabDoc doc;
    late TabResult r;

    setUp(() {
      entries = [
        for (var i = 0; i < 4; i++) drink(id: 'chopp$i'),
        for (var i = 0; i < 2; i++)
          drink(
            id: 'sprit$i',
            name: 'Spritzgerald',
            category: DrinkCategory.cocktail,
            containerMl: null,
            cents: 3200,
            consumerId: _ana.id,
          ),
      ];
      doc = table(
        extras: [
          food(6000, [_me.id, _ana.id]),
        ],
        service: true,
      );
      r = TabCalculator.compute(doc, byId(entries));
    });

    test('totals: subtotal, service and bill', () {
      expect(r.subtotal, 18400);
      expect(r.service, 1840);
      expect(r.total, 20240);
      expect(r.isPartial, isFalse);
    });

    test(
      'each person owes what they ordered plus half the food, service included',
      () {
        expect(r.shareOf(_me.id), 9900);
        expect(r.shareOf(_ana.id), 10340);
        expect(r.shareOf(_me.id) + r.shareOf(_ana.id), r.total);
        expect(r.splitComplete, isTrue);
      },
    );

    test('breakdown per person adds up to the share', () {
      final b = TabCalculator.breakdown(doc, r);
      expect(b[_me.id]!.drinksCents, 6000);
      expect(b[_ana.id]!.drinksCents, 6400);
      expect(b[_me.id]!.foodCents, 3000);
      expect(b[_ana.id]!.foodCents, 3000);
      expect(b[_me.id]!.serviceCents, 900);
      expect(b[_ana.id]!.serviceCents, 940);
      for (final p in b.values) {
        expect(
          p.drinksCents + p.foodCents - p.discountCents + p.serviceCents,
          p.shareCents,
        );
      }
    });

    test(
      'Lucas consumption is only his four drinks; Ana drinks are not his',
      () {
        final c = TabCalculator.consumption(doc, entries);
        expect(c[_me.id]!.individualCount, 4);
        expect(c[_me.id]!.sharedCount, 0);
        expect(c[_ana.id]!.individualCount, 2);
        expect(entries.where((e) => e.isMine).length, 4);
      },
    );

    test('paying the whole bill does not make it his consumption', () {
      final paid = doc.copyWith(
        payments: [
          TabPayment(id: 'pay1', participantId: _me.id, cents: 20240, at: _t),
        ],
      );
      final pr = TabCalculator.compute(paid, byId(entries));
      expect(pr.total - pr.paid.values.fold(0, (a, b) => a + b), 0);
      expect(pr.shareOf(_me.id), 9900);
      expect(pr.shareOf(_ana.id), 10340);
      // The bar is settled; Lucas paid above his own share.
      expect(pr.balanceOf(_me.id), 9900 - 20240);
      expect(TabCalculator.consumption(paid, entries)[_me.id]!.count, 4);
      expect(pr.venueSettled, isTrue);
      expect(pr.venueDueCents, 0);
      expect(pr.paidForOthers(_me.id), 20240 - 9900);
      expect(pr.paidForOthers(_ana.id), 0);
      expect(pr.overpaidCents, 0);
    });

    test('a correction after payment recalculates the difference and keeps the payment', () {
      final paid = doc.copyWith(
        payments: [
          TabPayment(id: 'pay1', participantId: _me.id, cents: 20240, at: _t),
        ],
      );
      // A chopp turns out to cost R\$ 20 instead of 15.
      final fixed = [
        entries.first.copyWithPrice(
          kind: PriceKind.informed,
          paidCents: 2000,
          updatedAt: _t,
        ),
        ...entries.skip(1),
      ];
      final pr = TabCalculator.compute(paid, byId(fixed));
      expect(pr.paid[_me.id], 20240);
      expect(pr.venueSettled, isFalse);
      expect(pr.venueDueCents, greaterThan(0));
      // And if the bill goes down, the excess is shown, not erased.
      final cheaper = TabCalculator.compute(
        paid,
        byId([
          entries.first.copyWithPrice(kind: PriceKind.unknown, updatedAt: _t),
          ...entries.skip(1),
        ]),
      );
      expect(cheaper.isPartial, isTrue);
    });
  });

  group('B: shared bottle', () {
    DrinkEntry bottle({String id = 'b1'}) => drink(
      id: id,
      name: 'Brahma',
      containerMl: 600,
      personalMl: 400,
      shared: true,
      cents: 1500,
      bill: 3000,
      portions: {ownerPortionKey: 400, _ana.id: 200},
    );

    test('both took part, no unit of their own, and cost 15/15 by default', () {
      final e = bottle();
      final doc = table();
      final r = TabCalculator.compute(doc, byId([e]));
      expect(r.total, 3000);
      expect(r.shareOf(_me.id), 1500);
      expect(r.shareOf(_ana.id), 1500);
      final c = TabCalculator.consumption(doc, [e]);
      expect(c[_me.id]!.sharedCount, 1);
      expect(c[_me.id]!.individualCount, 0);
      expect(c[_ana.id]!.sharedCount, 1);
      expect(e.isMine, isTrue);
    });

    test('changing only who pays does not change who took part', () {
      final e = bottle();
      final doc = table(
        links: [
          TabLink(entryId: e.id, assign: {_me.id: 1}),
        ],
      );
      final r = TabCalculator.compute(doc, byId([e]));
      expect(r.shareOf(_me.id), 3000);
      expect(r.shareOf(_ana.id), 0);
      final c = TabCalculator.consumption(doc, [e]);
      expect(c[_me.id]!.sharedCount, 1);
      expect(c[_ana.id]!.sharedCount, 1);
    });

    test('repeating gives another bottle, not a duplicate of the first', () {
      final a = bottle();
      final again = a.repeated(
        newId: 'b2',
        at: _t.add(const Duration(hours: 1)),
      );
      expect(again.id, isNot(a.id));
      expect(again.portions, a.portions);
      final doc = table();
      final r = TabCalculator.compute(doc, byId([a, again]));
      expect(r.total, 6000);
      expect(
        TabCalculator.consumption(doc, [a, again])[_me.id]!.sharedCount,
        2,
      );
    });

    test('an unknown portion still counts as taking part', () {
      final e = bottle().copyWithAttribution(
        consumerId: null,
        portions: {ownerPortionKey: 400, _ana.id: null},
        personalMl: 400,
        peopleCount: 2,
        updatedAt: _t,
      );
      final c = TabCalculator.consumption(table(), [e]);
      expect(c[_ana.id]!.sharedCount, 1);
    });
  });

  group('C: food split', () {
    test('R\$ 100 among three closes in cents: 33,34 + 33,33 + 33,33', () {
      const carol = Participant(id: 'p-carol', name: 'Carol');
      final doc = table(
        people: const [_me, _ana, carol],
        extras: [
          food(10000, [_me.id, _ana.id, carol.id], name: 'Porção'),
        ],
      );
      final r = TabCalculator.compute(doc, const {});
      expect(
        [r.shareOf(_me.id), r.shareOf(_ana.id), r.shareOf(carol.id)],
        [3334, 3333, 3333],
      );
      expect(r.splitComplete, isTrue);
    });

    test('a person added later does not inherit the previous dish', () {
      const dani = Participant(id: 'p-dani', name: 'Dani');
      final doc = table(
        people: const [_me, _ana, dani],
        extras: [
          food(6000, [_me.id, _ana.id]),
        ],
      );
      final r = TabCalculator.compute(doc, const {});
      expect(r.shareOf(dani.id), 0);
      expect(r.shareOf(_me.id) + r.shareOf(_ana.id), 6000);
    });

    test(
      '"everybody" is the list of who is present, never someone who left',
      () {
        const gone = Participant(id: 'p-gone', name: 'Zé', left: true);
        final doc = table(people: const [_me, _ana, gone]);
        expect([for (final p in doc.present) p.id], [_me.id, _ana.id]);
      },
    );
  });

  group('E: corrections', () {
    test(
      'moving a drink to Ana moves the consumption and the default cost',
      () {
        final wrong = drink(id: 'w1', cents: 3200, name: 'Spritzgerald');
        final doc = table();
        var r = TabCalculator.compute(doc, byId([wrong]));
        expect(r.shareOf(_me.id), 3200);
        final fixed = wrong.copyWithAttribution(
          consumerId: _ana.id,
          portions: null,
          personalMl: wrong.personalMl,
          peopleCount: 1,
          updatedAt: _t,
        );
        r = TabCalculator.compute(doc, byId([fixed]));
        expect(r.shareOf(_me.id), 0);
        expect(r.shareOf(_ana.id), 3200);
        expect(fixed.isMine, isFalse);
        // Undo: back to the owner.
        final back = fixed.copyWithAttribution(
          consumerId: null,
          portions: null,
          personalMl: fixed.personalMl,
          peopleCount: 1,
          updatedAt: _t,
        );
        expect(TabCalculator.compute(doc, byId([back])).shareOf(_me.id), 3200);
      },
    );

    test('deleting the food recalculates the service', () {
      final dish = food(6000, [_me.id, _ana.id]);
      final entries = [drink(id: 'd1', cents: 1000)];
      var r = TabCalculator.compute(
        table(extras: [dish], service: true),
        byId(entries),
      );
      expect(r.service, 700);
      r = TabCalculator.compute(table(service: true), byId(entries));
      expect(r.service, 100);
    });

    test(
      'an unpriced item makes the bill partial; a courtesy is a known zero',
      () {
        final free = drink(id: 'c1', kind: PriceKind.complimentary);
        final unknown = drink(id: 'u1', kind: PriceKind.unknown);
        final doc = table();
        expect(TabCalculator.compute(doc, byId([free])).isPartial, isFalse);
        final r = TabCalculator.compute(doc, byId([free, unknown]));
        expect(r.isPartial, isTrue);
        expect(r.pendingCount, 1);
      },
    );

    test('a record of someone who is not on the tab stays unassigned', () {
      final stray = drink(id: 's1', consumerId: 'nobody', cents: 1000);
      final r = TabCalculator.compute(table(), byId([stray]));
      expect(r.shareOf(_me.id), 0);
      expect(r.shareOf(_ana.id), 0);
      expect(r.unassigned, 1000);
      expect(stray.isMine, isFalse);
    });
  });

  group('legacy tabs keep their behaviour', () {
    test('without autoLink only explicit links are on the tab and null = everybody', () {
      final a = drink(id: 'l1', cents: 1000);
      final b = drink(id: 'l2', cents: 2000);
      final doc = TabDoc(
        outingId: 'o1',
        participants: const [_me, _ana],
        links: [TabLink(entryId: a.id)],
        equalIds: const ['p-lucas', 'p-ana'],
        mode: SplitMode.item,
      );
      final r = TabCalculator.compute(doc, byId([a, b]));
      expect(r.subtotal, 1000);
      expect(r.shareOf(_me.id), 500);
      expect(r.shareOf(_ana.id), 500);
    });

    test('old JSON without the new keys reads as the owner\'s record', () {
      final e = drink(id: 'j1');
      final json = Map<String, dynamic>.from(e.toJson())
        ..remove('consumer_id')
        ..remove('portions');
      final back = DrinkEntry.fromJson(json);
      expect(back.consumerId, isNull);
      expect(back.portions, isNull);
      expect(back.isMine, isTrue);
    });

    test('attribution round-trips and an explicit null clears a guest', () {
      final ana = drink(id: 'j2', consumerId: _ana.id);
      final json = ana.toJson();
      expect(json['consumer_id'], _ana.id);
      final cleared = ana.copyWithAttribution(
        consumerId: null,
        portions: null,
        personalMl: ana.personalMl,
        peopleCount: 1,
        updatedAt: _t,
      );
      expect(cleared.toJson().containsKey('consumer_id'), isTrue);
      expect(cleared.toJson()['consumer_id'], isNull);
    });
  });

  group('repeat button targets the drink, not a later dish', () {
    test('rowOfEntry finds the drink row even when food is newer', () {
      final d = drink(id: 'rep1', name: 'Spritzgerald', consumerId: _ana.id);
      final dish = TabExtra(
        id: 'late-dish',
        description: 'Batata',
        category: ExtraCategory.food,
        createdAt: _t.add(const Duration(hours: 3)),
        priceKind: PriceKind.informed,
        cents: 6000,
        assign: {_me.id: 1, _ana.id: 1},
      );
      final doc = table(extras: [dish]);
      final rows = TableOrders.rows(doc, {d.id: d}, const PersonFilter.table());
      // The trap the button fell into: the newest row is the dish.
      expect(rows.first.extra, isNotNull);
      expect(rows.first.latest, isNull);
      final row = TableOrders.rowOfEntry(doc, d)!;
      expect(row.latest!.id, 'rep1');
      expect(row.extra, isNull);
    });
  });
}
