import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_draft.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:flutter_test/flutter_test.dart';

final _tap = DateTime.utc(2026, 10, 16, 22, 30);
final _later = DateTime.utc(2026, 10, 16, 23, 10);

DrinkEntry source({EntryOrigin? origin}) => DrinkEntry(
  id: 'src',
  outingId: 'o1',
  consumedAt: DateTime.utc(2026, 10, 16, 21),
  name: 'Chopp',
  category: DrinkCategory.draft,
  presentation: 'Copo 400 ml',
  containerMl: 400,
  personalMl: 400,
  abvPercent: 4.8,
  priceKind: PriceKind.informed,
  paidCents: 1500,
  createdAt: DateTime.utc(2026, 10, 16, 21),
  updatedAt: DateTime.utc(2026, 10, 16, 21),
  entryOrigin: origin,
);

EntryOrigin lock(String id) =>
    EntryOrigin.lockScreen(commandId: id, tappedAt: _tap);

void main() {
  group('EntryOrigin', () {
    test('round-trips through the stored JSON', () {
      final e = source().repeated(newId: 'n', at: _tap, origin: lock('cmd-1'));
      final back = DrinkEntry.fromJson(e.toJson());
      expect(back.entryOrigin, isNotNull);
      expect(back.entryOrigin!.isLockScreen, isTrue);
      expect(back.entryOrigin!.commandId, 'cmd-1');
      expect(back.entryOrigin!.tappedAt.toUtc(), _tap);
    });

    test('older and manual records have no origin and no origin keys', () {
      final json = source().toJson();
      expect(json.containsKey('entry_origin'), isFalse);
      expect(json.containsKey('origin_command_id'), isFalse);
      expect(DrinkEntry.fromJson(json).entryOrigin, isNull);
    });

    test('a partial origin is ignored, never completed with guesses', () {
      final json = source().toJson()..['entry_origin'] = 'lock_screen';
      expect(DrinkEntry.fromJson(json).entryOrigin, isNull);
    });
  });

  group('repeating a drink', () {
    test('keeps composition, portion and price at the tap time', () {
      final r = source().repeated(newId: 'n', at: _tap, origin: lock('c'));
      expect(r.id, 'n');
      expect(r.consumedAt, _tap);
      expect(r.paidCents, 1500);
      expect(r.personalMl, 400);
      expect(r.abvPercent, 4.8);
      expect(r.outingId, 'o1');
    });

    test('never inherits the source origin: a repeat in the app has none', () {
      final fromLock = source(origin: lock('old'));
      final again = fromLock.repeated(newId: 'n2', at: _later);
      expect(again.entryOrigin, isNull);
    });

    test('a new lock-screen action carries only its own command', () {
      final fromLock = source(origin: lock('old'));
      final again = fromLock.repeated(
        newId: 'n2',
        at: _later,
        origin: lock('new'),
      );
      expect(again.entryOrigin!.commandId, 'new');
    });
  });

  group('corrections keep the origin', () {
    final base = source().repeated(newId: 'n', at: _tap, origin: lock('c'));

    test('price', () {
      final e = base.copyWithPrice(
        kind: PriceKind.informed,
        paidCents: 2000,
        updatedAt: _later,
      );
      expect(e.entryOrigin!.commandId, 'c');
      expect(e.paidCents, 2000);
    });

    test('bill total, delete and restore', () {
      expect(
        base
            .copyWithBillTotal(billTotalCents: 5000, updatedAt: _later)
            .entryOrigin,
        isNotNull,
      );
      final del = base.copyWith(deletedAt: _later);
      expect(del.entryOrigin!.commandId, 'c');
      expect(del.copyWith(clearDeleted: true).entryOrigin!.commandId, 'c');
    });

    test('editing the time never changes the original tap time', () {
      final draft = DrinkDraft.fromEntry(base);
      final entry = draft.toEntry(id: 'x', outingId: 'o1', now: _later);
      expect(entry.entryOrigin!.tappedAt.toUtc(), _tap);
      final moved = DrinkEntry.fromJson({
        ...entry.toJson(),
        'consumed_at': _later.toIso8601String(),
      });
      expect(moved.entryOrigin!.tappedAt.toUtc(), _tap);
      expect(moved.timeCorrected, isTrue);
      expect(base.timeCorrected, isFalse);
    });
  });

  group('review draft', () {
    test('is a NEW record with only the command origin', () {
      final template = source(origin: lock('someone-else'));
      final draft = DrinkDraft.fromEntry(
        template,
        asNew: true,
        consumedAt: _tap,
        origin: lock('mine'),
      );
      final saved = draft.toEntry(id: 'stable', outingId: 'o1', now: _later);
      expect(saved.id, 'stable'); // not the template id
      expect(saved.entryOrigin!.commandId, 'mine');
      expect(saved.consumedAt, _tap);
    });
  });
}
