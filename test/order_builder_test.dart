import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:bebometro/table/domain/order_builder.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 10, 19, 22);
const _lucas = 'p-lucas';
const _ana = 'p-ana';

OrderInput input({
  String name = 'Chopp',
  DrinkCategory category = DrinkCategory.draft,
  Map<String, int> units = const {_lucas: 1},
  PriceKind kind = PriceKind.informed,
  int? cents = 1500,
  PriceBasis basis = PriceBasis.unit,
  int? containerMl = 400,
  bool shared = false,
  Map<String, int?> portions = const {},
  int bottles = 1,
  int leftover = 0,
}) => OrderInput(
  outingId: 'o1',
  name: name,
  category: category,
  ownerId: _lucas,
  at: _t,
  units: units,
  priceKind: kind,
  priceCents: cents,
  basis: basis,
  containerMl: containerMl,
  shared: shared,
  portions: portions,
  bottles: bottles,
  leftoverMl: leftover,
);

var _n = 0;
String nextId() => 'id${_n++}';

void main() {
  setUp(() => _n = 0);

  test('4 chopps for Lucas: four records of the owner, R\$ 15 each', () {
    final list = OrderBuilder.build(input(units: {_lucas: 4}), newId: nextId);
    expect(list.length, 4);
    expect(list.map((e) => e.consumerId).toSet(), {null});
    expect(list.every((e) => e.isMine), isTrue);
    expect(list.map((e) => e.paidCents).toSet(), {1500});
    expect(list.map((e) => e.personalMl).toSet(), {400});
    expect(list.map((e) => e.id).toSet().length, 4);
    expect(list.every((e) => e.outingId == 'o1'), isTrue);
  });

  test('a free-name drink for Ana is saved without volume, ABV or recipe', () {
    final list = OrderBuilder.build(
      input(
        name: 'Spritzgerald',
        category: DrinkCategory.cocktail,
        units: {_ana: 2},
        cents: 3200,
        containerMl: null,
      ),
      newId: nextId,
    );
    expect(list.length, 2);
    expect(list.every((e) => e.consumerId == _ana), isTrue);
    expect(list.every((e) => !e.isMine), isTrue);
    expect(
      list.every((e) => e.containerMl == null && e.personalMl == null),
      isTrue,
    );
    expect(
      list.every((e) => e.abvPercent == null && e.composition == null),
      isTrue,
    );
    expect(list.map((e) => e.name).toSet(), {'Spritzgerald'});
    expect(list.map((e) => e.paidCents).toSet(), {3200});
  });

  test('units per person are explicit: Lucas 1 and Ana 2', () {
    final list = OrderBuilder.build(
      input(units: {_lucas: 1, _ana: 2}),
      newId: nextId,
    );
    expect(list.where((e) => e.isMine).length, 1);
    expect(list.where((e) => e.consumerId == _ana).length, 2);
  });

  test('the price of the whole order is spread in whole cents', () {
    final list = OrderBuilder.build(
      input(units: {_ana: 3}, basis: PriceBasis.total, cents: 10000),
      newId: nextId,
    );
    final prices = list.map((e) => e.paidCents!).toList();
    expect(prices.reduce((a, b) => a + b), 10000);
    expect(prices, [3334, 3333, 3333]);
  });

  test('a courtesy is zero and an unknown price stays unknown', () {
    final free = OrderBuilder.build(
      input(kind: PriceKind.complimentary, cents: null),
      newId: nextId,
    ).single;
    expect(free.priceKind, PriceKind.complimentary);
    expect(free.paidCents, 0);
    final unknown = OrderBuilder.build(
      input(kind: PriceKind.unknown, cents: null),
      newId: nextId,
    ).single;
    expect(unknown.priceKind, PriceKind.unknown);
    expect(unknown.paidCents, isNull);
  });

  group('shared bottle', () {
    OrderInput bottle({Map<String, int?>? portions, int? container = 600}) =>
        input(
          name: 'Brahma',
          category: DrinkCategory.beer,
          shared: true,
          portions: portions ?? {_lucas: 400, _ana: 200},
          containerMl: container,
          cents: 3000,
        );

    test('one record: portions 400/200, bottle R\$ 30, owner pays 15', () {
      final e = OrderBuilder.build(bottle(), newId: nextId).single;
      expect(e.isShared, isTrue);
      expect(e.portions, {ownerPortionKey: 400, _ana: 200});
      expect(e.billTotalCents, 3000);
      expect(e.paidCents, 1500);
      expect(e.personalMl, 400);
      expect(e.peopleCount, 2);
      expect(e.consumerId, isNull);
      expect(e.isMine, isTrue);
    });

    test('an unknown portion is kept unknown (never zero)', () {
      final e = OrderBuilder.build(
        bottle(portions: {_lucas: 400, _ana: null}),
        newId: nextId,
      ).single;
      expect(e.portions![_ana], isNull);
    });

    test('two bottles are two records', () {
      final list = OrderBuilder.build(
        input(
          shared: true,
          portions: {_lucas: 300, _ana: 300},
          containerMl: 600,
          bottles: 2,
        ),
        newId: nextId,
      );
      expect(list.length, 2);
      expect(list.map((e) => e.billTotalCents).toSet(), {1500});
    });

    test('portions plus leftover cannot exceed the bottle', () {
      final p = OrderBuilder.problems(
        bottle(portions: {_lucas: 400, _ana: 300}),
      );
      expect(p, contains(OrderProblem.portionsOverBottle));
      expect(
        () => OrderBuilder.build(
          bottle(portions: {_lucas: 400, _ana: 300}),
          newId: nextId,
        ),
        throwsArgumentError,
      );
    });

    test('"divide the volume equally" is an explicit estimate', () {
      expect(OrderBuilder.equalPortions([_lucas, _ana], 600, 0), {
        _lucas: 300,
        _ana: 300,
      });
      expect(OrderBuilder.equalPortions([_lucas, _ana], 600, 100), {
        _lucas: 250,
        _ana: 250,
      });
      expect(OrderBuilder.equalPortions([_lucas, _ana], null, 0), {
        _lucas: null,
        _ana: null,
      });
    });

    test('splitting the price in two does not claim each drank half', () {
      final e = OrderBuilder.build(
        bottle(portions: {_lucas: null, _ana: null}),
        newId: nextId,
      ).single;
      expect(e.paidCents, 1500);
      expect(e.portions!.values.every((v) => v == null), isTrue);
    });
  });

  test('problems: name, nobody, one sharer, missing price', () {
    expect(
      OrderBuilder.problems(input(name: ' ')),
      contains(OrderProblem.nameMissing),
    );
    expect(
      OrderBuilder.problems(input(units: const {})),
      contains(OrderProblem.nobodyPicked),
    );
    expect(
      OrderBuilder.problems(input(shared: true, portions: {_lucas: 100})),
      contains(OrderProblem.sharersNeeded),
    );
    expect(
      OrderBuilder.problems(input(cents: null)),
      contains(OrderProblem.priceMissing),
    );
    expect(OrderBuilder.problems(input()), isEmpty);
  });
}
