import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:bebometro/table/domain/order_builder.dart';
import 'package:bebometro/table/domain/table_orders.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 10, 19, 22);
const _lucas = 'p-lucas';
const _ana = 'p-ana';
const _joao = 'p-joao';

const _doc = TabDoc(
  outingId: 'o1',
  participants: [
    Participant(id: _lucas, name: 'Você', isMe: true),
    Participant(id: _ana, name: 'Ana'),
    Participant(id: _joao, name: 'João'),
  ],
  mode: SplitMode.item,
  autoLink: true,
);

OrderInput input({
  String name = 'Chopp',
  OrderKind kind = OrderKind.alcoholic,
  int quantity = 1,
  List<String> consumers = const [_lucas],
  Map<String, int>? units,
  List<String> payers = const [_lucas],
  Map<String, int>? payerCents,
  PriceKind priceKind = PriceKind.informed,
  int? cents = 1500,
  PriceBasis basis = PriceBasis.unit,
  DrinkEntry? template,
  List<DrinkEntry> existing = const [],
  TabExtra? existingExtra,
}) => OrderInput(
  outingId: 'o1',
  name: name,
  kind: kind,
  ownerId: _lucas,
  at: _t,
  quantity: quantity,
  consumers: consumers,
  units: units,
  payers: payers,
  payerCents: payerCents,
  priceKind: priceKind,
  priceCents: cents,
  basis: basis,
  template: template,
  existing: existing,
  existingExtra: existingExtra,
);

var _n = 0;
String nextId() => 'id${_n++}';

List<DrinkEntry> drinks(OrderInput i) =>
    OrderBuilder.build(i, newId: nextId).entries;

TabResult tab(List<DrinkEntry> entries, [TabDoc doc = _doc]) =>
    TabCalculator.compute(doc, {for (final e in entries) e.id: e});

