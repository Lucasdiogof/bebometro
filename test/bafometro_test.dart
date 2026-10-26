import 'dart:async';
import 'dart:typed_data';

import 'package:bebometro/core/theme/app_theme.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/games/data/breath_input.dart';
import 'package:bebometro/games/domain/breath_toy.dart';
import 'package:bebometro/games/domain/party_meter.dart';
import 'package:bebometro/games/presentation/bafometro_page.dart';
import 'package:bebometro/l10n/l10n.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
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

const _ana = BafoPerson(id: 'ana', name: 'Ana', alcoholicOrders: 3);
const _bia = BafoPerson(id: 'bia', name: 'Bia', alcoholicOrders: 0);

Widget _app(
  BreathInput Function() factory, {
  BafoRoster roster = const BafoRoster([_ana]),
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
    home: BafometroPage(inputFactory: factory, rosterLoader: () => roster),
  );
}

Uint8List _pcm(int v, int n) {
  final b = ByteData(n * 2);
  for (var i = 0; i < n; i++) {
    b.setInt16(i * 2, v, Endian.little);
  }
  return b.buffer.asUint8List();
}

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

/// About a second of sound is enough.
Future<void> _blow(WidgetTester tester, _FakeInput input) async {
  for (var i = 0; i < 16; i++) {
    input.controller.add(0.6);
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pump(const Duration(seconds: 3));
  await _settle(tester);
}

DrinkEntry _entry(
  String id, {
  String? consumer,
  DrinkCategory category = DrinkCategory.beer,
  Map<String, int?>? portions,
}) => DrinkEntry(
  id: id,
  outingId: 'o',
  consumedAt: DateTime(2026, 10, 20, 21),
  name: 'x',
  category: category,
  createdAt: DateTime(2026, 10, 20, 21),
  updatedAt: DateTime(2026, 10, 20, 21),
  consumerId: consumer,
  isShared: portions != null,
  portions: portions,
);

void main() {
  group('BreathToy (pure logic)', () {
    test('about one second of enough sound fills the bar', () {
      final toy = BreathToy();
      for (var i = 0; i < 10; i++) {
        toy.update(0.4, 0.1);
      }
      expect(toy.full, isTrue);
    });

    test('a normal, short blow is enough, silence is not', () {
      final quiet = BreathToy()..update(0.1, 2.0);
      expect(quiet.fill, 0);
      final soft = BreathToy()..update(0.3, 1.0);
      expect(soft.full, isTrue);
    });

    test('strength does not change speed or anything else', () {
      final soft = BreathToy()..update(0.3, 0.5);
      final loud = BreathToy()..update(1.0, 0.5);
      expect(soft.fill, loud.fill);
    });

    test('a pause drains the bar slowly', () {
      final toy = BreathToy()..update(1.0, 0.6);
      final before = toy.fill;
      toy.update(0.0, 0.4);
      expect(toy.fill, lessThan(before));
      expect(toy.fill, greaterThan(0));
    });

    test('microphone level: silence 0, loud high, empty 0', () {
      expect(MicBreathInput.levelOf(_pcm(0, 100)), 0);
      expect(MicBreathInput.levelOf(Uint8List(0)), 0);
      expect(MicBreathInput.levelOf(_pcm(20000, 100)), greaterThan(0.9));
      expect(MicBreathInput.levelOf(_pcm(30, 100)), lessThan(0.1));
    });
  });

  group('PartyMeter (the recreational rule)', () {
    test('n / (n + 4): rises with orders and never reaches 1', () {
      expect(PartyMeter.level(0), 0);
      expect(PartyMeter.level(4), 0.5);
      var prev = -1.0;
      for (var n = 0; n < 200; n++) {
        final l = PartyMeter.level(n);
        expect(l, greaterThan(prev));
        expect(l, lessThan(1));
        prev = l;
      }
    });

    test('only own alcoholic orders count: water, soft and shared do not', () {
      const me = Participant(id: 'p-me', name: 'Você', isMe: true);
      const ana = Participant(id: 'p-ana', name: 'Ana');
      const doc = TabDoc(outingId: 'o', participants: [me, ana]);
      final entries = [
        _entry('1', consumer: 'p-ana'),
        _entry('2', consumer: 'p-ana'),
        _entry('3', consumer: 'p-ana', category: DrinkCategory.water),
        _entry('4', consumer: 'p-ana', category: DrinkCategory.nonAlcoholic),
        _entry('5', portions: {ownerPortionKey: null, 'p-ana': null}),
        _entry('6'),
      ];
      final c = TabCalculator.consumption(doc, entries);
      expect(c['p-ana']!.alcoholicCount, 2);
      expect(c['p-me']!.alcoholicCount, 1);
      expect(c['p-me']!.sharedCount, 1);
      expect(
        PartyMeter.level(c['p-ana']!.alcoholicCount),
        closeTo(1 / 3, 1e-9),
      );
    });

    test('the level reads records only: blowing never changes it', () {
      expect(_ana.level, PartyMeter.level(3));
      expect(_bia.level, 0);
    });
  });

  testWidgets('without people it explains to start an outing', (tester) async {
    _tall(tester);
    await tester.pumpWidget(
      _app(() => _FakeInput(BreathStart.started), roster: BafoRoster.empty),
    );
    expect(find.text('Sem rolê por aqui'), findsOneWidget);
    expect(find.textContaining('Comece um rolê'), findsOneWidget);
    expect(find.text('Começar'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('one person is picked by itself and the name is shown', (
    tester,
  ) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.started);
    await tester.pumpWidget(_app(() => input));
    expect(find.byKey(const ValueKey('bafo-name')), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(input.starts, 0); // the microphone waits for "Começar"
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('several people: the names are offered and one must be chosen', (
    tester,
  ) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.started);
    await tester.pumpWidget(
      _app(() => input, roster: const BafoRoster([_ana, _bia])),
    );
    expect(find.byType(ChoiceChip), findsNWidgets(2));
    // Start is blocked until somebody is chosen.
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    expect(input.starts, 0);
    await tester.tap(find.byKey(const ValueKey('bafo-bia')));
    await tester.pump();
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    expect(input.starts, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'the microphone is untouched until Start; released after blowing; the result is only the name, the meter and "Simulação"',
    (tester) async {
      _tall(tester);
      final input = _FakeInput(BreathStart.started);
      await tester.pumpWidget(_app(() => input));
      expect(input.starts, 0);
      await tester.tap(find.text('Começar'));
      await _settle(tester);
      expect(input.starts, 1);
      await _blow(tester, input);
      expect(find.text('Simulação'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
      expect(input.stops, greaterThanOrEqualTo(1));
      // nothing that reads as a measurement, a verdict or a joke
      final all = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');
      expect(
        RegExp(
          r'[0-9]|%|mg|g/L|promil|BAC|nível da resenha|sóbri|bêbad|dirig',
          caseSensitive: false,
        ).hasMatch(all),
        isFalse,
        reason: all,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('another person goes back to the names', (tester) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.started);
    await tester.pumpWidget(
      _app(() => input, roster: const BafoRoster([_ana, _bia]), reduce: true),
    );
    await tester.tap(find.byKey(const ValueKey('bafo-ana')));
    await tester.pump();
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    await _blow(tester, input);
    expect(find.text('Simulação'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('bafo-next')));
    await tester.pump();
    expect(find.byType(ChoiceChip), findsNWidgets(2));
    expect(find.text('Simulação'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'denied permission offers hold-to-play and never claims a detected blow',
    (tester) async {
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
      expect(find.text('Segure o botão'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

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

  testWidgets('going to the background releases the microphone and stops', (
    tester,
  ) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.started);
    await tester.pumpWidget(_app(() => input));
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    expect(find.text('Sopre no microfone'), findsOneWidget);
    final before = input.stops;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await _settle(tester);
    expect(input.stops, greaterThan(before));
    expect(find.text('Sopre no microfone'), findsNothing);
    expect(find.text('Começar'), findsOneWidget); // back to ready
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'a person with only shared orders sits at the start of the meter',
    (tester) async {
      _tall(tester);
      final input = _FakeInput(BreathStart.started);
      const sharedOnly = BafoPerson(
        id: 's',
        name: 'Só dividiu',
        alcoholicOrders: 0,
      );
      await tester.pumpWidget(
        _app(() => input, roster: const BafoRoster([sharedOnly]), reduce: true),
      );
      await tester.tap(find.text('Começar'));
      await _settle(tester);
      await _blow(tester, input);
      expect(find.text('Simulação'), findsOneWidget);
      expect(sharedOnly.level, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('reduced motion jumps straight to the result', (tester) async {
    _tall(tester);
    final input = _FakeInput(BreathStart.started);
    await tester.pumpWidget(_app(() => input, reduce: true));
    await tester.tap(find.text('Começar'));
    await _settle(tester);
    await _blow(tester, input);
    expect(find.text('Tentar de novo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'long names and large system text at 360 px do not overflow, in the three languages',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      const long = BafoPerson(
        id: 'l',
        name: 'Maria Fernanda Albuquerque de Souza e Silva Junior Neto',
        alcoholicOrders: 2,
      );
      for (final scale in const [1.0, 1.3, 2.0]) {
        for (final loc in const [
          Locale('pt', 'BR'),
          Locale('en'),
          Locale('es'),
        ]) {
          await tester.pumpWidget(
            _app(
              () => _FakeInput(BreathStart.started),
              roster: const BafoRoster([long, _ana]),
              locale: loc,
              scale: scale,
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$loc x$scale ready');
          await tester.tap(find.byType(ChoiceChip).first);
          await tester.pump();
          await tester.tap(find.byType(TextButton).first);
          await _settle(tester);
          expect(tester.takeException(), isNull, reason: '$loc x$scale manual');
          await tester.pumpWidget(const SizedBox());
        }
      }
    },
  );
}
