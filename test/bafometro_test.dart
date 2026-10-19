import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:bebometro/core/theme/app_theme.dart';
import 'package:bebometro/games/data/breath_input.dart';
import 'package:bebometro/games/domain/breath_toy.dart';
import 'package:bebometro/games/presentation/bafometro_page.dart';
import 'package:bebometro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInput implements BreathInput {
  _FakeInput(this.outcome);
  final BreathStart outcome;
  final controller = StreamController<double>.broadcast();
  int starts = 0;
  int stops = 0;
  @override
  Stream<double> get levels => controller.stream;
  @override
  Future<BreathStart> start() async {
    starts++;
    return outcome;
  }

  @override
  Future<void> stop() async => stops++;
}

Widget _app(
  BreathInput Function() factory, {
  Locale locale = const Locale('pt', 'BR'),
  bool reduce = false,
  double scale = 1.0,
}) {
  setCurrentLocale(locale);
  return MaterialApp(
    theme: AppTheme.dark(),
    locale: locale,
    supportedLocales: const [Locale('pt', 'BR'), Locale('en'), Locale('es')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (c, child) => MediaQuery(
      data: MediaQuery.of(c).copyWith(
        disableAnimations: reduce,
        textScaler: TextScaler.linear(scale),
      ),
      child: child!,
    ),
    home: BafometroPage(inputFactory: factory),
  );
}

Uint8List _pcm(int v, int n) {
  final b = ByteData(n * 2);
  for (var i = 0; i < n; i++) {
    b.setInt16(i * 2, v, Endian.little);
  }
  return b.buffer.asUint8List();
}

/// Lets queued microtasks and a few frames run (the screen awaits the
/// microphone and the reveal animation).
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _settle(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  group('BreathToy (pure logic)', () {
    test('fills only above the threshold and drains in silence', () {
      final toy = BreathToy();
      toy.update(0.2, 1.0);
      expect(toy.fill, 0);
      toy.update(1.0, 1.0);
      expect(toy.fill, greaterThan(0.3));
      final before = toy.fill;
      toy.update(0.0, 1.0);
      expect(toy.fill, lessThan(before));
      for (var i = 0; i < 10; i++) {
        toy.update(1.0, 0.5);
      }
      expect(toy.full, isTrue);
    });

    test('the result is random, in range, and never repeats back to back', () {
      final toy = BreathToy(random: Random(7));
      int? prev;
      for (var i = 0; i < 200; i++) {
        final r = toy.pickResult(previous: prev);
        expect(r, inInclusiveRange(0, BreathToy.resultCount - 1));
        expect(r, isNot(prev));
        prev = r;
      }
    });

    test('the needle lands inside the dial for every result', () {
      for (var i = 0; i < BreathToy.resultCount; i++) {
        expect(BreathToy.needleFor(i), inExclusiveRange(0, 1));
      }
    });

    test('microphone level: silence 0, loud high, empty 0', () {
      expect(MicBreathInput.levelOf(_pcm(0, 100)), 0);
      expect(MicBreathInput.levelOf(Uint8List(0)), 0);
      expect(MicBreathInput.levelOf(_pcm(20000, 100)), greaterThan(0.9));
      expect(MicBreathInput.levelOf(_pcm(30, 100)), lessThan(0.1));
    });
  });

  test('no result text looks like a measurement or a verdict, in any language', () {
    final bad = RegExp(
      r'[0-9%]|mg|promil|BAC|blood|sangre|sangue|sóbri|sobri|sober|dirig|driv|conduc',
      caseSensitive: false,
    );
    for (final code in const ['pt', 'en', 'es']) {
      final t = lookupAppLocalizations(Locale(code));
      final texts = [
        t.bafoR1T, t.bafoR1L, t.bafoR2T, t.bafoR2L, t.bafoR3T, t.bafoR3L,
        t.bafoR4T, t.bafoR4L, t.bafoR5T, t.bafoR5L, t.bafoR6T, t.bafoR6L,
        t.bafoR7T, t.bafoR7L, t.bafoR8T, t.bafoR8L,
      ];
      for (final s in texts) {
        expect(bad.hasMatch(s), isFalse, reason: '$code: $s');
      }
    }
  });

  testWidgets('the microphone is untouched until Start; released after blowing', (tester) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.started);
    await tester.pumpWidget(_app(() => input));
    expect(input.starts, 0);
    expect(find.text('Bafômetro de brincadeira'), findsOneWidget);
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    expect(input.starts, 1);
    for (var i = 0; i < 60; i++) {
      input.controller.add(1.0);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(seconds: 3));
    await _settle(tester);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.textContaining('Sorteado ao acaso'), findsOneWidget);
    expect(input.stops, greaterThanOrEqualTo(1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('denied permission offers hold-to-play and never claims a detected blow', (tester) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.denied);
    await tester.pumpWidget(_app(() => input));
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    expect(find.textContaining('Sem acesso ao microfone'), findsOneWidget);
    expect(find.text('Segurar para brincar'), findsOneWidget);
    expect(find.text('Começar'), findsNothing);
    await tester.tap(find.text('Segurar para brincar'));
    await tester.pump();
    expect(find.textContaining('nada é detectado'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('leaving the screen releases the microphone', (tester) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.started);
    await tester.pumpWidget(_app(() => input));
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    final before = input.stops;
    await tester.pumpWidget(const SizedBox());
    await _settle(tester);
    expect(input.stops, greaterThan(before));
  });

  testWidgets('reduced motion jumps straight to the result', (tester) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.started);
    await tester.pumpWidget(_app(() => input, reduce: true));
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    for (var i = 0; i < 60; i++) {
      input.controller.add(1.0);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _settle(tester);
    expect(find.text('Tentar de novo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('English and Spanish screens build without overflow at 360 px', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    for (final loc in const [Locale('en'), Locale('es')]) {
      await tester.pumpWidget(_app(() => _FakeInput(BreathStart.started), locale: loc));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('large system text (1.3 and 2.0) at 360 px does not overflow, ready or blowing', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    for (final scale in const [1.3, 2.0]) {
      for (final loc in const [Locale('pt', 'BR'), Locale('en'), Locale('es')]) {
        await tester.pumpWidget(_app(() => _FakeInput(BreathStart.started), locale: loc, scale: scale));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$loc x$scale ready');
        await tester.tap(find.byType(TextButton).first);
        await _settle(tester);
        expect(tester.takeException(), isNull, reason: '$loc x$scale manual');
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
