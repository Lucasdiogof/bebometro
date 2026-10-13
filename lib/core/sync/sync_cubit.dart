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
    _failures = 0; // an explicit request should not wait on the backoff
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
      // The server refused to link an outing to its place (FK or the same-owner
      // trigger). Never worked around: the outing stays pending as it is.
      var placeLinkError = false;
      // Places the server has not confirmed (pending, rejected or table absent).
      final unconfirmedPlaces = <String>{};
      // Outings waiting for their place; their drinks wait with them.
      final heldOutings = <String>{};
      var held = 0;
      // Rows whose newer columns/tables do not exist on the server yet: the
      // compatible part is sent, the row stays pending for a later full send.
      var schemaGaps = 0;

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
          if (collection == LocalStore.drinkEntries &&
              heldOutings.contains(row['outing_id'])) {
            held++;
            continue;
          }
          if (collection == LocalStore.outings &&
              unconfirmedPlaces.contains(row['place_id'])) {
            // Keep the link: wait until the place is confirmed, send nothing.
            heldOutings.add(id);
            held++;
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

        final acked = <String>{};
        Future<void> ack(String id) async {
          await _store.clearPending('$prefix$id', versions[id]!);
          acked.add(id);
        }

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
              if (_tableMissing(e)) {
                schemaGaps++; // whole table absent: keep the row pending
                continue;
              }
              if (collection == LocalStore.outings &&
                  (e.code == '23503' || e.code == 'P0001')) {
                // Place link refused (missing place or owner mismatch): the
                // row, its place_id and its drinks stay as they are.
                placeLinkError = true;
                rejected++;
                failedOutings.add(id);
                continue;
              }
              if (_columnGap(e, collection)) {
                final core = _withoutOptionalColumns(collection, row);
                if (core != null) {
                  try {
                    await client.from(collection).upsert(core);
                    schemaGaps++; // not acked: the full row is retried later
                    continue;
                  } on PostgrestException catch (e2) {
                    _log('core row $collection/$id rejected: ${e2.code}');
                  }
                }
              }
              rejected++;
              if (collection == LocalStore.outings) {
                failedOutings.add(id);
                if (e.code == '23505') activeConflict = true;
              }
            }
          }
        }
        if (collection == LocalStore.places) {
          for (final row in rows) {
            final id = row['id'] as String;
            if (!acked.contains(id)) unconfirmedPlaces.add(id);
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
              : placeLinkError
                  ? 'O servidor não aceitou o vínculo de um rolê com o local '
                      'salvo. Nada foi alterado: os dados continuam salvos no '
                      'aparelho.'
                  : 'O servidor recusou algumas alterações. Seus dados continuam '
                  'salvos no aparelho.',
          retryIn: _backoff,
        );
        return;
      }

      if (held > 0 && schemaGaps == 0) {
        _problem(
          SyncStatus.pending,
          'Alguns rolês aguardam o envio do local salvo. Nada foi perdido.',
          retryIn: _backoff,
        );
        return;
      }

      if (schemaGaps > 0) {
        _problem(
          SyncStatus.pending,
          'Parte dos dados novos aguarda uma atualização do servidor. O '
          'restante já foi enviado e nada foi perdido.',
          retryIn: const Duration(minutes: 5),
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

  static const _optionalColumns = {
    'outings': [
      'place_id',
      'city',
      'state',
      'budget_cents',
      'feedback_wake',
      'feedback_hangover',
      'feedback_note',
    ],
    'drink_entries': ['composition'],
    'custom_drinks': ['components'],
  };

  bool _tableMissing(PostgrestException e) =>
      e.code == 'PGRST205' || e.code == '42P01';

  /// A column the server does not have. Place-link errors (23503, P0001) are
  /// deliberately not here: P0001 is a generic exception code and the outing
  /// must not lose its place_id to get past a validation.
  bool _columnGap(PostgrestException e, String collection) =>
      e.code == 'PGRST204' || e.code == '42703';

  /// The row without its newer optional columns, or null if it had none.
  Map<String, dynamic>? _withoutOptionalColumns(
    String collection,
    Map<String, dynamic> row,
  ) {
    final optional = _optionalColumns[collection];
    if (optional == null || !optional.any(row.containsKey)) return null;
    return {
      for (final e in row.entries)
        if (!optional.contains(e.key)) e.key: e.value,
    };
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
