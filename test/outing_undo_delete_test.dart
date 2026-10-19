import 'package:bebometro/core/data/local_store.dart';
import 'package:bebometro/drinks/data/drink_repository.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/outings/data/outing_deletion.dart';
import 'package:bebometro/outings/data/outing_repository.dart';
import 'package:bebometro/outings/domain/outing.dart';
import 'package:bebometro/places/domain/place_draft.dart';
import 'package:bebometro/tab/data/tab_repository.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

late OutingRepository outings;
late DrinkRepository drinks;
late TabRepository tabs;
late OutingDeletion deletion;

Future<Outing> _start(String name, {Duration ago = const Duration(hours: 2)}) =>
    outings.start(
      type: OutingType.bar,
      place: PlaceSnapshot(nickname: name),
      startedAt: DateTime.now().subtract(ago),
    );

Future<void> _drink(String id, String outingId, int minutesAgo) =>
    drinks.save(
      DrinkEntry(
        id: id,
        outingId: outingId,
        consumedAt: DateTime.now().subtract(Duration(minutes: minutesAgo)),
        name: 'Chope',
        category: DrinkCategory.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        containerMl: 400,
        personalMl: 400,
        priceKind: PriceKind.informed,
        paidCents: 1500,
      ),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.openAccount('u-undo');
    outings = OutingRepository(store);
    drinks = DrinkRepository(store, const []);
    tabs = TabRepository(store, drinks);
    deletion = OutingDeletion(outings, drinks);
  });

  test('undo brings back the same outing and only what this delete removed', () async {
    final o = await _start('Bar do Zé');
    await _drink('a', o.id, 30);
    await _drink('b', o.id, 20);
    await _drink('old', o.id, 10);
    await drinks.delete('old'); // deleted BEFORE, must stay deleted
    await tabs.update(
      o.id,
      (_) => TabDoc.forTable(
        o.id,
        const Participant(id: 'me', name: 'Você', isMe: true),
      ).copyWith(
        payments: [
          TabPayment(id: 'p', participantId: 'me', cents: 1000, at: DateTime.now()),
        ],
      ),
    );

    final d = (await deletion.delete(o.id))!;
    expect(d.entryIds.toSet(), {'a', 'b'});
    expect(outings.byId(o.id), isNull);
    expect(drinks.entriesFor(o.id), isEmpty);

    expect(await deletion.restore(d), RestoreOutcome.restored);
    expect(outings.byId(o.id)!.id, o.id);
    expect(outings.all(), hasLength(1));
    expect(drinks.entriesFor(o.id).map((e) => e.id), ['a', 'b']);
    expect(drinks.entryById('old')!.isDeleted, isTrue);
    expect(tabs.load(o.id).payments.single.cents, 1000);
  });

  test('a repeated or late undo changes nothing', () async {
    final o = await _start('Bar');
    await _drink('a', o.id, 30);
    final d = (await deletion.delete(o.id))!;
    expect(await deletion.restore(d), RestoreOutcome.restored);
    expect(await deletion.restore(d), RestoreOutcome.nothingToRestore);
    // the person deletes one drink on purpose; the old undo must not bring it back
    await drinks.delete('a');
    expect(await deletion.restore(d), RestoreOutcome.nothingToRestore);
    expect(drinks.entriesFor(o.id), isEmpty);
  });

  test('an old undo does not revive a later, separate deletion', () async {
    final o = await _start('Bar');
    await _drink('a', o.id, 30);
    final first = (await deletion.delete(o.id))!;
    await deletion.restore(first);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await deletion.delete(o.id);
    expect(await deletion.restore(first), RestoreOutcome.nothingToRestore);
    expect(outings.byId(o.id), isNull);
    expect(drinks.entriesFor(o.id), isEmpty);
  });

  test('a running outing is never ended by a restore: needs an explicit choice', () async {
    final o = await _start('Primeiro');
    await _drink('a', o.id, 30);
    final d = (await deletion.delete(o.id))!;
    expect(d.wasActive, isTrue);
    final other = await _start('Segundo', ago: const Duration(minutes: 20));

    expect(deletion.needsChoice(d), isTrue);
    expect(await deletion.restore(d), RestoreOutcome.needsChoice);
    expect(outings.byId(o.id), isNull); // nothing touched
    expect(outings.active!.id, other.id);

    expect(await deletion.restore(d, asEnded: true), RestoreOutcome.restoredEnded);
    final back = outings.byId(o.id)!;
    expect(back.isActive, isFalse);
    expect(back.endedAt!.difference(d.at).inSeconds, 0);
    expect(outings.active!.id, other.id);
    expect(outings.byId(other.id)!.isActive, isTrue);
    expect(drinks.entriesFor(o.id), hasLength(1));
  });

  test('without another running outing the running one comes back running', () async {
    final o = await _start('Bar');
    final d = (await deletion.delete(o.id))!;
    expect(deletion.needsChoice(d), isFalse);
    expect(await deletion.restore(d), RestoreOutcome.restored);
    expect(outings.active!.id, o.id);
  });

  test('a finished outing comes back finished with the same end', () async {
    final o = await _start('Bar');
    final end = o.startedAt.add(const Duration(hours: 1));
    await outings.finish(o.id, end);
    await _start('Outro', ago: const Duration(minutes: 5));
    final d = (await deletion.delete(o.id))!;
    expect(deletion.needsChoice(d), isFalse);
    expect(await deletion.restore(d), RestoreOutcome.restored);
    expect(outings.byId(o.id)!.endedAt!.difference(end).inSeconds, 0);
  });
}
