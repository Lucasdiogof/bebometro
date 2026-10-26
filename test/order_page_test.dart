import 'package:bebometro/core/data/local_store.dart';
import 'package:bebometro/core/di/injector.dart';
import 'package:bebometro/core/theme/app_theme.dart';
import 'package:bebometro/drinks/data/drink_repository.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/l10n/l10n.dart';
import 'package:bebometro/tab/data/tab_repository.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:bebometro/table/domain/table_orders.dart';
import 'package:bebometro/table/presentation/order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _me = Participant(id: 'p-me', name: 'Você', isMe: true);
const _ana = Participant(id: 'p-ana', name: 'Ana');
const _joao = Participant(id: 'p-joao', name: 'João');
const _outing = 'o1';

late DrinkRepository drinks;
late TabRepository tabs;
OrderOutcome? lastOutcome;
var _saved = false;

Future<void> _setup({List<Participant> people = const [_me, _ana]}) async {
  SharedPreferences.setMockInitialValues({});
  final store = await LocalStore.openAccount('u-order');
  drinks = DrinkRepository(store, const []);
  tabs = TabRepository(store, drinks);
  await getIt.reset();
  getIt
    ..registerSingleton<DrinkRepository>(drinks)
    ..registerSingleton<TabRepository>(tabs);
  await tabs.update(
    _outing,
    (_) => TabDoc(
      outingId: _outing,
      participants: people,
      equalIds: [for (final p in people) p.id],
      mode: SplitMode.item,
      autoLink: true,
    ),
  );
  lastOutcome = null;
  _saved = false;
}

Widget _host(
  Widget Function(BuildContext) page, {
  Locale locale = const Locale('pt', 'BR'),
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
      data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            key: const ValueKey('open'),
            onPressed: () async {
              lastOutcome = await Navigator.of(context)
                  .push<OrderOutcome>(MaterialPageRoute(builder: page));
              _saved = true;
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
}

void _size(WidgetTester tester, {double w = 400, double h = 1400}) {
  tester.view.physicalSize = Size(w, h);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget Function(BuildContext) _newOrder({Set<String> pre = const {}}) =>
    (_) =>
        OrderPage(outingId: _outing, doc: tabs.load(_outing), preselected: pre);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('open')));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String text) async {
  final field = find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(TextField),
  );
  await tester.enterText(
    field.evaluate().isEmpty ? find.byKey(ValueKey(key)) : field,
    text,
  );
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(ValueKey(key)));
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pump();
}

