import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/export/domain/export_builder.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 10, 16, 23, 53);

DrinkEntry entry({
  String id = 'e1',
  String name = 'Chopp',
  PriceKind kind = PriceKind.informed,
  int? paid = 1500,
  bool shared = false,
  int people = 1,
  int? bill,
  int? personalMl = 400,
  double? abv = 4.8,
  String? consumerId,
}) => DrinkEntry(
  id: id,
  outingId: 'o1',
  consumedAt: _t,
  name: name,
  category: DrinkCategory.draft,
  presentation: 'Copo 400 ml',
  containerMl: 400,
  personalMl: personalMl,
  abvPercent: abv,
  priceKind: kind,
  paidCents: paid,
  isShared: shared,
  peopleCount: people,
  billTotalCents: bill,
  consumerId: consumerId,
  createdAt: _t,
  updatedAt: _t,
);

List<String> lines(String csv) =>
    csv.replaceFirst(ExportBuilder.bom, '').trim().split('\n');

void main() {
  group('drinks CSV', () {
    test('starts with a BOM and fixed Portuguese column names', () {
      final csv = ExportBuilder.drinksCsv([entry()]);
      expect(csv.startsWith(ExportBuilder.bom), isTrue);
      final header = lines(csv).first
          .split(';')
          .map((c) => c.replaceAll('"', ''))
          .toList();
      expect(header.first, 'id');
      expect(header, containsAll(['categoria', 'preco_tipo', 'pago_centavos']));
    });

    test('codes, decimal comma and sim/nao instead of translated labels', () {
      final row = lines(
        ExportBuilder.drinksCsv([
          entry(
            shared: true,
            people: 3,
            bill: 3000,
            paid: 1000,
            personalMl: 200,
          ),
        ]),
      )[1];
      expect(row, contains('"draft"'));
      expect(row, contains('4,8'));
      expect(row, contains('sim'));
      expect(row, contains('"informado"'));
      expect(row, contains(';1000;3000;'));
    });

    test('complimentary, unknown price and unknown volume are not zero', () {
      final csv = ExportBuilder.drinksCsv([
        entry(id: 'a', kind: PriceKind.complimentary, paid: null),
        entry(id: 'b', kind: PriceKind.unknown, paid: null, personalMl: null),
      ]);
      final rows = lines(csv);
      expect(rows[1], contains('"cortesia"'));
      expect(rows[2], contains('"nao_informado"'));
      // unknown volume stays an empty cell between separators
      expect(rows[2], contains(';;'));
      expect(rows[2].split(';')[10], '');
    });

    test('who drank it is a fixed code at the end of the row', () {
      final csv = ExportBuilder.drinksCsv([
        entry(id: 'o'),
        entry(id: 'g', consumerId: 'p-ana'),
      ]);
      final rows = lines(csv);
      final header = rows.first.split(';');
      expect(
        header
            .sublist(header.length - 2)
            .map((c) => c.replaceAll('"', ''))
            .toList(),
        ['consumidor', 'porcoes_json'],
      );
      expect(rows[1].split(';')[rows[1].split(';').length - 2], '"voce"');
      expect(rows[2].split(';')[rows[2].split(';').length - 2], '"p-ana"');
    });

    test('a quote in a name is escaped', () {
      final row = lines(
        ExportBuilder.drinksCsv([entry(name: 'Chopp "da casa"')]),
      )[1];
      expect(row, contains('"Chopp ""da casa"""'));
    });
  });
}
