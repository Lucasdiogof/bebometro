import 'package:bebometro/core/sync/sync_cubit.dart';
import 'package:bebometro/drinks/data/drink_repository.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/outings/domain/outing_summary.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 10, 19, 22);
var _n = 0;

DrinkEntry e({
  String? consumer,
  Map<String, int?>? portions,
  bool shared = false,
  int cents = 1500,
  int? ml = 400,
  DrinkCategory category = DrinkCategory.draft,
}) {
  _n++;
  return DrinkEntry(
    id: 'x$_n',
    outingId: 'o1',
    consumedAt: _t.add(Duration(minutes: _n)),
    name: 'Chopp',
    category: category,
    createdAt: _t,
    updatedAt: _t,
    containerMl: ml,
    personalMl: ml,
    priceKind: PriceKind.informed,
    paidCents: cents,
    isShared: shared,
    consumerId: consumer,
    portions: portions,
  );
}

void main() {
  group('personal numbers never include a guest', () {
    test('summary counts only the owner by default', () {
      final list = [
        e(),
        e(),
        e(consumer: 'ana', cents: 3200),
        e(consumer: 'ana', cents: 3200),
      ];
      final mine = OutingSummary.of(list);
      expect(mine.entryCount, 2);
      expect(mine.personalMl, 800);
      expect(mine.informedCents, 3000);
      final table = OutingSummary.of(list, mineOnly: false);
      expect(table.entryCount, 4);
      expect(table.informedCents, 3000 + 6400);
    });

    test('a record with unknown consumer is not the owner\'s', () {
      // "nobody" is an id that is not the owner (null): never counted as mine.
      expect(e(consumer: 'nobody').isMine, isFalse);
    });

    test(
      'a shared bottle counts for the owner only when the owner is in it',
      () {
        final withMe = e(
          shared: true,
          portions: {ownerPortionKey: 400, 'ana': 200},
          ml: 600,
        );
        final withoutMe = e(
          shared: true,
          portions: {'ana': 300, 'bia': 300},
          ml: 600,
        );
        expect(withMe.isMine, isTrue);
        expect(withoutMe.isMine, isFalse);
        expect(OutingSummary.of([withMe, withoutMe]).entryCount, 1);
      },
    );

    test('legacy records (no consumer) are the owner\'s', () {
      expect(e().isMine, isTrue);
      expect(e(shared: true).isMine, isTrue);
    });
  });

  group('lock screen only repeats an individual order of the owner', () {
    test('individual owner order: yes; guest, shared bottle: no', () {
      expect(DrinkRepository.isPersonalIndividual(e()), isTrue);
      expect(DrinkRepository.isPersonalIndividual(e(consumer: 'ana')), isFalse);
      expect(
        DrinkRepository.isPersonalIndividual(
          e(shared: true, portions: {ownerPortionKey: 1, 'ana': 1}),
        ),
        isFalse,
      );
      expect(DrinkRepository.isPersonalIndividual(e(shared: true)), isFalse);
    });

    test(
      'repeating an order keeps the person: Mais uma para Ana stays Ana\'s',
      () {
        final ana = e(consumer: 'ana');
        final again = ana.repeated(newId: 'n', at: _t);
        expect(again.consumerId, 'ana');
        expect(again.isMine, isFalse);
      },
    );
  });

  group('sync never degrades an attributed record', () {
    test('a guest or portions make the record "attributed"', () {
      expect(SyncCubit.carriesAttribution(e(consumer: 'ana').toJson()), isTrue);
      expect(
        SyncCubit.carriesAttribution(
          e(shared: true, portions: {ownerPortionKey: 1, 'ana': 1}).toJson(),
        ),
        isTrue,
      );
      expect(SyncCubit.carriesAttribution(e().toJson()), isFalse);
    });

    test('an ordinary record of the owner has nothing else to lose', () {
      expect(SyncCubit.hasOtherOptionalColumns(e().toJson()), isFalse);
    });

    test('a record with a composition would lose it in a partial write', () {
      final json = e().toJson()..['composition'] = {'recipe_name': 'x'};
      expect(SyncCubit.hasOtherOptionalColumns(json), isTrue);
    });
  });
}