void main() {
  testWidgets(
    'Heineken 600 for Você and Ana, only Você pays: one shared order, R\$ 20 once',
    (tester) async {
      _size(tester);
      await _setup();
      await tester.pumpWidget(_host(_newOrder()));
      await _open(tester);

      // Starts with Você as the payer and nobody as consumer.
      expect(
        tester
            .widget<FilterChip>(find.byKey(const ValueKey('payer-p-me')))
            .selected,
        isTrue,
      );
      await _type(tester, 'order-name', 'Heineken 600');
      await _type(tester, 'order-price', '20');
      await _tap(tester, 'consumer-p-me');
      await _tap(tester, 'consumer-p-ana');
      // choosing consumers did not touch the payers
      expect(
        tester
            .widget<FilterChip>(find.byKey(const ValueKey('payer-p-ana')))
            .selected,
        isFalse,
      );
      expect(find.byKey(const ValueKey('payer-summary')), findsOneWidget);
      await _tap(tester, 'order-save');
      await tester.pumpAndSettle();

      expect(_saved, isTrue);
      final e = lastOutcome!.entries.single;
      expect(e.isShared, isTrue);
      expect(e.billTotalCents, 2000);
      expect(e.payers, {ownerPortionKey: 1});
      final r = tabs.compute(_outing);
      expect(r.total, 2000);
      expect(r.shareOf('p-me'), 2000);
      expect(r.shareOf('p-ana'), 0);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('free name works with no catalog, no volume and no ABV', (
    tester,
  ) async {
    _size(tester);
    await _setup();
    await tester.pumpWidget(_host(_newOrder(pre: const {'p-ana'})));
    await _open(tester);
    expect(find.text('Teor alcoólico'), findsNothing);
    expect(find.textContaining('Volume'), findsNothing);
    expect(find.textContaining('Composição'), findsNothing);
    await _type(tester, 'order-name', 'Spritzgerald');
    await _type(tester, 'order-price', '32');
    await _tap(tester, 'order-save');
    await tester.pumpAndSettle();
    final e = lastOutcome!.entries.single;
    expect(e.name, 'Spritzgerald');
    expect(e.consumerId, 'p-ana');
    expect(e.containerMl, isNull);
    expect(e.abvPercent, isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('food paid by two of three: Ana consumed and pays nothing', (
    tester,
  ) async {
    _size(tester);
    await _setup(people: const [_me, _ana, _joao]);
    await tester.pumpWidget(_host(_newOrder()));
    await _open(tester);
    await _tap(tester, 'kind-food');
    await _type(tester, 'order-name', 'Batata');
    await _type(tester, 'order-price', '60');
    for (final id in ['p-me', 'p-ana', 'p-joao']) {
      await _tap(tester, 'consumer-$id');
    }
    await _tap(tester, 'payer-p-joao');
    await _tap(tester, 'order-save');
    await tester.pumpAndSettle();
    final x = lastOutcome!.extra!;
    expect(x.assign, {'p-me': 1, 'p-joao': 1});
    expect(x.consumers, ['p-me', 'p-ana', 'p-joao']);
    final r = tabs.compute(_outing);
    expect(r.shareOf('p-me'), 3000);
    expect(r.shareOf('p-joao'), 3000);
    expect(r.shareOf('p-ana'), 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('typed payer amounts must add up to the total, shown at once', (
    tester,
  ) async {
    _size(tester);
    await _setup();
    await tester.pumpWidget(_host(_newOrder(pre: const {'p-me'})));
    await _open(tester);
    await _type(tester, 'order-name', 'Porção');
    await _type(tester, 'order-price', '50');
    await _tap(tester, 'payer-p-ana');
    await tester.tap(find.text('Valores personalizados'));
    await tester.pump();
    // equal split pre-filled: 25 + 25 adds up
    expect(find.byKey(const ValueKey('payer-diff')), findsOneWidget);
    await _type(tester, 'payer-amount-p-me', '40');
    expect(find.textContaining('Passou'), findsOneWidget);
    await _tap(tester, 'order-save');
    await tester.pumpAndSettle();
    expect(_saved, isFalse); // refused
    expect(
      find.text('Os valores precisam somar o total do pedido.'),
      findsOneWidget,
    );
    await _type(tester, 'payer-amount-p-me', '30');
    await _type(tester, 'payer-amount-p-ana', '20');
    await _tap(tester, 'order-save');
    await tester.pumpAndSettle();
    expect(_saved, isTrue);
    final r = tabs.compute(_outing);
    expect(r.shareOf('p-me'), 3000);
    expect(r.shareOf('p-ana'), 2000);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('correcting an order keeps payments and explains the balance', (
    tester,
  ) async {
    _size(tester);
    await _setup();
    final src = drinks.newId();
    await drinks.save(
      DrinkEntry(
        id: src,
        outingId: _outing,
        consumedAt: DateTime(2026, 10, 20, 21),
        name: 'Chopp',
        category: DrinkCategory.beer,
        createdAt: DateTime(2026, 10, 20, 21),
        updatedAt: DateTime(2026, 10, 20, 21),
        priceKind: PriceKind.informed,
        paidCents: 1500,
        payers: const {ownerPortionKey: 1},
      ),
    );
    await tabs.update(
      _outing,
      (d) => d.copyWith(
        payments: [
          TabPayment(
            id: 'pay',
            participantId: 'p-me',
            cents: 1000,
            at: DateTime(2026, 10, 20, 22),
          ),
        ],
      ),
    );
    final doc = tabs.load(_outing);
    final row = TableOrders.rows(
      doc,
      tabs.entriesOf(_outing),
      const PersonFilter.table(),
    ).single;
    await tester.pumpWidget(
      _host((_) => OrderPage(outingId: _outing, doc: doc, edit: row)),
    );
    await _open(tester);
    // pre-filled from what was saved
    expect(find.text('Corrigir pedido'), findsOneWidget);
    await _type(tester, 'order-price', '20');
    await _tap(tester, 'order-save');
    await tester.pumpAndSettle();
    // the balance changed (15 -> 20 owed, 10 already paid): the app says so
    expect(find.text('Saldos atualizados'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(_saved, isTrue);
    expect(lastOutcome!.edited, isTrue);
    expect(lastOutcome!.entries.single.id, src); // same record
    final r = tabs.compute(_outing);
    expect(r.paidBy('p-me'), 1000); // payment untouched
    expect(r.balanceOf('p-me'), 1000);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'long names, large text, keyboard open and three languages: no overflow',
    (tester) async {
      await _setup(
        people: const [
          _me,
          Participant(
            id: 'p-long',
            name: 'Maria Fernanda Albuquerque de Souza e Silva Junior Neto',
          ),
        ],
      );
      for (final scale in const [1.0, 1.3, 2.0]) {
        for (final loc in const [
          Locale('pt', 'BR'),
          Locale('en'),
          Locale('es'),
        ]) {
          tester.view.physicalSize = const Size(360, 740);
          tester.view.devicePixelRatio = 1.0;
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          await tester.pumpWidget(
            _host(
              _newOrder(pre: const {'p-long'}),
              locale: loc,
              scale: scale,
            ),
          );
          await _open(tester);
          await _type(
            tester,
            'order-name',
            'Um pedido com um nome bem comprido para testar a quebra de linha',
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$loc x$scale');
          await tester.pumpWidget(const SizedBox());
        }
      }
      addTearDown(() {
        tester.view.resetViewInsets();
        tester.view.reset();
      });
    },
  );
}
