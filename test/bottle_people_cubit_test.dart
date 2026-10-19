import 'package:bebometro/core/data/local_store.dart';
import 'package:bebometro/drinks/data/drink_repository.dart';
import 'package:bebometro/drinks/domain/bottle_people.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/drinks/presentation/drink_form_cubit.dart';
import 'package:bebometro/outings/data/outing_repository.dart';
import 'package:bebometro/outings/domain/outing.dart';
import 'package:bebometro/places/domain/place_draft.dart';
import 'package:bebometro/tab/data/tab_repository.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _me = Participant(id: 'p-me', name: 'Você', isMe: true);
const _ana = Participant(id: 'p-ana', name: 'Ana');
const _bob = Participant(id: 'p-bob', name: 'Bob');

late DrinkRepository drinks;
late TabRepository tabs;
late Outing outing;
late DrinkEntry bottle;

DrinkEntry _bottle(Map<String, int?> portions, {int? personal, int paid = 3000}) {
  final t = DateTime.now().subtract(const Duration(hours: 1));
  return DrinkEntry(
    id: 'bottle-1',
    outingId: outing.id,
    consumedAt: t,
    name: 'Vinho',
    category: DrinkCategory.wine,
    createdAt: t,
    updatedAt: t,
    containerMl: 750,
    isShared: true,
    peopleCount: portions.length,
    personalMl: personal,
    priceKind: PriceKind.informed,
    paidCents: paid,
    billTotalCents: 6000,
    portions: portions,
  );
}

Future<void> _seed({List<Participant> people = const [_me, _ana, _bob]}) async {
  SharedPreferences.setMockInitialValues({});
  final store = await LocalStore.openAccount('u-bottle');
  drinks = DrinkRepository(store, const []);
  tabs = TabRepository(store, drinks);
  outing = await OutingRepository(store).start(
    type: OutingType.bar,
    place: const PlaceSnapshot(nickname: 'Bar'),
    startedAt: DateTime.now().subtract(const Duration(hours: 2)),
  );
  bottle = _bottle({ownerPortionKey: 200, 'p-ana': 300}, personal: 200);
  await drinks.save(bottle);
  await tabs.update(outing.id, (_) {
    return TabDoc.forTable(outing.id, _me).copyWith(
      participants: people,
      payments: [
        TabPayment(
          id: 'pay1',
          participantId: 'p-ana',
          cents: 6000,
          at: DateTime.now(),
        ),
      ],
    );
  });
}

DrinkFormCubit _open() =>
    DrinkFormCubit.forEntry(drinks, outing, bottle, const [], tabs: tabs);

void main() {
  test('adding a guest keeps volumes, id and payments; one record only', () async {
    await _seed();
    final c = _open();
    expect(c.candidatesToAdd, ['p-bob']);
    c.addPerson('p-bob');
    expect(c.state.draft.portions, {ownerPortionKey: 200, 'p-ana': 300, 'p-bob': null});
    expect(c.peopleChanged, isTrue);
    final rows = c.impact()!;
    expect(rows.firstWhere((r) => r.key == 'p-bob').isIn, isTrue);
    await c.submit();
    expect(c.state.saved, isTrue);
    final saved = drinks.entryById('bottle-1')!;
    expect(saved.portions, {ownerPortionKey: 200, 'p-ana': 300, 'p-bob': null});
    expect(saved.createdAt, bottle.createdAt);
    expect(saved.billTotalCents, 6000);
    expect(drinks.entriesFor(outing.id).where((e) => e.name == 'Vinho'), hasLength(1));
    expect(tabs.load(outing.id).payments.single.cents, 6000);
    // cost now split in three, default equal
    expect(tabs.compute(outing.id).shareOf('p-bob'), 2000);
    expect(saved.paidCents, 2000);
  });

  test('a person of another outing is refused', () async {
    await _seed();
    final c = _open();
    c.addPerson('p-ghost');
    expect(c.state.draft.portions!.containsKey('p-ghost'), isFalse);
  });

  test('removing with volume and cost needs a choice, then keeps the total', () async {
    await _seed();
    final c = _open();
    expect(() => c.removePerson('p-ana'), throwsArgumentError);
    c.addPerson('p-bob');
    c.removePerson(
      'p-ana',
      volume: VolumeFate.toPerson,
      volumeTo: 'p-bob',
      money: MoneyFate.toPerson,
      moneyTo: 'p-bob',
    );
    await c.submit();
    final saved = drinks.entryById('bottle-1')!;
    expect(saved.portions, {ownerPortionKey: 200, 'p-bob': 300});
    final r = tabs.compute(outing.id);
    expect(r.shareOf('p-me') + r.shareOf('p-bob') + r.shareOf('p-ana'), 6000);
    expect(r.shareOf('p-bob'), 4000);
    expect(r.shareOf('p-ana'), 0);
    expect(tabs.load(outing.id).payments.single.participantId, 'p-ana');
  });

  test('a bottle drunk only by guests stays editable', () async {
    await _seed();
    final guests = _bottle({'p-ana': 300, 'p-bob': 100}, paid: 0);
    await drinks.save(guests);
    bottle = guests;
    final c = _open();
    expect(c.state.draft.isValid, isTrue);
    c.setPortion('p-bob', 150);
    await c.submit();
    expect(drinks.entryById('bottle-1')!.portions!['p-bob'], 150);
  });

  test('Você and Ana become Você alone: same record, total, leftover and payment', () async {
    await _seed();
    final withLeftover = _bottle({ownerPortionKey: 200, 'p-ana': 300}, personal: 200);
    await drinks.save(withLeftover);
    final c = _open();
    expect(c.state.draft.leftoverMl, 0);
    c.setLeftoverMl(100);
    c.removePerson(
      'p-ana',
      volume: VolumeFate.toPerson,
      volumeTo: ownerPortionKey,
      money: MoneyFate.toPerson,
      moneyTo: ownerPortionKey,
    );
    await c.submit();
    expect(c.state.saved, isTrue);
    final saved = drinks.entryById('bottle-1')!;
    expect(saved.portions, {ownerPortionKey: 500});
    expect(saved.peopleCount, 1);
    expect(saved.isShared, isTrue);
    expect(saved.leftoverMl, 100);
    expect(saved.billTotalCents, 6000);
    expect(saved.containerMl, 750);
    expect(saved.paidCents, 6000);
    expect(drinks.entriesFor(outing.id).where((e) => e.name == 'Vinho'), hasLength(1));
    final r = tabs.compute(outing.id);
    expect(r.shareOf('p-me'), 6000);
    expect(r.shareOf('p-ana'), 0);
    expect(tabs.load(outing.id).payments.single.participantId, 'p-ana');
  });

  test('saving is blocked while a priced bottle has nobody to pay', () async {
    await _seed();
    final c = _open();
    c.setWeight(ownerPortionKey, 0);
    c.setWeight('p-ana', 0);
    await c.submit();
    expect(c.state.saved, isFalse);
    expect(drinks.entryById('bottle-1')!.portions!.length, 2);
  });
}
