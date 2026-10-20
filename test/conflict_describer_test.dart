import 'package:bebometro/core/data/local_store.dart';
import 'package:bebometro/core/sync/conflict_describer.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _place({
  String nickname = 'Bar do Zé',
  String? address = 'Rua 5',
  bool favorite = false,
  String? deletedAt,
}) => {
  'id': 'p1',
  'type': 'bar',
  'nickname': nickname,
  'address': address,
  'city': 'Goiânia',
  'state': 'GO',
  'favorite': favorite,
  'archived_at': null,
  'deleted_at': deletedAt,
  'updated_at': '2026-10-19T10:00:00Z',
};

void main() {
  test('a place is named, shows readable fields and marks what differs', () {
    final v = ConflictDescriber.describe(
      LocalStore.places,
      _place(address: 'Rua 9', favorite: true),
      _place(),
    )!;
    expect(v.name, 'Bar do Zé');
    expect(v.differing.length, 2);
    final text = v.local.fields.map((f) => '${f.label}: ${f.value}').join('\n');
    expect(text, contains('Rua 9'));
    expect(text, contains('Goiânia / GO'));
    expect(text, isNot(contains('p1'))); // no technical id
    expect(text, isNot(contains('{')));
  });

  test('unknown data says "não informado"', () {
    final v = ConflictDescriber.describe(
      LocalStore.places,
      _place(address: null),
      _place(),
    )!;
    expect(v.local.fields.any((f) => f.value == 'não informado'), isTrue);
  });

  test('an edit and a deletion are told apart', () {
    final v = ConflictDescriber.describe(
      LocalStore.places,
      _place(deletedAt: '2026-10-19T11:00:00Z'),
      _place(nickname: 'Bar do Zé 2'),
    )!;
    expect(v.local.deleted, isTrue);
    expect(v.remote!.deleted, isFalse);
    // the name shown is the version still alive
    expect(v.name, 'Bar do Zé 2');
  });

  test(
    'a drink shows volume, abv and unknowns; a missing remote is allowed',
    () {
      final local = {
        'id': 'd1',
        'name': 'Meu chope',
        'category': 'draft',
        'brand': null,
        'style': 'Pilsen',
        'volume_ml': 300,
        'abv_percent': 4.8,
        'ingredients': null,
        'updated_at': '2026-10-19T10:00:00Z',
      };
      final remote = {...local, 'volume_ml': 400, 'abv_percent': null};
      final v = ConflictDescriber.describe(
        LocalStore.customDrinks,
        local,
        remote,
      )!;
      expect(v.differing.length, 2);
      final vol = v.local.fields.firstWhere((f) => f.value.contains('300'));
      expect(vol.value, contains('ml'));
      expect(v.remote!.fields.any((f) => f.value == 'não informado'), isTrue);
      final alone = ConflictDescriber.describe(
        LocalStore.customDrinks,
        local,
        null,
      )!;
      expect(alone.remote, isNull);
    },
  );

  test('a recipe lists each ingredient and flags composition changes', () {
    Map<String, dynamic> recipe(double gin) => {
      'id': 'r1',
      'name': 'Gin tônica',
      'category': 'cocktail',
      'components': [
        {
          'name': 'Gin',
          'alcoholic': true,
          'amount': gin,
          'unit': 'ml',
          'abv_percent': 40,
        },
        {'name': 'Tônica', 'alcoholic': false, 'amount': 150, 'unit': 'ml'},
      ],
      'updated_at': '2026-10-19T10:00:00Z',
    };
    final v = ConflictDescriber.describe(
      LocalStore.customDrinks,
      recipe(60),
      recipe(50),
    )!;
    expect(v.kind, 'Receita pessoal');
    expect(v.differing, contains('Composição da receita'));
    final comp = v.local.fields.last.value;
    expect(comp.split('\n'), hasLength(2));
    expect(comp, contains('Gin'));
  });

  test('other collections are not described here', () {
    expect(ConflictDescriber.describe(LocalStore.outings, {}, {}), isNull);
  });
}
