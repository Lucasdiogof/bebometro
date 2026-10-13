import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../core/data/device_store.dart';
import '../../core/data/local_store.dart';
import '../../export/domain/export_builder.dart';
import '../../scan/data/photo_files.dart';

/// What happened to the records kept in the pre-account layout.
enum LegacyStatus {
  /// No old records on this device.
  none,

  /// Old records waiting for a decision (convert, import, keep, export).
  pending,

  /// The person chose to keep them apart for now (asked again from the
  /// account screen, never forced).
  kept,

  /// Became the space of the converted account (same user id).
  adopted,

  /// Copied into an account with new ids.
  imported,
}

class LegacyInfo {
  const LegacyInfo({
    required this.status,
    this.owner,
    this.account,
    this.outings = 0,
    this.entries = 0,
    this.pendingUploads = 0,
  });

  final LegacyStatus status;

  /// User id of the anonymous session that wrote them, or null when unknown.
  final String? owner;

  /// Account that adopted/imported them.
  final String? account;
  final int outings;
  final int entries;

  /// Rows that had never reached the server.
  final int pendingUploads;

  bool get needsDecision => status == LegacyStatus.pending;
  bool get hasData => status != LegacyStatus.none;
}

/// Why an import could not run.
class LegacyImportBlocked implements Exception {
  const LegacyImportBlocked(this.reason);

  /// `active_outing`: both spaces have an outing running; the person must
  /// choose to import the old one as finished.
  final String reason;
}

/// Keeps the records written before accounts became mandatory.
///
/// Nothing here deletes the old layout: it stays as the recoverable copy.
/// Every step is idempotent and resumable, and a step is only marked done
/// after everything it wrote is on disk:
///
/// * [recordOwner] notes, once, the anonymous session that owned them.
/// * [adopt] (case A: the same user id, after converting the anonymous user)
///   copies the old keys into the account namespace.
/// * [importInto] (cases B and C: another account, or no recoverable session)
///   copies the rows with NEW ids, remapping every link, copying photo files
///   and clearing their upload state, so nothing collides with rows the old
///   anonymous user may have on the server. The id map is saved before the
///   first row, so a retry reuses it instead of duplicating.
class LegacyData {
  LegacyData(this._device);

  final DeviceStore _device;
  static const _uuid = Uuid();

  static const _ownerKey = 'legacy.owner';
  static const _stateKey = 'legacy.state';
  static const _backupKey = 'legacy.backup_at';

  /// Legacy keys that hold account data (no prefix at all).
  Iterable<String> _legacyKeys() => _device.keys().where((k) =>
      !k.startsWith('acct.') &&
      !k.startsWith('legacy.') &&
      LocalStore.isAccountKey(k));

  bool _hasRows() {
    for (final c in LocalStore.collections) {
      final raw = _device.getString('col.$c');
      if (raw == null) continue;
      try {
        if ((jsonDecode(raw) as List).isNotEmpty) return true;
      } catch (_) {
        return true; // unreadable but present: keep treating it as data
      }
    }
    return false;
  }

  Map<String, dynamic> _state() {
    final raw = _device.getString(_stateKey);
    if (raw == null) return const {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return const {};
    }
  }

  Future<void> _setState(LegacyStatus status, {String? account}) =>
      _device.setString(
        _stateKey,
        jsonEncode({
          'status': status.name,
          'account': ?account,
          'at': DateTime.now().toUtc().toIso8601String(),
        }),
      );

  String? get owner {
    final v = _device.getString(_ownerKey);
    return (v == null || v == 'unknown') ? null : v;
  }

  /// Notes who owned the old records the first time this version runs. Only
  /// the session restored from disk can tell; without it the owner stays
  /// unknown (it is never guessed).
  Future<void> recordOwner(String? anonymousUserId) async {
    if (_device.getString(_ownerKey) != null || !_hasRows()) return;
    await _device.setString(_ownerKey, anonymousUserId ?? 'unknown');
    // The old keys themselves are the recoverable copy: they are never
    // rewritten from here on. Record when that copy was frozen.
    await _device.setString(_backupKey, DateTime.now().toUtc().toIso8601String());
  }

  Future<LegacyInfo> info() async {
    if (!_hasRows()) return const LegacyInfo(status: LegacyStatus.none);
    final st = _state();
    final status = LegacyStatus.values.firstWhere(
      (s) => s.name == st['status'],
      orElse: () => LegacyStatus.pending,
    );
    final store = await LocalStore.openLegacy();
    try {
      return LegacyInfo(
        status: status,
        owner: owner,
        account: st['account'] as String?,
        outings: store.count(LocalStore.outings),
        entries: store.all(LocalStore.drinkEntries)
            .where((e) => e['deleted_at'] == null)
            .length,
        pendingUploads: store.pendingCount,
      );
    } finally {
      await store.close();
    }
  }

  Future<void> keepSeparate() => _setState(LegacyStatus.kept);

