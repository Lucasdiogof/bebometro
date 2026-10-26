import 'dart:async';
import 'dart:convert';

import '../../core/data/local_store.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/drink_entry.dart';
import '../domain/tab_calc.dart';
import '../domain/tab_models.dart';

/// The tab (comanda) of each outing. One document per outing, written in one
/// step through the durable local store and the existing sync queue, so the
/// participants, shares, settings and payments are never half-saved. The
/// document id is the outing id: there is at most one tab per outing and
/// re-sending it never duplicates anything.
class TabRepository {
  TabRepository(this._store, this._drinks) {
    _store.changes
        .where((c) => c == LocalStore.outingTabs)
        .listen((_) => _changes.add(null));
    // A correction of a linked drink record is a correction of the tab.
    _drinks.changes.listen((_) => _changes.add(null));
  }

  /// 2: participants can be marked as left and a tab can include every record
  /// of the outing by itself (people at the table). The server refuses to move
  /// this number backwards (migration 20261022000000), so an older app cannot
  /// overwrite a tab saved by this one. 3: extras carry who consumed them
  /// (`consumers`), apart from who pays (`assign`).
  static const schemaVersion = 3;

  final LocalStore _store;
  final DrinkRepository _drinks;
  final _changes = StreamController<void>.broadcast();

  /// Emits when the tab or any drink record changes.
  Stream<void> get changes => _changes.stream;

  TabDoc load(String outingId) {
    final row = _store.get(LocalStore.outingTabs, outingId);
    if (row == null) return TabDoc.empty(outingId);
    try {
      return TabDoc.fromJson(
        outingId,
        Map<String, dynamic>.from(row['data'] as Map? ?? const {}),
      );
    } catch (_) {
      return TabDoc.empty(outingId);
    }
  }

  bool hasTab(String outingId) {
    final row = _store.get(LocalStore.outingTabs, outingId);
    return row != null && !load(outingId).isEmpty;
  }

  /// Live drink records of the outing by id.
  Map<String, DrinkEntry> entriesOf(String outingId) => {
    for (final e in _drinks.entriesFor(outingId)) e.id: e,
  };

  TabResult compute(String outingId) =>
      TabCalculator.compute(load(outingId), entriesOf(outingId));

  /// Read-modify-write without any await in between, so two quick edits can
  /// never overwrite each other.
  Future<void> update(String outingId, TabDoc Function(TabDoc) change) {
    final before = load(outingId);
    final next = change(before);
    final existing = _store.get(LocalStore.outingTabs, outingId);
    // Nothing changed (a new order on a tab that already lists every record):
    // no write, so no pending upload and no revision bump for the tab.
    if (existing != null &&
        jsonEncode(next.toJson()) == jsonEncode(before.toJson())) {
      return Future.value();
    }
    final now = DateTime.now().toUtc().toIso8601String();
    return _store.put(LocalStore.outingTabs, {
      'id': outingId,
      'outing_id': outingId,
      'data': next.toJson(),
      'schema_version': schemaVersion,
      'created_at': existing?['created_at'] ?? now,
      'updated_at': now,
      'deleted_at': null,
    });
  }
}
