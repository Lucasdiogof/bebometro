import 'local_store.dart';

/// Small device-local preferences and "already shown" markers that do not
/// belong to any synced record.
class AppPrefs {
  AppPrefs(this._store);

  final LocalStore _store;

  static const _budgetAlertsKey = 'prefs.budget_alerts';

  /// Budget warnings on/off (default on).
  bool get budgetAlerts => _store.getString(_budgetAlertsKey) != '0';

  Future<void> setBudgetAlerts(bool on) =>
      _store.setString(_budgetAlertsKey, on ? '1' : '0');

  // ---- budget thresholds already announced (per outing and budget value) -----

  String _firedKey(String outingId) => 'budget.fired.$outingId';

  /// Thresholds (80, 100) already announced for this outing at this budget. A
  /// new budget value starts a fresh set.
  Set<int> firedThresholds(String outingId, int budgetCents) {
    final raw = _store.getString(_firedKey(outingId));
    if (raw == null) return {};
    final parts = raw.split('|');
    if (parts.length != 2 || parts[0] != '$budgetCents') return {};
    return {
      for (final p in parts[1].split(','))
        if (int.tryParse(p) != null) int.parse(p),
    };
  }

  Future<void> markFired(String outingId, int budgetCents, Set<int> all) =>
      _store.setString(_firedKey(outingId), '$budgetCents|${all.join(',')}');

  // ---- "is this outing still happening?" -------------------------------------

  String _staleKey(String outingId) => 'stale.snooze.$outingId';

  /// When the "still happening?" question may be asked again for this outing.
  DateTime? staleSnoozedUntil(String outingId) {
    final raw = _store.getString(_staleKey(outingId));
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> snoozeStale(String outingId, DateTime until) =>
      _store.setString(_staleKey(outingId), until.toIso8601String());
}