  /// Case A: the anonymous user became [userId] (same id). The old keys are
  /// copied under the account prefix. Refuses when the owner is someone else.
  Future<bool> adopt(String userId) async {
    final st = _state();
    if (st['status'] == LegacyStatus.adopted.name && st['account'] == userId) {
      return true;
    }
    if (owner != userId || !_hasRows()) return false;
    final target = await LocalStore.openAccount(userId);
    final targetEmpty = target.isEmpty;
    await target.close();
    // The account space only receives the old records if it holds nothing of
    // its own; otherwise the explicit import is the way.
    if (!targetEmpty && _device.getString('legacy.adopting') != userId) {
      return false;
    }
    await _device.setString('legacy.adopting', userId);
    final prefix = LocalStore.accountPrefix(userId);
    final prefs = _device.prefs;
    for (final key in _legacyKeys().toList()) {
      final value = prefs.get(key);
      if (value is String) {
        await prefs.setString('$prefix$key', value);
      } else if (value is List) {
        await prefs.setStringList('$prefix$key', value.cast<String>());
      }
    }
    await _setState(LegacyStatus.adopted, account: userId);
    await _device.remove('legacy.adopting');
    return true;
  }

  /// Cases B and C: copies the old records into [target] with new ids.
  /// [importActiveAsEndedAt] must be given when both spaces have an outing
  /// running: the old one is then imported as finished at that time (the
  /// person chose it); otherwise [LegacyImportBlocked] is thrown.
  Future<int> importInto(
    LocalStore target,
    String accountId,
    PhotoFiles files, {
    DateTime? importActiveAsEndedAt,
  }) async {
    final legacy = await LocalStore.openLegacy();
    try {
      final targetActive = target
          .all(LocalStore.outings)
          .any((o) => o['ended_at'] == null && o['deleted_at'] == null);
      final legacyActive = legacy
          .all(LocalStore.outings)
          .where((o) => o['ended_at'] == null && o['deleted_at'] == null)
          .toList();
      if (targetActive && legacyActive.isNotEmpty && importActiveAsEndedAt == null) {
        throw const LegacyImportBlocked('active_outing');
      }

      // Same map on every attempt for this account.
      final mapKey = 'legacy.import_map.$accountId';
      final map = <String, String>{};
      final saved = _device.getString(mapKey);
      if (saved != null) {
        (jsonDecode(saved) as Map).forEach((k, v) => map[k as String] = v as String);
      } else {
        for (final c in LocalStore.collections) {
          for (final row in legacy.all(c)) {
            final id = row['id'] as String;
            // The tab's id IS its outing id: one entry covers both.
            map.putIfAbsent(id, () => _uuid.v4());
          }
        }
        await _device.setString(mapKey, jsonEncode(map));
      }

      final uuidRe = RegExp(
          r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}');
      Object? remap(Object? v) {
        if (v is String) {
          return v.replaceAllMapped(uuidRe, (m) => map[m[0]!] ?? m[0]!);
        }
        if (v is List) return [for (final x in v) remap(x)];
        if (v is Map) {
          return {
            for (final e in v.entries) remap(e.key) as String: remap(e.value),
          };
        }
        return v;
      }

      var count = 0;
      for (final c in LocalStore.collections) {
        for (final row in legacy.all(c)) {
          final copy = Map<String, dynamic>.from(remap(row) as Map);
          if (c == LocalStore.outingPhotos) {
            // A new owner means a new private path: upload again.
            copy['storage_path'] = null;
            copy['uploaded_at'] = null;
            final oldId = row['id'] as String;
            final bytes = await files.read(oldId);
            if (bytes != null) await files.write(copy['id'] as String, bytes);
          }
          if (c == LocalStore.outings &&
              copy['ended_at'] == null &&
              copy['deleted_at'] == null &&
              targetActive) {
            final end = importActiveAsEndedAt!;
            final started = DateTime.parse(copy['started_at'] as String);
            final at = end.isBefore(started) ? started : end;
            copy['ended_at'] = at.toUtc().toIso8601String();
            copy['status'] = 'ended';
          }
          copy['updated_at'] = DateTime.now().toUtc().toIso8601String();
          if (target.get(c, copy['id'] as String) == null) {
            await target.put(c, copy);
            count++;
          }
        }
      }
      final favs = legacy.getStringSet('favorites');
      if (favs.isNotEmpty) {
        await target.setStringSet('favorites', {
          ...target.getStringSet('favorites'),
          for (final f in favs) remap(f) as String,
        });
      }
      // Where these records came from, for the account screen and support.
      await target.setString(
        'import.legacy',
        jsonEncode({
          'from': owner ?? 'aparelho (dono desconhecido)',
          'at': DateTime.now().toUtc().toIso8601String(),
          'rows': map.length,
        }),
      );
      await _setState(LegacyStatus.imported, account: accountId);
      return count;
    } finally {
      await legacy.close();
    }
  }

  /// JSON of the old records, for the person to keep before deciding.
  Future<String> exportJson() async {
    final s = await LocalStore.openLegacy();
    try {
      return ExportBuilder.json(
        exportedAt: DateTime.now(),
        places: s.all(LocalStore.places),
        outings: s.all(LocalStore.outings),
        drinkEntries: s.all(LocalStore.drinkEntries),
        customDrinks: s.all(LocalStore.customDrinks),
        outingDrinks: s.all(LocalStore.outingDrinks),
        outingPhotos: s.all(LocalStore.outingPhotos),
        outingTabs: s.all(LocalStore.outingTabs),
      );
    } finally {
      await s.close();
    }
  }
}