void main() {
  setUp(() => _n = 0);

  group('quem consumiu ≠ quem paga', () {
    test('Heineken 600 for Você and Ana, paid by Você: one shared order', () {
      final list = drinks(
        input(
          name: 'Heineken 600',
          consumers: const [_lucas, _ana],
          payers: const [_lucas],
          cents: 2000,
        ),
      );
      expect(list, hasLength(1));
      final e = list.single;
      expect(e.isShared, isTrue);
      expect(e.portions, {ownerPortionKey: null, _ana: null});
      expect(e.billTotalCents, 2000);
      expect(e.payers, {ownerPortionKey: 1});
      expect(e.ownerCostCents, 2000);
      expect(e.paidCents, 2000);
      final r = tab(list);
      expect(r.total, 2000); // the table pays it once
      expect(r.shareOf(_lucas), 2000);
      expect(r.shareOf(_ana), 0);
      // both took part
      final rows = TableOrders.rows(_doc, {
        e.id: e,
      }, const PersonFilter.table());
      expect(rows.single.shared, isTrue);
      expect(rows.single.consumerIds.toSet(), {_lucas, _ana});
      expect(rows.single.payerIds, [_lucas]);
      expect(rows.single.payersDiffer, isTrue);
    });

    test('Batata R\$ 60 for three, paid by two: R\$ 30 each, third pays 0', () {
      final x = OrderBuilder.build(
        input(
          name: 'Batata',
          kind: OrderKind.food,
          consumers: const [_lucas, _ana, _joao],
          payers: const [_lucas, _joao],
          cents: 6000,
        ),
        newId: nextId,
      ).extra!;
      expect(x.consumers, [_lucas, _ana, _joao]);
      expect(x.assign, {_lucas: 1, _joao: 1});
      final r = TabCalculator.compute(_doc.copyWith(extras: [x]), const {});
      expect(r.shareOf(_lucas), 3000);
      expect(r.shareOf(_joao), 3000);
      expect(r.shareOf(_ana), 0);
      expect(r.total, 6000);
    });

    test("Ana's drink paid by Você costs Você, not Ana", () {
      final list = drinks(
        input(
          name: 'Gin tônica',
          consumers: const [_ana],
          payers: const [_lucas],
          cents: 3200,
        ),
      );
      final e = list.single;
      expect(e.consumerId, _ana);
      expect(e.isMine, isFalse);
      expect(e.ownerCostCents, 3200);
      final r = tab(list);
      expect(r.shareOf(_lucas), 3200);
      expect(r.shareOf(_ana), 0);
    });

    test('changing who consumed never changes who pays, and the reverse', () {
      OrderInput of(List<String> c, List<String> p) =>
          input(consumers: c, payers: p, quantity: 2, cents: 1000);
      final a = drinks(of(const [_lucas, _ana], const [_joao]));
      final b = drinks(of(const [_lucas], const [_joao]));
      expect(a.map((e) => e.payers).toSet(), b.map((e) => e.payers).toSet());
      final c = drinks(of(const [_lucas, _ana], const [_lucas, _ana]));
      for (final e in [...a, ...c]) {
        expect(e.portions!.keys, unorderedEquals([ownerPortionKey, _ana]));
      }
      expect(c.first.payers, {ownerPortionKey: 1, _ana: 1});
    });

    test('no price: payers are kept and the amount is pending', () {
      final list = drinks(
        input(
          consumers: const [_lucas, _ana],
          payers: const [_lucas, _ana],
          priceKind: PriceKind.unknown,
          cents: null,
        ),
      );
      final e = list.single;
      expect(e.payers, {ownerPortionKey: 1, _ana: 1});
      expect(e.ownerCostCents, isNull);
      final r = tab(list);
      expect(r.isPartial, isTrue);
      expect(r.total, 0);
    });

    test('a courtesy is zero, not unknown, and keeps its payers', () {
      final e = drinks(input(priceKind: PriceKind.complimentary, cents: null))
          .single;
      expect(e.priceKind, PriceKind.complimentary);
      expect(e.paidCents, 0);
      expect(e.payers, {ownerPortionKey: 1});
      expect(tab([e]).isPartial, isFalse);
    });
  });

  group('divisão do custo em centavos', () {
    test('equal split between payers adds up to the cent', () {
      final list = drinks(
        input(
          consumers: const [_lucas],
          payers: const [_lucas, _ana, _joao],
          cents: 10000,
        ),
      );
      final r = tab(list);
      expect(r.shareOf(_lucas) + r.shareOf(_ana) + r.shareOf(_joao), 10000);
      expect(r.shareOf(_lucas), 3334);
    });

    test('typed amounts must add up to the total', () {
      final bad = input(
        payers: const [_lucas, _ana],
        payerCents: const {_lucas: 600, _ana: 500},
        cents: 2000,
      );
      expect(OrderBuilder.problems(bad), contains(OrderProblem.payersSum));
      expect(() => drinks(bad), throwsArgumentError);
    });

    test('typed amounts are exact even over several units', () {
      // 3 units of R$ 33,33 (total 99,99): Você 66,66 and Ana 33,33.
      final list = drinks(
        input(
          quantity: 3,
          consumers: const [_lucas, _ana],
          payers: const [_lucas, _ana],
          payerCents: const {_lucas: 6666, _ana: 3333},
          cents: 3333,
        ),
      );
      expect(list, hasLength(3));
      final r = tab(list);
      expect(r.total, 9999);
      expect(r.shareOf(_lucas), 6666);
      expect(r.shareOf(_ana), 3333);
    });

    test('the total price of the order is spread in whole cents', () {
      final list = drinks(
        input(
          quantity: 3,
          consumers: const [_ana],
          basis: PriceBasis.total,
          cents: 10000,
        ),
      );
      expect(list.map((e) => e.paidCents!).toList(), [3334, 3333, 3333]);
    });
  });

  group('quantidades', () {
    test('4 chopps for one person are four individual records', () {
      final list = drinks(input(quantity: 4));
      expect(list, hasLength(4));
      expect(list.every((e) => e.isMine && !e.isShared), isTrue);
      expect(list.map((e) => e.id).toSet(), hasLength(4));
      expect(tab(list).total, 6000);
    });

    test(
      'shared units without distribution are shared orders, not units each',
      () {
        final list = drinks(
          input(quantity: 2, consumers: const [_lucas, _ana], cents: 1000),
        );
        expect(list, hasLength(2));
        expect(list.every((e) => e.isShared), isTrue);
        expect(list.every((e) => e.personalMl == null), isTrue);
        expect(tab(list).total, 2000); // each counted once
      },
    );

    test('units per person make individual records', () {
      final list = drinks(
        input(
          quantity: 3,
          consumers: const [_lucas, _ana],
          units: const {_lucas: 2, _ana: 1},
        ),
      );
      expect(list.where((e) => e.isMine), hasLength(2));
      expect(list.where((e) => e.consumerId == _ana), hasLength(1));
      expect(list.any((e) => e.isShared), isFalse);
    });

    test('units per person must add up to the quantity', () {
      final p = OrderBuilder.problems(
        input(
          quantity: 3,
          consumers: const [_lucas, _ana],
          units: const {_lucas: 1, _ana: 1},
        ),
      );
      expect(p, contains(OrderProblem.unitsMismatch));
    });

    test('no volume, ABV or recipe is created for a free-name drink', () {
      final e = drinks(input(name: 'Spritzgerald', cents: 3200)).single;
      expect(
        e.containerMl == null &&
            e.personalMl == null &&
            e.abvPercent == null &&
            e.composition == null,
        isTrue,
      );
    });
  });

  group('validação', () {
    test('needs a name, a consumer and a payer', () {
      final p = OrderBuilder.problems(
        input(name: ' ', consumers: const [], payers: const []),
      );
      expect(
        p,
        containsAll(<OrderProblem>[
          OrderProblem.nameMissing,
          OrderProblem.nobodyConsumed,
          OrderProblem.nobodyPays,
        ]),
      );
    });

    test('an informed price needs the amount', () {
      final p = OrderBuilder.problems(input(cents: null));
      expect(p, contains(OrderProblem.priceMissing));
    });

    test('soft drinks are not alcoholic', () {
      final e = drinks(input(name: 'Guaraná', kind: OrderKind.soft)).single;
      expect(e.isAlcoholic, isFalse);
      final w = drinks(input(name: 'Vinho')).single;
      expect(w.isAlcoholic, isTrue);
    });
  });

  group('correção', () {
    test('keeps ids, times and origin; drops only the surplus', () {
      final origin = EntryOrigin.lockScreen(commandId: 'c', tappedAt: _t);
      final first = drinks(input(quantity: 3, consumers: const [_ana]));
      final withOrigin = [
        first[0],
        first[1],
        DrinkEntry.fromJson({...first[2].toJson(), ...origin.toJson()}),
      ];
      final again = drinks(
        input(
          quantity: 2,
          consumers: const [_ana],
          existing: withOrigin,
          cents: 1800,
        ),
      );
      expect(again.map((e) => e.id), [first[0].id, first[1].id]);
      expect(again.map((e) => e.consumedAt), [
        first[0].consumedAt,
        first[1].consumedAt,
      ]);
      final third = drinks(
        input(quantity: 3, consumers: const [_ana], existing: withOrigin),
      );
      expect(third[2].entryOrigin?.commandId, 'c');
    });

    test('an old record without payers is edited without losing its data', () {
      final legacy = DrinkEntry(
        id: 'old',
        outingId: 'o1',
        consumedAt: _t,
        name: 'Caipirinha',
        category: DrinkCategory.cocktail,
        createdAt: _t,
        updatedAt: _t,
        abvPercent: 40,
        ingredients: const ['cachaça'],
        priceKind: PriceKind.informed,
        paidCents: 2500,
      );
      final out = drinks(
        input(
          name: 'Caipirinha',
          template: legacy,
          existing: [legacy],
          cents: 2800,
        ),
      ).single;
      expect(out.id, 'old');
      expect(out.abvPercent, 40);
      expect(out.ingredients, ['cachaça']);
      expect(out.paidCents, 2800);
      // another name drops the old technical data
      final renamed = drinks(
        input(name: 'Outra', template: legacy, existing: [legacy]),
      ).single;
      expect(renamed.abvPercent, isNull);
    });

    test('payments stay and the balance follows the new payers', () {
      final before = drinks(
        input(
          consumers: const [_lucas, _ana],
          payers: const [_lucas],
          cents: 2000,
        ),
      );
      final doc = _doc.copyWith(
        payments: [
          TabPayment(id: 'p1', participantId: _lucas, cents: 500, at: _t),
        ],
      );
      expect(tab(before, doc).balanceOf(_lucas), 1500);
      final after = drinks(
        input(
          consumers: const [_lucas, _ana],
          payers: const [_lucas, _ana],
          cents: 2000,
          existing: before,
        ),
      );
      final r = tab(after, doc);
      expect(r.paidBy(_lucas), 500); // payment kept
      expect(r.balanceOf(_lucas), 500);
      expect(r.balanceOf(_ana), 1000);
    });
  });

  group('dados antigos', () {
    DrinkEntry old({String? consumer, Map<String, int?>? portions}) =>
        DrinkEntry(
          id: 'e',
          outingId: 'o1',
          consumedAt: _t,
          name: 'Chopp',
          category: DrinkCategory.draft,
          createdAt: _t,
          updatedAt: _t,
          priceKind: PriceKind.informed,
          paidCents: 1500,
          consumerId: consumer,
          portions: portions,
        );

    test('without payers the cost still follows who drank it', () {
      final e = old(consumer: _ana);
      expect(e.payers, isNull);
      final r = tab([e]);
      expect(r.shareOf(_ana), 1500);
      expect(r.shareOf(_lucas), 0);
      expect(e.ownerCostCents, 0); // not the owner's drink
      expect(old().ownerCostCents, 1500);
    });

    test('payers survive a JSON round trip and are absent when unset', () {
      expect(old().toJson().containsKey('payers'), isFalse);
      final e = drinks(input(payers: const [_lucas, _ana])).single;
      expect(DrinkEntry.fromJson(e.toJson()).payers, e.payers);
    });

    test('a tab extra without consumers keeps who it was split among', () {
      final x = TabExtra(
        id: 'x',
        description: 'Porção',
        category: ExtraCategory.food,
        createdAt: _t,
        priceKind: PriceKind.informed,
        cents: 3000,
        assign: const {_lucas: 1, _ana: 1},
      );
      final back = TabExtra.fromJson(x.toJson());
      expect(back.consumers, isNull);
      final rows = TableOrders.rows(
        _doc.copyWith(extras: [back]),
        const {},
        const PersonFilter.table(),
      );
      expect(rows.single.consumerIds, [_lucas, _ana]);
    });
  });

  group('repetir', () {
    test('repeating keeps consumers, payers, price and a new id', () {
      final src = drinks(
        input(
          consumers: const [_lucas, _ana],
          payers: const [_lucas],
          cents: 2000,
        ),
      ).single;
      final copy = src.repeated(
        newId: 'again',
        at: _t.add(const Duration(minutes: 5)),
      );
      expect(copy.id, 'again');
      expect(copy.payers, src.payers);
      expect(copy.portions, src.portions);
      expect(copy.billTotalCents, 2000);
      expect(copy.entryOrigin, isNull);
    });
  });
}
