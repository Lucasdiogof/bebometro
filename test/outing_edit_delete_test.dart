import 'package:bebometro/core/data/local_store.dart';
import 'package:bebometro/outings/data/outing_repository.dart';
import 'package:bebometro/outings/domain/outing.dart';
import 'package:bebometro/places/domain/place_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(OutingRepository, Outing)> _repo() async {
  SharedPreferences.setMockInitialValues({});
  final store = await LocalStore.openAccount('u-edit');
  final repo = OutingRepository(store);
  final o = await repo.start(
    type: OutingType.bar,
    place: const PlaceSnapshot(nickname: 'Bar do Zé'),
    startedAt: DateTime.now().subtract(const Duration(hours: 2)),
  );
  return (repo, o);
}

void main() {
  test('edit changes the kind and the start, keeps id and place', () async {
    final (repo, o) = await _repo();
    final newStart = o.startedAt.subtract(const Duration(minutes: 30));
    await repo.edit(o.id, type: OutingType.home, startedAt: newStart);
    final back = repo.byId(o.id)!;
    expect(back.type, OutingType.home);
    expect(back.startedAt.difference(newStart).inSeconds, 0);
    expect(back.nickname, 'Bar do Zé');
    expect(back.id, o.id);
  });

  test('the start cannot be in the future, after the end, or after the first record', () async {
    final (repo, o) = await _repo();
    expect(
      () => repo.edit(
        o.id,
        type: o.type,
        startedAt: DateTime.now().add(const Duration(hours: 1)),
      ),
      throwsArgumentError,
    );
    final first = o.startedAt.add(const Duration(minutes: 20));
    expect(
      () => repo.edit(
        o.id,
        type: o.type,
        startedAt: first.add(const Duration(minutes: 5)),
        earliestRecord: first,
      ),
      throwsArgumentError,
    );
    await repo.finish(o.id, o.startedAt.add(const Duration(hours: 1)));
    expect(
      () => repo.edit(
        o.id,
        type: o.type,
        startedAt: o.startedAt.add(const Duration(hours: 1, minutes: 5)),
      ),
      throwsArgumentError,
    );
    // nothing was changed by the refused attempts
    expect(repo.byId(o.id)!.startedAt.difference(o.startedAt).inSeconds, 0);
  });

  test(
    'delete is a tombstone: the outing leaves every list and stays out',
    () async {
      final (repo, o) = await _repo();
      expect(repo.active?.id, o.id);
      await repo.delete(o.id);
      expect(repo.byId(o.id), isNull);
      expect(repo.active, isNull);
      expect(repo.all(), isEmpty);
      // a second delete is harmless
      await repo.delete(o.id);
      expect(repo.all(), isEmpty);
    },
  );
}
