import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/bottle_people.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:flutter_test/flutter_test.dart';

BottlePeople _base() => BottlePeople.equal({
  ownerPortionKey: 300,
  'ana': 200,
  'bob': null,
}, leftoverMl: 50);

void main() {
  test('adding someone keeps everyone else\'s volume and starts unknown', () {
    final next = _base().add('cris');
    expect(next.portions, {
      ownerPortionKey: 300,
      'ana': 200,
      'bob': null,
      'cris': null,
    });
    expect(next.weightOf('cris'), 1);
    expect(next.leftoverMl, 50);
  });

  test('removing someone with volume or cost needs an explicit choice', () {
    final p = _base();
    expect(() => p.remove('ana'), throwsArgumentError);
    expect(
      () => p.remove('ana', volume: VolumeFate.toLeftover),
      throwsArgumentError,
    );
    expect(
      () => p.remove(
        'ana',
        volume: VolumeFate.toPerson,
        volumeTo: 'nobody',
        money: MoneyFate.spreadOnOthers,
      ),
      throwsArgumentError,
    );
  });

  test('volume to leftover keeps the known total', () {
    final p = _base();
    final next = p.remove(
      'ana',
      volume: VolumeFate.toLeftover,
      money: MoneyFate.spreadOnOthers,
    );
    expect(next.portions.containsKey('ana'), isFalse);
    expect(next.leftoverMl, 250);
    expect(next.knownMl + next.leftoverMl, p.knownMl + p.leftoverMl);
  });

  test('volume handed to a person with unknown volume becomes that amount', () {
    final next = _base().remove(
      'ana',
      volume: VolumeFate.toPerson,
      volumeTo: 'bob',
      money: MoneyFate.spreadOnOthers,
    );
    expect(next.portions['bob'], 200);
    expect(next.portions[ownerPortionKey], 300);
  });

  test('someone with unknown volume leaves without touching volumes', () {
    final next = _base().remove('bob', money: MoneyFate.spreadOnOthers);
    expect(next.portions, {ownerPortionKey: 300, 'ana': 200});
    expect(next.leftoverMl, 50);
  });

  test('cost handed over adds the weight; spreading drops it', () {
    final p = _base().withWeight('ana', 2);
    final given = p.remove(
      'ana',
      volume: VolumeFate.toLeftover,
      money: MoneyFate.toPerson,
      moneyTo: 'bob',
    );
    expect(given.weightOf('bob'), 3);
    final spread = p.remove(
      'ana',
      volume: VolumeFate.toLeftover,
      money: MoneyFate.spreadOnOthers,
    );
    expect(spread.weights, {ownerPortionKey: 1, 'bob': 1});
  });

  test('cost shares always add up to the bill', () {
    final p = _base().add('cris').withWeight('ana', 2);
    for (final total in [0, 1, 100, 6000, 6001]) {
      final shares = p.costShares(total);
      expect(shares.values.fold(0, (a, b) => a + b), total);
    }
  });

  test('a bottle keeps at least one person and someone who pays', () {
    final one = BottlePeople.equal({ownerPortionKey: null});
    expect(one.canRemoveAny, isFalse);
    expect(() => one.remove(ownerPortionKey), throwsArgumentError);
    final onePays = _base().withWeight(ownerPortionKey, 0).withWeight('bob', 0);
    expect(
      () => onePays.remove(
        'ana',
        volume: VolumeFate.toLeftover,
        money: MoneyFate.spreadOnOthers,
      ),
      throwsArgumentError,
    );
  });

  test('two people can become one: volume and cost handed over explicitly', () {
    final two = BottlePeople.equal({ownerPortionKey: 200, 'ana': 300}, leftoverMl: 100);
    expect(two.canRemoveAny, isTrue);
    expect(
      () => two.remove('ana', volume: VolumeFate.toLeftover),
      throwsArgumentError, // cost still unresolved
    );
    final one = two.remove(
      'ana',
      volume: VolumeFate.toPerson,
      volumeTo: ownerPortionKey,
      money: MoneyFate.toPerson,
      moneyTo: ownerPortionKey,
    );
    expect(one.portions, {ownerPortionKey: 500});
    expect(one.leftoverMl, 100); // leftover untouched, not turned into drinking
    expect(one.costShares(6000), {ownerPortionKey: 6000});
    expect(one.toLinkAssign('me-id'), isNull); // one payer = default split
    expect(one.canRemoveAny, isFalse);
  });

  test('known volume plus leftover cannot pass the bottle', () {
    final p = _base();
    expect(p.isOverBottle(550), isFalse);
    expect(p.isOverBottle(549), isTrue);
    expect(p.isOverBottle(null), isFalse);
    expect(p.add('cris').withPortion('cris', 100).isOverBottle(600), isTrue);
  });

  test('the link keeps "everyone equally" as null and explicit splits by id', () {
    expect(_base().toLinkAssign('me-id'), isNull);
    final p = _base().withWeight('ana', 2).withWeight('bob', 0);
    expect(p.toLinkAssign('me-id'), {'me-id': 1, 'ana': 2});
  });

  test('weights come back from the link, owner by participant id', () {
    final entry = DrinkEntry(
      id: 'b',
      outingId: 'o',
      consumedAt: DateTime.utc(2026),
      name: 'Vinho',
      category: DrinkCategory.wine,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      containerMl: 750,
      isShared: true,
      portions: {ownerPortionKey: 100, 'ana': 100},
    );
    final p = BottlePeople.fromEntry(
      entry,
      assign: {'me-id': 1, 'ana': 3},
      ownerId: 'me-id',
    );
    expect(p.weightOf(ownerPortionKey), 1);
    expect(p.weightOf('ana'), 3);
  });
}
