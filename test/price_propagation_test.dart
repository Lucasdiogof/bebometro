import 'package:bebometro/core/data/local_store.dart';
import 'package:bebometro/drinks/data/drink_repository.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _t = DateTime.utc(2026, 10, 16, 21);

DrinkEntry drink(
  String id,
  String name, {
  int? paid,
  int ml = 400,
  String outing = 'o1',
  bool shared = false,
  int people = 1,
  int? personal,
}) =>
    DrinkEntry(
      id: id,
      outingId: outing,
      consumedAt: _t,
      name: name,
      category: DrinkCategory.draft,
      presentation: 'Copo $ml ml',
      containerMl: ml,
      personalMl: personal ?? ml,
      abvPercent: 4.8,
      isShared: shared,
      peopleCount: people,
      priceKind: paid == null ? PriceKind.unknown : PriceKind.informed,
      paidCents: paid,
      createdAt: _t,
      updatedAt: _t,
    );

void main() {
  late DrinkRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = DrinkRepository(await LocalStore.openAccount('qa'), const []);
  });

  Future<void> seed() async {
    await repo.save(drink('a', 'Chopp', paid: 1500));
    await repo.save(drink('b', 'Chopp')); // same drink, no price
    await repo.save(drink('c', 'Chopp')); // same drink, no price
    await repo.save(drink('d', 'Chopp', paid: 1800)); // same, other price
    await repo.save(drink('e', 'Pilsen')); // different drink
    await repo.save(drink('f', 'Chopp', ml: 300)); // different size
    await repo.save(drink('g', 'Chopp', outing: 'o2')); // other outing
  }

  test('equivalents are the same drink, size and outing only', () async {
    await seed();
    final ids =
        repo.equivalentsOf(repo.entryById('a')!).map((e) => e.id).toSet();
    expect(ids, {'b', 'c', 'd'});
  });

  test('applying the price to equivalents without price leaves the rest',
      () async {
    await seed();
    await repo.applyPrices({
      'b': (kind: PriceKind.informed, paidCents: 1500),
      'c': (kind: PriceKind.informed, paidCents: 1500),
    });
    expect(repo.entryById('b')!.paidCents, 1500);
    expect(repo.entryById('c')!.paidCents, 1500);
    expect(repo.entryById('d')!.paidCents, 1800, reason: 'had another price');
    expect(repo.entryById('e')!.paidCents, isNull, reason: 'other drink');
    expect(repo.entryById('f')!.paidCents, isNull, reason: 'other size');
    expect(repo.entryById('g')!.paidCents, isNull, reason: 'other outing');
  });

  test('applying to all equivalents replaces the other price too', () async {
    await seed();
    await repo.applyPrices({
      'b': (kind: PriceKind.informed, paidCents: 1500),
      'c': (kind: PriceKind.informed, paidCents: 1500),
      'd': (kind: PriceKind.informed, paidCents: 1500),
    });
    expect(repo.entryById('d')!.paidCents, 1500);
    expect(repo.entryById('e')!.paidCents, isNull);
    // Only the payment changes: volume and consumption stay.
    expect(repo.entryById('d')!.containerMl, 400);
    expect(repo.entryById('d')!.personalMl, 400);
  });

  test('a shared bottle keeps the price paid separate from the personal ml',
      () async {
    await repo.save(
        drink('s', 'Cerveja 600', ml: 600, shared: true, people: 3, personal: 200, paid: 1000));
    final e = repo.entryById('s')!;
    expect(e.personalMl, 200);
    expect(e.containerMl, 600);
    expect(e.paidCents, 1000);
    // Re-pricing never touches the portion.
    await repo.applyPrices({'s': (kind: PriceKind.informed, paidCents: 1200)});
    final after = repo.entryById('s')!;
    expect(after.paidCents, 1200);
    expect(after.personalMl, 200);
  });

  test('complimentary and unknown prices are not the same as zero', () async {
    await repo.save(drink('u', 'Chopp'));
    await repo.applyPrices({'u': (kind: PriceKind.complimentary, paidCents: null)});
    expect(repo.entryById('u')!.priceKind, PriceKind.complimentary);
    expect(repo.entryById('u')!.paidCents, 0);
    await repo.applyPrices({'u': (kind: PriceKind.unknown, paidCents: null)});
    expect(repo.entryById('u')!.paidCents, isNull);
  });

  test('a deleted record is not touched by a price update', () async {
    await repo.save(drink('x', 'Chopp'));
    await repo.delete('x');
    await repo.applyPrices({'x': (kind: PriceKind.informed, paidCents: 999)});
    expect(repo.entryById('x')!.isDeleted, isTrue);
    expect(repo.entryById('x')!.paidCents, isNull);
  });
}
