import 'package:bebometro/drinks/domain/common_sizes.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('commonSizesFor', () {
    test('toda categoria oferece pelo menos um tamanho', () {
      for (final c in DrinkCategory.values) {
        expect(commonSizesFor(c), isNotEmpty, reason: c.name);
      }
    });

    test('são só sugestões, nunca tamanho oficial do produto', () {
      for (final c in DrinkCategory.values) {
        for (final p in commonSizesFor(c)) {
          expect(p.isSuggestion, isTrue, reason: '${c.name}: ${p.label}');
        }
      }
    });

    test('volumes são positivos e sem repetição dentro da categoria', () {
      for (final c in DrinkCategory.values) {
        final sizes = commonSizesFor(c);
        final volumes = [for (final p in sizes) p.volumeMl];
        expect(volumes, everyElement(greaterThan(0)), reason: c.name);
        expect(volumes.toSet(), hasLength(volumes.length), reason: c.name);
      }
    });

    test('o rótulo sempre diz o volume que a opção representa', () {
      for (final c in DrinkCategory.values) {
        for (final p in commonSizesFor(c)) {
          expect(
            p.label.contains('${p.volumeMl}') ||
                p.label.contains('${p.volumeMl / 1000}'),
            isTrue,
            reason: '${c.name}: "${p.label}" vs ${p.volumeMl} ml',
          );
        }
      }
    });

    test('chope serve em copo/caneca, cerveja em embalagem', () {
      expect(
        commonSizesFor(DrinkCategory.draft).map((p) => p.label),
        everyElement(anyOf(startsWith('Copo'), startsWith('Caneca'))),
      );
      expect(
        commonSizesFor(DrinkCategory.beer).map((p) => p.volumeMl),
        containsAll([350, 600]),
      );
    });

    test('cerveja e sem álcool dividem as mesmas sugestões', () {
      expect(
        commonSizesFor(DrinkCategory.nonAlcoholic).map((p) => p.volumeMl),
        commonSizesFor(DrinkCategory.beer).map((p) => p.volumeMl),
      );
    });
  });
}
