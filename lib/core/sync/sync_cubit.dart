import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_store.dart';

enum SyncStatus {
  /// Everything saved on the device was confirmed by the server.
  synced,

  /// Changes saved on the device are waiting to be sent.
  pending,
  syncing,

  /// Offline or the server refused something; will retry.
  failed,

  /// Cloud sync is not available (e.g. anonymous sign-in disabled).
  /// Data stays safely on this device.
  localOnly,
}

class SyncState {
  const SyncState(
    this.status, {
    this.pending = 0,
    this.lastSyncAt,
    this.message,
  });

  final SyncStatus status;
  final int pending;
  final DateTime? lastSyncAt;

  /// Short, user-facing explanation. Technical details go to the debug log.
  final String? message;

  String get label {
    switch (status) {
      case SyncStatus.synced:
        return 'Sincronizado';
      case SyncStatus.pending:
        return '$pending aguardando envio';
      case SyncStatus.syncing:
        return 'Sincronizando…';
      case SyncStatus.failed:
        return 'Falha ao sincronizar';
      case SyncStatus.localOnly:
        return 'Só neste aparelho';
    }
  }
}

/// Sends locally saved rows to Supabase.
///
/// Writes always land on the device first ([LocalStore] keeps a durable queue
/// of pending rows). This class drains that queue: one run at a time, parents
/// before children, upserting by client-generated UUID so a retry never
/// duplicates anything. Deletions are soft (`deleted_at`) and travel the same
/// way. A row is only dropped from the queue after the server confirmed it and
/// only if it was not edited again in the meantime.
class SyncCubit extends Cubit<SyncState> {
  SyncCubit(this._store, {required this.cloudEnabled})
      : super(const SyncState(SyncStatus.synced)) {
    _lastSyncAt = _parseTime(_store.getString(_lastSyncKey));
    _sub = _store.changes.listen((_) => schedule());
    _emitIdle();
  }

  static const _lastSyncKey = 'sync.last_at';

  final LocalStore _store;
  final bool cloudEnabled;
  late final StreamSubscription<String> _sub;

  Timer? _debounce;
  Timer? _retry;
  Future<void>? _running;
  bool _again = false;
  int _failures = 0;
  DateTime? _lastSyncAt;
  String? _lastMessage;
  SyncStatus? _lastProblem;

  /// Starts the first sync after launch.
  void start() => schedule(immediate: true);

  /// Debounced sync request; safe to call as often as needed.
  void schedule({bool immediate = false}) {
    if (isClosed) return;
    if (_running == null) _emitIdle();
    if (!cloudEnabled) return;
    _debounce?.cancel();
    _debounce = Timer(
      immediate ? Duration.zero : const Duration(milliseconds: 800),
      () => flush(),
    );
  }

  /// "Sincronizar agora": runs immediately and completes when the run ends.
  Future<void> syncNow() {
    _debounce?.cancel();
    _retry?.cancel();
    return flush();
  }

