import 'dart:ui' show Locale;

import 'package:bebometro/drinks/domain/drink_category.dart';
import 'package:bebometro/drinks/domain/drink_entry.dart';
import 'package:bebometro/l10n/l10n.dart';
import 'package:bebometro/outings/domain/outing.dart';
import 'package:bebometro/tracking/domain/tracking_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 10, 17, 22);

Outing _outing({String? nickname, String? placeName}) => Outing(
  id: 'o1',
  type: OutingType.bar,
  startedAt: _t,
  createdAt: _t,
  updatedAt: _t,
  nickname: nickname,
  placeName: placeName,
  address: 'Rua Secreta, 123',
);

DrinkEntry _drink(
  String id, {
  String name = 'Chopp',
  DrinkCategory category = DrinkCategory.draft,
  int? paid,
  int ml = 400,
  double? abv = 4.8,
}) => DrinkEntry(
  id: id,
  outingId: 'o1',
  consumedAt: _t,
  name: name,
  category: category,
  containerMl: ml,
  personalMl: ml,
  presentation: 'Copo $ml ml',
  abvPercent: abv,
  priceKind: paid == null ? PriceKind.unknown : PriceKind.informed,
  paidCents: paid,
  createdAt: _t,
  updatedAt: _t,
);

TrackingSnapshot _snap(
  List<DrinkEntry> entries, {
  Outing? outing,
  DrinkEntry? last,
  bool spend = true,
  bool place = true,
  String? account,
  int pending = 0,
}) => TrackingSnapshot.of(
  outing: outing ?? _outing(nickname: 'Bar do Zé'),
  entries: entries,
  lastAlcoholic: last,
  showSpend: spend,
  showPlace: place,
  accountId: account,
  pendingCommands: pending,
);

void main() {
  setUp(() => setCurrentLocale(const Locale('pt')));

  group('contagem e gasto', () {
    test('conta só registros alcoólicos; água e refri ficam de fora', () {
      final s = _snap([
        _drink('1', paid: 1500),
        _drink('2', paid: 1500),
        _drink('3', name: 'Água', category: DrinkCategory.water, abv: 0),
      ]);
      expect(s.alcoholicCount, 2);
    });

    test('gasto soma só o que foi informado e conta os sem preço', () {
      final s = _snap([
        _drink('1', paid: 1500),
        _drink('2', paid: 1000),
        _drink('3'),
      ]);
      expect(s.spendCents, 2500);
      expect(s.unpricedCount, 1);
    });

    test('o usuário pode esconder o gasto: fica nulo e some do texto', () {
      final s = _snap([_drink('1', paid: 1500)], spend: false);
      expect(s.spendCents, isNull);
      expect(s.texts['spend'], isNull);
    });

    test('sem registros: zero em tudo', () {
      final s = _snap(const []);
      expect(s.alcoholicCount, 0);
      expect(s.spendCents, 0);
      expect(s.nextLabel, isNull);
      expect(s.repeatEntryId, isNull);
    });
  });

  group('local', () {
    test('apelido tem prioridade sobre o nome do mapa', () {
      final s = _snap(
        const [],
        outing: _outing(nickname: 'Casa da Samara', placeName: 'Bar X'),
      );
      expect(s.place, 'Casa da Samara');
    });

    test('sem apelido (ou só espaços), usa o nome do mapa', () {
      expect(
        _snap(
          const [],
          outing: _outing(nickname: '  ', placeName: 'Bar X'),
        ).place,
        'Bar X',
      );
      expect(
        _snap(const [], outing: _outing(placeName: 'Bar X')).place,
        'Bar X',
      );
    });

    test('nunca mostra o endereço, nem quando não há nome', () {
      final s = _snap(const [], outing: _outing());
      expect(s.place, isNull);
      expect(s.toMap().toString(), isNot(contains('Rua Secreta')));
    });

    test('o usuário pode esconder o local', () {
      final s = _snap(const [], place: false);
      expect(s.place, isNull);
    });
  });

  group('"Mais uma"', () {
    test('repete o último alcoólico com nome e tamanho', () {
      final last = _drink('7', name: 'Chopp');
      final s = _snap([last], last: last);
      expect(s.repeatEntryId, '7');
      expect(s.nextLabel, 'Chopp Copo 400 ml');
      expect(s.texts['anotherWith'], isNotNull);
    });

    test('não repete o tamanho se o nome já o contém', () {
      final last = _drink('7', name: 'Chopp Copo 400 ml');
      expect(_snap([last], last: last).nextLabel, 'Chopp Copo 400 ml');
    });

    test('sem último alcoólico a ação não existe', () {
      final s = _snap([_drink('1', paid: 100)]);
      expect(s.nextLabel, isNull);
      expect(s.texts['anotherWith'], isNull);
      expect(s.texts['anotherA11y'], isNull);
    });
  });

  group('textos para o lado nativo', () {
    test('saem no idioma escolhido no app, não no do sistema', () {
      final pt = _snap([_drink('1', paid: 1500)]);
      expect(pt.texts['language'], 'pt');
      setCurrentLocale(const Locale('en'));
      final en = _snap([_drink('1', paid: 1500)]);
      expect(en.texts['language'], 'en');
      expect(en.texts['open'], isNot(pt.texts['open']));
      setCurrentLocale(const Locale('es'));
      expect(_snap(const []).texts['language'], 'es');
    });

    test('textos fixos sempre presentes', () {
      final t = _snap(const []).texts;
      for (final k in [
        'title',
        'count',
        'open',
        'another',
        'water',
        'pending',
        'channelName',
        'channelDescription',
      ]) {
        expect(t[k], isNotNull, reason: k);
        expect(t[k], isNotEmpty, reason: k);
      }
    });

    test('gasto com itens sem preço usa o texto de "pelo menos"', () {
      final withUnpriced = _snap([_drink('1', paid: 1500), _drink('2')])
          .texts['spend'];
      final complete = _snap([_drink('1', paid: 1500)]).texts['spend'];
      expect(withUnpriced, isNot(complete));
    });
  });

  group('persistência e igualdade', () {
    test('toMap leva todos os campos que o nativo lê', () {
      final last = _drink('7');
      final m = _snap([last], last: last, account: 'acc', pending: 3).toMap();
      expect(m['outingId'], 'o1');
      expect(m['startedAtMs'], _t.millisecondsSinceEpoch);
      expect(m['alcoholicCount'], 1);
      expect(m['accountId'], 'acc');
      expect(m['pendingCommands'], 3);
      expect(m['repeatEntryId'], '7');
      expect(m['texts'], isA<Map<String, String?>>());
    });

    test('snapshots com os mesmos dados são iguais, inclusive o hash', () {
      final a = _snap([_drink('1', paid: 1500)]);
      final b = _snap([_drink('1', paid: 1500)]);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('qualquer dado diferente quebra a igualdade', () {
      final base = _snap([_drink('1', paid: 1500)]);
      expect(
        _snap([_drink('1', paid: 1500), _drink('2', paid: 1)]),
        isNot(base),
      );
      expect(_snap([_drink('1', paid: 1500)], pending: 1), isNot(base));
      expect(_snap([_drink('1', paid: 1500)], account: 'x'), isNot(base));
      expect(_snap([_drink('1', paid: 1500)], place: false), isNot(base));
    });

    test('mudar o idioma muda o snapshot (os textos fazem parte dele)', () {
      final pt = _snap(const []);
      setCurrentLocale(const Locale('en'));
      expect(_snap(const []), isNot(pt));
    });
  });
}
