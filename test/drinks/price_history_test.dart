import 'package:bebometro/drinks/domain/catalog_item.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/drinks/domain/price_history.dart';
import 'package:flutter_test/flutter_test.dart';

final _base = DateTime.utc(2026, 10, 1, 20);

DrinkEntry _drink(
  String id, {
  String name = 'Chopp',
  int day = 1,
  int ml = 400,
  int? paid,
  int? bill,
  PriceKind? kind,
  bool shared = false,
  String? item,
  String? presentation,
}) {
  final at = _base.add(Duration(days: day));
  return DrinkEntry(
    id: id,
    outingId: 'o',
    consumedAt: at,
    name: name,
    category: DrinkCategory.draft,
    containerMl: ml,
    personalMl: ml,
    presentation: presentation ?? 'Copo $ml ml',
    catalogItemId: item,
    isShared: shared,
    peopleCount: shared ? 2 : 1,
    priceKind:
        kind ??
        (paid == null && bill == null ? PriceKind.unknown : PriceKind.informed),
    paidCents: paid,
    billTotalCents: bill,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  group('ComparableKey', () {
    test('mesmo produto, tamanho e apresentação são iguais', () {
      final a = ComparableKey.of(_drink('1', paid: 1500));
      final b = ComparableKey.of(_drink('2', paid: 1800, day: 5));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test(
      'tamanho, nome, compartilhado e apresentação diferentes não se misturam',
      () {
        final base = ComparableKey.of(_drink('1', paid: 1500));
        expect(ComparableKey.of(_drink('2', ml: 300, paid: 1)), isNot(base));
        expect(
          ComparableKey.of(_drink('3', name: 'Pilsen', paid: 1)),
          isNot(base),
        );
        expect(
          ComparableKey.of(_drink('4', shared: true, bill: 3000)),
          isNot(base),
        );
        expect(
          ComparableKey.of(_drink('5', paid: 1, presentation: 'Caneca')),
          isNot(base),
        );
      },
    );

    test('com produto do catálogo, o id vale mais que o nome', () {
      final a = ComparableKey.of(
        _drink('1', name: 'Brahma', item: 'cat:brahma', paid: 1),
      );
      final b = ComparableKey.of(
        _drink('2', name: 'Brahma Chopp', item: 'cat:brahma', paid: 1),
      );
      expect(a, b);
    });
  });

  group('isPriceComparable', () {
    test('só preço informado pelo usuário conta', () {
      expect(isPriceComparable(_drink('1', paid: 1500)), isTrue);
      expect(isPriceComparable(_drink('2')), isFalse);
      expect(
        isPriceComparable(_drink('3', paid: 0, kind: PriceKind.complimentary)),
        isFalse,
      );
    });

    test('item que só existe dentro de um rolê nunca alimenta o histórico', () {
      final e = _drink('1', paid: 1500, item: '${CatalogItem.outingPrefix}abc');
      expect(isPriceComparable(e), isFalse);
    });
  });

  group('suggestPrice', () {
    final key = ComparableKey.of(_drink('k', paid: 1));

    test('sem histórico igual não sugere nada', () {
      final s = suggestPrice([_drink('1', name: 'Pilsen', paid: 1500)], key);
      expect(s.isEmpty, isTrue);
    });

    test('usa o preço mais recente do mesmo chope', () {
      final s = suggestPrice([
        _drink('1', day: 1, paid: 1500),
        _drink('2', day: 9, paid: 1800),
        _drink('3', day: 5, paid: 1600),
      ], key);
      expect(s.paidCents, 1800);
      expect(s.paidAt, _base.add(const Duration(days: 9)));
      expect(s.totalCents, isNull);
    });

    test('registro sem preço mais novo não apaga o último preço conhecido', () {
      final s = suggestPrice([
        _drink('1', day: 1, paid: 1500),
        _drink('2', day: 9),
      ], key);
      expect(s.paidCents, 1500);
    });

    test('tamanho diferente não entra', () {
      final s = suggestPrice([_drink('1', ml: 300, paid: 900)], key);
      expect(s.isEmpty, isTrue);
    });

    test('compartilhado guarda a parte paga e o total da conta separados', () {
      final sharedKey = ComparableKey.of(_drink('k', shared: true, bill: 1));
      final s = suggestPrice([
        _drink('1', shared: true, paid: 1500, bill: 3000, day: 3),
      ], sharedKey);
      expect(s.paidCents, 1500);
      expect(s.totalCents, 3000);
    });
  });

  group('priceStatsFor', () {
    test('agrupa por bebida e tamanho, com mínimo, máximo e último', () {
      final stats = priceStatsFor([
        _drink('1', day: 1, paid: 1500),
        _drink('2', day: 3, paid: 1800),
        _drink('3', day: 2, paid: 1400),
      ]);
      expect(stats, hasLength(1));
      final s = stats.single;
      expect(s.count, 3);
      expect(s.minCents, 1400);
      expect(s.maxCents, 1800);
      expect(s.lastCents, 1800);
      expect(s.lastAt, _base.add(const Duration(days: 3)));
      expect(s.firstAt, _base.add(const Duration(days: 1)));
      expect(s.shared, isFalse);
      expect(s.label, startsWith('Chopp'));
    });

    test(
      'tamanhos diferentes viram grupos separados, o mais frequente primeiro',
      () {
        final stats = priceStatsFor([
          _drink('1', ml: 300, paid: 1000),
          _drink('2', paid: 1500, day: 2),
          _drink('3', paid: 1600, day: 3),
        ]);
        expect(stats, hasLength(2));
        expect(stats.first.count, 2);
        expect(stats.last.count, 1);
      },
    );

    test('ignora sem preço, cortesia e item exclusivo do rolê', () {
      final stats = priceStatsFor([
        _drink('1'),
        _drink('2', paid: 0, kind: PriceKind.complimentary),
        _drink('3', paid: 1500, item: '${CatalogItem.outingPrefix}x'),
      ]);
      expect(stats, isEmpty);
    });

    test('compartilhado usa o total da conta, não a parte de cada um', () {
      final stats = priceStatsFor([
        _drink('1', shared: true, paid: 1500, bill: 3000),
      ]);
      expect(stats.single.lastCents, 3000);
      expect(stats.single.shared, isTrue);
    });

    test('compartilhado sem total informado não entra no histórico', () {
      expect(priceStatsFor([_drink('1', shared: true, paid: 1500)]), isEmpty);
    });

    test('lista vazia dá resultado vazio', () {
      expect(priceStatsFor(const []), isEmpty);
    });
  });
}