  /// Runs one sync; concurrent callers share the run in progress and a new
  /// run is queued if something changed meanwhile.
  Future<void> flush() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final run = _run().whenComplete(() {
      _running = null;
      if (_again && !isClosed) {
        _again = false;
        schedule();
      }
    });
    _running = run;
    return run;
  }

  void _emitIdle() {
    if (isClosed) return;
    final pending = _store.pendingCount;
    if (!cloudEnabled) {
      emit(SyncState(
        SyncStatus.localOnly,
        pending: pending,
        lastSyncAt: _lastSyncAt,
        message: _localOnlyMessage,
      ));
    } else if (_lastProblem != null &&
        (pending > 0 || _lastProblem == SyncStatus.localOnly)) {
      emit(SyncState(
        _lastProblem!,
        pending: pending,
        lastSyncAt: _lastSyncAt,
        message: _lastMessage,
      ));
    } else {
      emit(SyncState(
        pending > 0 ? SyncStatus.pending : SyncStatus.synced,
        pending: pending,
        lastSyncAt: _lastSyncAt,
      ));
    }
  }

  static const _localOnlyMessage =
      'A nuvem ainda não está disponível. Seus registros estão salvos só '
      'neste aparelho e serão enviados quando for possível.';

  void _problem(SyncStatus status, String message, {required Duration retryIn}) {
    _lastProblem = status;
    _lastMessage = message;
    emit(SyncState(
      status,
      pending: _store.pendingCount,
      lastSyncAt: _lastSyncAt,
      message: message,
    ));
    _retry?.cancel();
    _retry = Timer(retryIn, () => flush());
  }

  Duration get _backoff {
    final seconds = 30 * (1 << (_failures > 4 ? 4 : _failures));
    return Duration(seconds: seconds > 300 ? 300 : seconds);
  }

  Future<void> _run() async {
    _retry?.cancel();
    if (!cloudEnabled) {
      _emitIdle();
      return;
    }
    try {
      final client = Supabase.instance.client;
      var user = client.auth.currentUser;
      if (user == null) {
        emit(SyncState(SyncStatus.syncing,
            pending: _store.pendingCount, lastSyncAt: _lastSyncAt));
        try {
          user = (await client.auth.signInAnonymously()).user;
        } on AuthRetryableFetchException {
          rethrow; // network trouble: handled as "offline" below
        } on AuthException catch (e) {
          _log('anonymous sign-in refused: ${e.message}');
          _failures++;
          _problem(SyncStatus.localOnly, _localOnlyMessage,
              retryIn: const Duration(minutes: 5));
          return;
        }
      }
      if (user == null) {
        _problem(SyncStatus.localOnly, _localOnlyMessage,
            retryIn: const Duration(minutes: 5));
        return;
      }

      final snapshot = _store.pending;
      if (snapshot.isEmpty) {
        _finishOk();
        return;
      }
      emit(SyncState(SyncStatus.syncing,
          pending: snapshot.length, lastSyncAt: _lastSyncAt));

      final failedOutings = <String>{};
      var rejected = 0;
      var activeConflict = false;

      for (final collection in LocalStore.collections) {
        final prefix = '$collection|';
        final rows = <Map<String, dynamic>>[];
        final versions = <String, int>{};

        for (final entry in snapshot.entries) {
          if (!entry.key.startsWith(prefix)) continue;
          final id = entry.key.substring(prefix.length);
          final row = _store.get(collection, id);
          if (row == null) {
            await _store.clearPending(entry.key, entry.value);
            continue;
          }
          if (collection == LocalStore.drinkEntries &&
              failedOutings.contains(row['outing_id'])) {
            rejected++; // its outing is not on the server yet
            continue;
          }
          rows.add({...row, 'owner_id': user.id});
          versions[id] = entry.value;
        }
        if (rows.isEmpty) continue;

        if (collection == LocalStore.outings) {
          // Finish old outings before an active one is written, so the
          // "one active outing" rule is never violated by ordering.
          rows.sort((a, b) =>
              (a['status'] == 'active' ? 1 : 0) -
              (b['status'] == 'active' ? 1 : 0));
        }

        Future<void> ack(String id) =>
            _store.clearPending('$prefix$id', versions[id]!);

        try {
          await client.from(collection).upsert(rows);
          for (final row in rows) {
            await ack(row['id'] as String);
          }
        } on PostgrestException catch (e) {
          _log('batch upsert on $collection failed: ${e.code} ${e.message}');
          // Isolate the offending row(s); the others still go through.
          for (final row in rows) {
            final id = row['id'] as String;
            try {
              await client.from(collection).upsert(row);
              await ack(id);
            } on PostgrestException catch (e) {
              _log('row $collection/$id rejected: ${e.code} ${e.message}');
              rejected++;
              if (collection == LocalStore.outings) {
                failedOutings.add(id);
                if (e.code == '23505') activeConflict = true;
              }
            }
          }
        }
      }

      if (rejected > 0) {
        _failures++;
        _problem(
          SyncStatus.failed,
          activeConflict
              ? 'O servidor já tem outro rolê em andamento. Nada foi apagado: '
                  'os dados continuam salvos no aparelho.'
              : 'O servidor recusou algumas alterações. Seus dados continuam '
                  'salvos no aparelho.',
          retryIn: _backoff,
        );
        return;
      }

      if (_store.pendingCount > 0) {
        // Edited while uploading: another pass is needed before "synced".
        _again = true;
        _emitIdle();
        return;
      }
      _finishOk();
    } on AuthException catch (e) {
      _log('auth/network error: ${e.message}');
      _failures++;
      _problem(SyncStatus.failed, 'Sem conexão. Vamos tentar de novo.',
          retryIn: _backoff);
    } catch (e, st) {
      _log('sync error: $e\n$st');
      _failures++;
      _problem(SyncStatus.failed, 'Sem conexão. Vamos tentar de novo.',
          retryIn: _backoff);
    }
  }

  void _finishOk() {
    _failures = 0;
    _lastProblem = null;
    _lastMessage = null;
    _lastSyncAt = DateTime.now();
    unawaited(_store.setString(_lastSyncKey, _lastSyncAt!.toIso8601String()));
    emit(SyncState(SyncStatus.synced, lastSyncAt: _lastSyncAt));
  }

  DateTime? _parseTime(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw)?.toLocal();

  void _log(String message) {
    if (kDebugMode) debugPrint('[sync] $message');
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _retry?.cancel();
    _sub.cancel();
    return super.close();
  }
}
