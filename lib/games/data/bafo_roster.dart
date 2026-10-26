import '../../core/di/injector.dart';
import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../tab/data/tab_repository.dart';
import '../../tab/domain/tab_calc.dart';
import '../domain/party_meter.dart';

/// Reads the people and their own alcoholic orders from the stored records.
/// Read only: nothing is written, nothing leaves the device.
BafoRoster loadBafoRoster() {
  try {
    final outings = getIt<OutingRepository>();
    // The running outing, else the newest one that was not deleted.
    final outing = outings.active ?? _newest(outings);
    if (outing == null) return BafoRoster.empty;
    final doc = getIt<TabRepository>().load(outing.id);
    // A finished outing keeps everybody who was there; a running one only
    // the people still at the table.
    final people = outing.isActive ? doc.present : doc.participants;
    final entries = getIt<DrinkRepository>().entriesFor(outing.id);
    final consumption = TabCalculator.consumption(doc, entries);
    return BafoRoster([
      for (final p in people)
        BafoPerson(
          id: p.id,
          name: p.displayName,
          alcoholicOrders: consumption[p.id]?.alcoholicCount ?? 0,
        ),
    ]);
  } catch (_) {
    return BafoRoster.empty;
  }
}

Outing? _newest(OutingRepository outings) {
  final all = outings.all();
  return all.isEmpty ? null : all.first;
}
