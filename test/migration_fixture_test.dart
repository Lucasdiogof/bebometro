import 'dart:convert';

import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// A tab and its records exactly as they were saved before people existed:
/// no `consumer_id`, no `portions`, no `auto_link`, no `left`. It has a shared
/// bottle, a paid tab, a financial guest ("Convidado") and an outing-only
/// (label reading) item.
final _t = DateTime.utc(2026, 10, 10, 22);

Map<String, dynamic> _oldEntry(Map<String, dynamic> extra) => {
      'id': 'x',
      'outing_id': 'o-old',
      'consumed_at': _t.toIso8601String(),
      'name': 'Chopp',
      'category': 'draft',
      'created_at': _t.toIso8601String(),
      'updated_at': _t.toIso8601String(),
      'price_kind': 'informed',
      'is_shared': false,
      'people_count': 1,
      ...extra,
    };

final _oldEntries = [
  _oldEntry({'id': 'old-1', 'container_ml': 400, 'personal_ml': 400, 'paid_cents': 1500}),
  _oldEntry({'id': 'old-2', 'container_ml': 400, 'personal_ml': 400, 'paid_cents': 1500}),
  _oldEntry({
    'id': 'old-bottle',
    'name': 'Vinho',
    'category': 'wine',
    'is_shared': true,
    'people_count': 3,
    'container_ml': 750,
    'personal_ml': 250,
    'bill_total_cents': 9000,
    'paid_cents': null,
  }),
  _oldEntry({
    'id': 'old-ocr',
    'name': 'Gin do cardápio',
    'category': 'cocktail',
    'catalog_item_id': 'outing:abc',
    'container_ml': null,
    'personal_ml': null,
    'paid_cents': 2800,
  }),
];

final _oldTab = {
  'participants': [
    {'id': 'p-me', 'name': 'Você', 'me': true},
    {'id': 'p-guest', 'name': 'Convidado'},
  ],
  'extras': <Map<String, dynamic>>[],
  'links': [
    {'entry_id': 'old-1', 'service': true, 'assign': null, 'merged': <String>[]},
    {'entry_id': 'old-2', 'service': true, 'assign': {'p-me': 1}, 'merged': <String>[]},
    {'entry_id': 'old-bottle', 'service': true, 'assign': {'p-me': 1, 'p-guest': 2}, 'merged': <String>[]},
    {'entry_id': 'old-ocr', 'service': true, 'assign': null, 'merged': <String>[]},
  ],
  'service_on': true,
  'service_bp': 1000,
  'discount_kind': 'none',
  'discount_value': 0,
  'mode': 'item',
  'equal_ids': ['p-me', 'p-guest'],
  'custom': <String, int>{},
  'payments': [
    {'id': 'pay-1', 'participant_id': 'p-me', 'cents': 5000, 'at': '2026-10-10T23:00:00.000Z'},
  ],
};

({TabDoc doc, Map<String, DrinkEntry> entries}) _read(
  List<Map<String, dynamic>> entries,
  Map<String, dynamic> tab,
) =>
    (
      doc: TabDoc.fromJson('o-old', tab),
      entries: {
        for (final j in entries) j['id'] as String: DrinkEntry.fromJson(j),
      },
    );

void main() {
  test('old records and tab open as before: everything is the owner\'s', () {
    final r = _read(_oldEntries, _oldTab);
    for (final e in r.entries.values) {
      expect(e.consumerId, isNull, reason: e.id);
      expect(e.portions, isNull, reason: e.id);
      expect(e.isMine, isTrue, reason: e.id);
    }
    expect(r.doc.autoLink, isFalse);
    expect(r.doc.participants.where((p) => p.left), isEmpty);
    // The financial guest did not become a consumer and the shared bottle
    // keeps the owner's own portion.
    expect(r.entries['old-bottle']!.personalMl, 250);
  });

  test('reading, saving and reading again changes nothing (idempotent)', () {
    final first = _read(_oldEntries, _oldTab);
    final resultA = TabCalculator.compute(first.doc, first.entries);

    final savedDoc = jsonDecode(jsonEncode(first.doc.toJson())) as Map<String, dynamic>;
    final savedEntries = [
      for (final e in first.entries.values)
        jsonDecode(jsonEncode(e.toJson())) as Map<String, dynamic>,
    ];
    final second = _read(savedEntries, savedDoc);
    final resultB = TabCalculator.compute(second.doc, second.entries);

    expect(resultB.total, resultA.total);
    expect(resultB.subtotal, resultA.subtotal);
    expect(resultB.service, resultA.service);
    for (final p in first.doc.participants) {
      expect(resultB.shareOf(p.id), resultA.shareOf(p.id), reason: p.id);
    }
    expect(second.entries.keys.toSet(), first.entries.keys.toSet());
    expect({for (final l in second.doc.links) l.entryId}, {for (final l in first.doc.links) l.entryId});
    expect(second.doc.payments.map((p) => (p.id, p.cents)), first.doc.payments.map((p) => (p.id, p.cents)));
    // Saving did not invent attribution for old rows.
    for (final e in second.entries.values) {
      expect(e.consumerId, isNull);
    }
    expect(second.doc.autoLink, isFalse);
    // A third pass is still identical.
    final third = _read([
      for (final e in second.entries.values) e.toJson(),
    ], second.doc.toJson());
    expect(TabCalculator.compute(third.doc, third.entries).total, resultA.total);
  });

  test('the old bill: 2 draft + shared bottle once + gin, service 10%, paid R\$ 50 stays', () {
    final r = _read(_oldEntries, _oldTab);
    final res = TabCalculator.compute(r.doc, r.entries);
    // 15 + 15 + 90 (bottle once, not three times) + 28 = 148; service 14,80.
    expect(res.subtotal, 14800);
    expect(res.service, 1480);
    expect(res.total, 16280);
    expect(r.doc.payments.single.cents, 5000);
    expect(DrinkCategory.wine.code, 'wine');
  });
}
