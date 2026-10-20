import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:bebometro/glass/domain/beer_sim.dart';
import 'package:flutter_test/flutter_test.dart';

BeerSim _sim({double fill = 0.78}) =>
    BeerSim(initialFill: fill)..setSize(const Size(100, 200));

void _run(BeerSim s, double target, {int steps = 400, double dt = 1 / 60}) {
  for (var i = 0; i < steps; i++) {
    s.step(dt, target);
  }
}

void main() {
  group('geometria', () {
    test('de pé, a área acima de uma linha horizontal é a fração da tela', () {
      final s = _sim();
      expect(s.areaFraction(0), closeTo(1, 1e-9));
      expect(s.areaFraction(100), closeTo(0.5, 1e-9));
      expect(s.areaFraction(50), closeTo(0.75, 1e-9));
      expect(s.areaFraction(200), closeTo(0, 1e-9));
    });

    test('sem tamanho nenhuma área existe', () {
      expect(BeerSim().areaFraction(10), 0);
    });

    test('levelFor devolve o nível que guarda exatamente o volume pedido', () {
      final s = _sim();
      expect(s.levelFor(0.5), closeTo(100, 0.5));
      expect(s.levelFor(0.25), closeTo(150, 0.5));
      expect(s.levelFor(0), s.maxProj);
      expect(s.levelFor(1), s.minProj);
    });

    test('o volume se conserva em qualquer inclinação', () {
      for (final angle in [-1.2, -0.6, 0.0, 0.4, 0.9, 1.4]) {
        final s = _sim()..angle = angle;
        s.setSize(const Size(120, 240)); // recalcula as projeções
        for (final v in [0.1, 0.3, 0.5, 0.78, 0.9]) {
          expect(
            s.areaFraction(s.levelFor(v)),
            closeTo(v, 0.01),
            reason: 'ângulo $angle, volume $v',
          );
        }
      }
    });

    test(
      'ao ter o tamanho definido, o nível casa com o enchimento inicial',
      () {
        final s = _sim(fill: 0.78);
        expect(s.level, closeTo(200 * (1 - 0.78), 0.5));
        expect(s.volume, 0.78);
        expect(s.isEmpty, isFalse);
      },
    );

    test('a capacidade cai quando o celular inclina, e fica cheia de pé', () {
      final s = _sim();
      expect(s.capacity(), closeTo(1, 1e-9));
      s
        ..angle = math.pi / 4
        ..setSize(const Size(101, 200));
      expect(s.capacity(), lessThan(1));
    });
  });

  group('movimento', () {
    test('sem tamanho, o passo não faz nada', () {
      final s = BeerSim();
      s.step(1 / 60, 1);
      expect(s.angle, 0);
      expect(s.time, 0);
    });

    test('o ângulo converge ao alvo e fica estável', () {
      final s = _sim();
      _run(s, 0.5);
      expect(s.angle, closeTo(0.5, 0.01));
      expect(s.angularVelocity.abs(), lessThan(0.05));
    });

    test('quadro longo é limitado a 50 ms por passo', () {
      final s = _sim();
      s.step(5, 0);
      expect(s.time, closeTo(0.05, 1e-9));
    });

    test('dt zero ou negativo é ignorado', () {
      final s = _sim();
      s.step(0, 1);
      s.step(-1, 1);
      expect(s.time, 0);
    });

    test('atravessar ±π pelo caminho curto nunca faz o líquido saltar', () {
      final s = _sim()..angle = -math.pi + 0.1;
      s.step(1 / 60, math.pi - 0.1);
      // O caminho curto é para o lado negativo.
      expect(s.angularVelocity, lessThan(0));
      expect(s.angle, inInclusiveRange(-math.pi, math.pi));
    });

    test('o ângulo fica sempre entre -π e π', () {
      final s = _sim();
      for (var i = 0; i < 500; i++) {
        s.step(1 / 60, (i % 2 == 0) ? 3.0 : -3.0);
        expect(s.angle, inInclusiveRange(-math.pi, math.pi));
      }
    });

    test('as ondas nascem do movimento e depois amortecem', () {
      final s = _sim();
      s.step(1 / 60, 1.5);
      s.step(1 / 60, 1.5);
      expect(s.waveAmp, greaterThan(0));
      expect(s.waveAmp, lessThanOrEqualTo(200 * 0.018));
      _run(s, 1.5, steps: 600);
      expect(s.waveAmp, lessThan(0.01));
    });

    test('sem efeitos nem ondas, nem bolhas', () {
      final s = _sim()..effects = false;
      _run(s, 1.0, steps: 5);
      expect(s.waveAmp, 0);
      for (var i = 0; i < s.bubbleCount; i++) {
        expect(s.bubbleAlive(i), isFalse);
      }
    });

    test('settle volta ao nível sem mexer no volume', () {
      final s = _sim();
      _run(s, 1.0, steps: 30);
      final v = s.volume;
      s.settle();
      expect(s.angle, 0);
      expect(s.angularVelocity, 0);
      expect(s.waveAmp, 0);
      expect(s.volume, v);
    });

    test('cada passo avisa os ouvintes', () {
      final s = _sim();
      var calls = 0;
      s.addListener(() => calls++);
      s.step(1 / 60, 0);
      s.step(1 / 60, 0);
      expect(calls, 2);
    });
  });

  group('derramar e encher', () {
    test('de pé não derrama nada', () {
      final s = _sim();
      _run(s, 0, steps: 200);
      expect(s.volume, closeTo(0.78, 1e-9));
      expect(s.pouring, isFalse);
    });

    test('inclinado demais, o excedente sai pela boca', () {
      final s = _sim();
      _run(s, 1.4, steps: 400);
      expect(s.volume, lessThan(0.78));
      expect(s.volume, lessThanOrEqualTo(s.capacity() + 0.01));
    });

    test('o volume nunca fica negativo nem passa do cheio', () {
      final s = _sim();
      for (var i = 0; i < 800; i++) {
        s.step(1 / 60, math.pi / 2);
        expect(s.volume, inInclusiveRange(0, 1));
      }
    });

    test('copo vazio é detectado', () {
      final s = _sim(fill: 0.002);
      expect(s.isEmpty, isTrue);
    });

    test('refill enche aos poucos até o inicial e para', () {
      final s = _sim();
      _run(s, math.pi / 2, steps: 800);
      expect(s.volume, lessThan(0.78));
      s.settle();
      var notified = 0;
      s.addListener(() => notified++);
      s.refill();
      expect(s.refilling, isTrue);
      expect(notified, 1);
      _run(s, 0, steps: 600);
      expect(s.volume, closeTo(0.78, 1e-6));
      expect(s.refilling, isFalse);
    });
  });

  group('bolhas', () {
    test('nascem dentro do líquido ao definir o tamanho', () {
      final s = _sim();
      var alive = 0;
      for (var i = 0; i < s.bubbleCount; i++) {
        if (!s.bubbleAlive(i)) continue;
        alive++;
        final depth = s.nx * s.bubbleX(i) + s.ny * s.bubbleY(i) - s.level;
        expect(depth, greaterThan(10));
        expect(s.bubbleR(i), inInclusiveRange(0.7, 3.0));
      }
      expect(alive, greaterThan(0));
    });

    test('no modo calmo só um terço das bolhas fica ativo', () {
      final s = BeerSim(bubbleCount: 60)..calm = true;
      expect(s.activeBubbles, 20);
      expect(BeerSim(bubbleCount: 60).activeBubbles, 60);
    });

    test('a semente fixa deixa a simulação reproduzível', () {
      List<double> run() {
        final s = _sim();
        _run(s, 0.7, steps: 120);
        return [s.angle, s.volume, s.waveAmp, s.bubbleX(0), s.bubbleY(0)];
      }

      expect(run(), run());
    });
  });
}
