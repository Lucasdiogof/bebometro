import 'package:bebometro/core/data/local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> row(String id, String name) => {
  'id': id,
  'outing_id': 'o',
  'name': name,
  'deleted_at': null,
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('each account sees only its own records', () async {
    final a = await LocalStore.openAccount('user-a');
    final b = await LocalStore.openAccount('user-b');
    await a.put(LocalStore.drinkEntries, row('1', 'Chopp A'));
    expect(a.all(LocalStore.drinkEntries), hasLength(1));
    expect(b.all(LocalStore.drinkEntries), isEmpty);
    // A new instance of A (app restart) still has its data, B still none.
    final a2 = await LocalStore.openAccount('user-a');
    final b2 = await LocalStore.openAccount('user-b');
    expect(a2.get(LocalStore.drinkEntries, '1')!['name'], 'Chopp A');
    expect(b2.get(LocalStore.drinkEntries, '1'), isNull);
    expect(b2.pendingCount, 0);
  });

  test('a cloud read never overwrites a local edit still waiting', () async {
    final s = await LocalStore.openAccount('u');
    await s.put(LocalStore.drinkEntries, row('1', 'local edit'));
    expect(s.isPending(LocalStore.drinkEntries, '1'), isTrue);
    final applied = await s.putRemote(LocalStore.drinkEntries, [
      (json: row('1', 'old cloud'), revision: 5),
    ]);
    expect(applied, 0);
    expect(s.get(LocalStore.drinkEntries, '1')!['name'], 'local edit');
  });

  test('a cloud read does not queue anything for upload', () async {
    final s = await LocalStore.openAccount('u');
    await s.putRemote(LocalStore.drinkEntries, [
      (json: row('9', 'from cloud'), revision: 2),
    ]);
    expect(s.get(LocalStore.drinkEntries, '9'), isNotNull);
    expect(s.pendingCount, 0);
    expect(s.revisionOf(LocalStore.drinkEntries, '9'), 2);
  });

  test('an old upload answer does not clear a newer local edit', () async {
    final s = await LocalStore.openAccount('u');
    await s.put(LocalStore.drinkEntries, row('1', 'v1'));
    final key = '${LocalStore.drinkEntries}|1';
    final v1 = s.pending[key]!;
    await s.put(LocalStore.drinkEntries, row('1', 'v2')); // edited meanwhile
    await s.clearPending(key, v1); // old acknowledgement
    expect(s.isPending(LocalStore.drinkEntries, '1'), isTrue);
    final v2 = s.pending[key]!;
    await s.clearPending(key, v2);
    expect(s.isPending(LocalStore.drinkEntries, '1'), isFalse);
  });

  test('the pending queue survives a restart', () async {
    final s = await LocalStore.openAccount('u');
    await s.put(LocalStore.drinkEntries, row('1', 'offline edit'));
    final again = await LocalStore.openAccount('u');
    expect(again.isPending(LocalStore.drinkEntries, '1'), isTrue);
    expect(again.get(LocalStore.drinkEntries, '1')!['name'], 'offline edit');
  });

  test('a closed store ignores late writes (account switch)', () async {
    final s = await LocalStore.openAccount('u');
    await s.close();
    await s.put(LocalStore.drinkEntries, row('1', 'late answer'));
    expect(s.get(LocalStore.drinkEntries, '1'), isNull);
  });
}
