import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/data/device_store.dart';
import '../../core/data/local_store.dart';
import '../../scan/data/photo_files.dart';

/// Result of asking the server to delete the account.
enum DeleteOutcome {
  done,

  /// The password must be confirmed again (sign-in older than 10 minutes).
  needsReauth,

  /// Part was removed; calling again continues (idempotent on the server).
  partial,

  /// The function is not deployed on this project yet.
  unavailable,

  /// No connection.
  offline,
}

/// Server-side account operations and the local clean-up after them.
class AccountService {
  AccountService(this._device, this._files);

  final DeviceStore _device;
  final PhotoFiles _files;

  /// Calls the `delete-account` Edge Function with the person's own session.
  /// The function takes the user from the JWT; no id is sent.
  Future<DeleteOutcome> deleteOnServer() async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'delete-account',
        method: HttpMethod.post,
      );
      return res.status == 200 ? DeleteOutcome.done : DeleteOutcome.partial;
    } on FunctionsFetchException {
      return DeleteOutcome.offline;
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map ? details['error'] : null;
      if (e.status == 404) return DeleteOutcome.unavailable;
      if (code == 'reauthentication_needed') return DeleteOutcome.needsReauth;
      if (e.status == 401) return DeleteOutcome.needsReauth;
      return DeleteOutcome.partial;
    } catch (e) {
      if (kDebugMode) debugPrint('[account] delete failed: ${e.runtimeType}');
      return DeleteOutcome.offline;
    }
  }

  /// After the server confirmed the deletion: removes the account's space and
  /// its photo files from this device. The account scope must be closed.
  Future<void> wipeLocal(String userId) async {
    final store = await LocalStore.openAccount(userId);
    final photoIds = [
      for (final p in store.all(LocalStore.outingPhotos)) p['id'] as String,
    ];
    await store.close();
    for (final id in photoIds) {
      try {
        await _files.delete(id);
      } catch (_) {}
    }
    final prefix = LocalStore.accountPrefix(userId);
    for (final key
        in _device.keys().where((k) => k.startsWith(prefix)).toList()) {
      await _device.remove(key);
    }
  }
}
