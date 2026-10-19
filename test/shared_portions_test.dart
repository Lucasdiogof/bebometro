import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_draft.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 10, 19, 22);

DrinkEntry _bottle(Map<String, int?> portions, {int? personal}) => DrinkEntry(
      id: 'b1',
      outingId: 'o1',
      consumedAt: _t,
      name: 'Vinho',
      category: DrinkCategory.wine,
      createdAt: _t,
      updatedAt: _t,
      containerMl: 750,
      isShared: true,
      peopleCount: portions.length,
      personalMl: personal,
      priceKind: PriceKind.informed,
      paidCents: 3000,
      billTotalCents: 9000,
      portions: portions,
    );

void main() {
  test('a bottle the owner did not drink can be corrected (price edit not blocked)', () {
    final d = DrinkDraft.fromEntry(_bottle({'p-ana': 400, 'p-bob': 200}));
    expect(d.errors.containsKey('personal'), isFalse);
    expect(d.errors.containsKey('portions'), isFalse);
    expect(d.errors.keys.where((k) => k != 'time'), isEmpty);
  });

  test('changing one portion keeps the others and the owner portion follows', () {
    final d = DrinkDraft.fromEntry(_bottle({ownerPortionKey: 100, 'p-ana': 400}, personal: 100));
    final next = d.withPortions({...d.portions!, ownerPortionKey: 250});
    expect(next.portions, {ownerPortionKey: 250, 'p-ana': 400});
    expect(next.personalMl, 250);
    expect(next.peopleCount, 2);
    expect(next.toEntry(id: 'x', outingId: 'o1', now: _t).personalMl, 250);
  });

  test('an unknown portion stays unknown, never zero', () {
    final d = DrinkDraft.fromEntry(_bottle({'p-ana': 400, 'p-bob': 200}));
    final next = d.withPortions({...d.portions!, 'p-bob': null});
    expect(next.portions!['p-bob'], isNull);
    final entry = next.toEntry(id: 'x', outingId: 'o1', now: _t);
    expect(entry.portions!['p-bob'], isNull);
    expect(next.errors.keys.where((k) => k != 'time'), isEmpty);
  });

  test('portions that add up to more than the bottle are refused', () {
    final d = DrinkDraft.fromEntry(_bottle({'p-ana': 400, 'p-bob': 200}));
    final over = d.withPortions({'p-ana': 600, 'p-bob': 200});
    expect(over.errors.containsKey('personal'), isTrue);
  });
}
