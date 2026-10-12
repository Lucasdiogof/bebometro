import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_store.dart';

enum SyncStatus {
  /// Nothing waiting to be sent.
  synced,
  syncing,

  /// Offline or a server error; will retry.
  failed,

  /// Cloud sync is not available (e.g. anonymous sign-in disabled in the
  /// project). Data stays safely on this device.
  localOnly,
}

class SyncState {
  const SyncState(this.status, {this.pending = 0, this.detail});

  final SyncStatus status;
  final int pending;
  final String? detail;

  String get label {
    switch (status) {
      case SyncStatus.synced:
        return 'Sincronizado';
      case SyncStatus.syncing:
        return 'Sincronizando…';
      case SyncStatus.failed:
        return pending > 0 ? '$pending pendente(s) de envio' : 'Falha ao sincronizar';
      case SyncStatus.localOnly:
        return 'Salvo só neste aparelho';
    }
  }
}

/// Pushes locally saved rows to Supabase. Writes always land on the device
/// first; this class only tracks which rows still need to be upserted.
/// Row ids are stable client-generated UUIDs, so retrying never duplicates.
class SyncCubit extends Cubit<SyncState> {
  SyncCubit(this._store, {required this.cloudEnabled})
      : super(const SyncState(SyncStatus.synced)) {
    _dirty.addAll(_store.getStringSet(_dirtyKey));
    if (!cloudEnabled) {
      emit(SyncState(SyncStatus.localOnly, pending: _dirty.length));
    }
  }

  static const _dirtyKey = 'sync.dirty';

  final LocalStore _store;
  final bool cloudEnabled;
  final _dirty = <String>{};
  Timer? _debounce;
  Timer? _retry;
  bool _flushing = false;
  bool _flushAgain = false;
  bool _authUnavailable = false;

  void start() => schedule(immediate: true);

  /// Marks a row as needing upload and schedules a flush.
  Future<void> markDirty(String collection, String id) async {
    _dirty.add('$collection|$id');
    await _store.setStringSet(_dirtyKey, _dirty);
    schedule();
  }

  void schedule({bool immediate = false}) {
    if (!cloudEnabled || _authUnavailable) {
      emit(SyncState(SyncStatus.localOnly, pending: _dirty.length));
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(
      immediate ? Duration.zero : const Duration(milliseconds: 800),
      flush,
    );
  }

  Future<void> flush() async {
    if (!cloudEnabled) return;
    if (_flushing) {
      _flushAgain = true;
      return;
    }
    _flushing = true;
    try {
      final client = Supabase.instance.client;
      var user = client.auth.currentUser;
      if (user == null) {
        emit(SyncState(SyncStatus.syncing, pending: _dirty.length));
        try {
          user = (await client.auth.signInAnonymously()).user;
        } on AuthException catch (e) {
          _authUnavailable = true;
          emit(SyncState(
            SyncStatus.localOnly,
            pending: _dirty.length,
            detail: e.message,
          ));
          return;
        }
      }
      if (user == null) {
        emit(SyncState(SyncStatus.localOnly, pending: _dirty.length));
        return;
      }

      if (_dirty.isEmpty) {
        emit(const SyncState(SyncStatus.synced));
        return;
      }
      emit(SyncState(SyncStatus.syncing, pending: _dirty.length));

      for (final collection in LocalStore.collections) {
        final keys = _dirty.where((k) => k.startsWith('$collection|')).toList();
        if (keys.isEmpty) continue;
        final rows = <Map<String, dynamic>>[];
        final sent = <String, String?>{};
        for (final key in keys) {
          final id = key.substring(collection.length + 1);
          final row = _store.get(collection, id);
          if (row == null) {
            _dirty.remove(key);
            continue;
          }
          rows.add({...row, 'owner_id': user.id});
          sent[key] = row['updated_at'] as String?;
        }
        if (rows.isNotEmpty) {
          await client.from(collection).upsert(rows);
        }
        for (final entry in sent.entries) {
          final id = entry.key.substring(collection.length + 1);
          // Keep the flag if the row changed while the request was in flight.
          if (_store.get(collection, id)?['updated_at'] == entry.value) {
            _dirty.remove(entry.key);
          }
        }
        await _store.setStringSet(_dirtyKey, _dirty);
      }
      _retry?.cancel();
      emit(_dirty.isEmpty
          ? const SyncState(SyncStatus.synced)
          : SyncState(SyncStatus.failed, pending: _dirty.length));
      if (_dirty.isNotEmpty) _flushAgain = true;
    } catch (e) {
      emit(SyncState(
        SyncStatus.failed,
        pending: _dirty.length,
        detail: e.toString(),
      ));
      _retry?.cancel();
      _retry = Timer(const Duration(seconds: 30), flush);
    } finally {
      _flushing = false;
      if (_flushAgain) {
        _flushAgain = false;
        schedule();
      }
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _retry?.cancel();
    return super.close();
  }
}
