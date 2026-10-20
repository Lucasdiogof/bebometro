import 'package:bebometro/core/theme/app_theme.dart';
import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/l10n/l10n.dart';
import 'package:bebometro/tab/domain/tab_calc.dart';
import 'package:bebometro/tab/domain/tab_models.dart';
import 'package:bebometro/table/domain/table_orders.dart';
import 'package:bebometro/table/presentation/bill_view.dart';
import 'package:bebometro/table/presentation/orders_view.dart';
import 'package:bebometro/table/presentation/people_bar.dart';
import 'package:bebometro/table/presentation/people_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Automated layout tests: the table screens at a 360 px phone width with the
/// system text scaled to 1.0, 1.3 and 2.0, in the three languages, with a very
/// long person name. They fail on any RenderFlex overflow or build exception.
/// This is NOT a check on a real device with the system font setting.

final _t = DateTime.utc(2026, 10, 19, 22);
const _longName = 'Maria Eduarda Albuquerque de Souza Pereira';

const _me = Participant(id: 'p-me', name: 'Você', isMe: true);
const _ana = Participant(id: 'p-ana', name: _longName);
const _bob = Participant(id: 'p-bob', name: 'Bob', left: true);

DrinkEntry _drink(
  String id,
  String name, {
  String? consumer,
  int? ml = 400,
  int cents = 1500,
}) => DrinkEntry(
  id: id,
  outingId: 'o1',
  consumedAt: _t,
  name: name,
  category: DrinkCategory.draft,
  createdAt: _t,
  updatedAt: _t,
  containerMl: ml,
  personalMl: ml,
  priceKind: PriceKind.informed,
  paidCents: cents,
  peopleCount: 1,
  consumerId: consumer,
);

TabDoc _doc() => TabDoc(
  outingId: 'o1',
  participants: const [_me, _ana, _bob],
  extras: [
    TabExtra(
      id: 'x1',
      description:
          'Porção de batata frita com cheddar e bacon para a mesa toda',
      category: ExtraCategory.food,
      createdAt: _t,
      priceKind: PriceKind.informed,
      cents: 6000,
      assign: {_me.id: 1, _ana.id: 1},
    ),
  ],
  serviceOn: true,
  mode: SplitMode.item,
  autoLink: true,
  payments: [
    TabPayment(id: 'pay1', participantId: _me.id, cents: 9000, at: _t),
  ],
);

final _entries = [
  for (var i = 0; i < 4; i++) _drink('c$i', 'Chopp de trigo artesanal da casa'),
  for (var i = 0; i < 2; i++)
    _drink('s$i', 'Spritzgerald', consumer: _ana.id, ml: null, cents: 3200),
];

Widget _app(Widget child, Locale locale, double scale) {
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
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: c!,
    ),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  const locales = [Locale('pt', 'BR'), Locale('en'), Locale('es')];
  const scales = [1.0, 1.3, 2.0];

  for (final locale in locales) {
    for (final scale in scales) {
      final label = '${locale.languageCode} x$scale';

      testWidgets(
        'people bar, orders, people and bill do not overflow ($label)',
        (tester) async {
          tester.view.physicalSize = const Size(360, 740);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final doc = _doc();
          final byId = {for (final e in _entries) e.id: e};
          final result = TabCalculator.compute(doc, byId);
          final rows = TableOrders.rows(doc, byId, const PersonFilter.table());
          final consumption = TabCalculator.consumption(doc, _entries);

          await tester.pumpWidget(
            _app(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PeopleBar(
                    doc: doc,
                    filter: const PersonFilter.table(),
                    onChanged: (_) {},
                    onAdd: () {},
                    onManage: (_) {},
                  ),
                  OrdersView(
                    rows: rows,
                    doc: doc,
                    active: true,
                    onEdit: (_) {},
                    onRepeat: (_) {},
                    onDelete: (_) {},
                    onMove: (_) {},
                  ),
                  PeopleView(
                    doc: doc,
                    result: result,
                    consumption: consumption,
                    onSeeOrders: (_) {},
                    onManage: (_) {},
                  ),
                  BillView(
                    doc: doc,
                    result: result,
                    onSettings: () {},
                    onSplit: () {},
                    onShare: () {},
                  ),
                ],
              ),
              locale,
              scale,
            ),
          );
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull, reason: label);
        },
      );
    }
  }

  test('item count is units, not rows: 4 chopp + 2 spritz + 1 dish = 7 items, 3 rows', () {
    final doc = _doc();
    final byId = {for (final e in _entries) e.id: e};
    expect(TableOrders.itemCount(doc, byId.values), 7);
    expect(TableOrders.rows(doc, byId, const PersonFilter.table()).length, 3);
  });

  test(
    'a deleted record is not an item and a dish with quantity counts its units',
    () {
      final doc = _doc().copyWith(
        extras: [
          TabExtra(
            id: 'x2',
            description: 'Pastel',
            category: ExtraCategory.food,
            createdAt: _t,
            quantity: 3,
            priceKind: PriceKind.informed,
            cents: 900,
          ),
        ],
      );
      final gone = _drink('gone', 'Chopp').copyWith(deletedAt: _t);
      expect(TableOrders.itemCount(doc, [_entries.first, gone]), 1 + 3);
    },
  );
}
