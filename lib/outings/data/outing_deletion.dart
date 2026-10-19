import '../../drinks/data/drink_repository.dart';
import 'outing_repository.dart';

/// What one "delete outing" removed, so it can be brought back. Everything
/// carries the same tombstone stamp [at]: even after a restart the outing and
/// exactly the records deleted with it can be told apart from anything that
/// was deleted before or later.
class DeletedOuting {
  const DeletedOuting({
    required this.outingId,
    required this.at,
    required this.entryIds,
    required this.wasActive,
  });

  final String outingId;
  final DateTime at;

  /// Records this operation deleted (not the ones already deleted before).
  final List<String> entryIds;

  /// The outing was running when it was deleted.
  final bool wasActive;
}

enum RestoreOutcome {
  /// Back as it was.
  restored,

  /// Back, finished at the moment it was deleted (another outing is running).
  restoredEnded,

  /// The deletion was already undone, or the outing changed since: nothing was
  /// touched.
  nothingToRestore,

  /// A running outing exists and the deleted one was running too: the caller
  /// must ask which way to go. Nothing was touched.
  needsChoice,
}

/// Delete outing with Undo.
///
/// How long Undo is offered is a UI matter ([undoWindow]); the data does not
/// expire: the outing, its records, its tab (people, payments, split) and its
/// photos are only hidden/tombstoned, never erased, so a restore needs nothing
/// from memory. Closing the app only ends the offer.
class OutingDeletion {
  OutingDeletion(this._outings, this._drinks);

  final OutingRepository _outings;
  final DrinkRepository _drinks;

  /// How long the "Desfazer" offer stays on screen.
  static const undoWindow = Duration(seconds: 10);

  /// Deletes the outing and its live records with one common stamp. Returns
  /// null when there is nothing to delete.
  Future<DeletedOuting?> delete(String outingId) async {
    final outing = _outings.byId(outingId);
    if (outing == null) return null;
    final at = DateTime.now().toUtc();
    final ids = [for (final e in _drinks.entriesFor(outingId)) e.id];
    for (final id in ids) {
      await _drinks.delete(id, at: at);
    }
    await _outings.delete(outingId, at: at);
    return DeletedOuting(
      outingId: outingId,
      at: at,
      entryIds: ids,
      wasActive: outing.isActive,
    );
  }

  /// Another running outing blocks restoring a running one.
  bool needsChoice(DeletedOuting d) {
    final running = _outings.active;
    return d.wasActive && running != null && running.id != d.outingId;
  }

  /// Restores what [d] deleted. If the deleted outing was running and another
  /// one is running now, [asEnded] must say what to do: true brings it back
  /// finished (never touching the running one); without it nothing happens
  /// and [RestoreOutcome.needsChoice] is returned.
  Future<RestoreOutcome> restore(
    DeletedOuting d, {
    bool asEnded = false,
  }) async {
    final conflict = needsChoice(d);
    if (conflict && !asEnded) return RestoreOutcome.needsChoice;
    final back = await _outings.restore(
      d.outingId,
      deletedAt: d.at,
      endedAt: conflict ? d.at : null,
    );
    // The outing first: a restore cut short leaves a live outing missing some
    // drinks, never live drinks under a deleted outing. Records go by the same
    // stamp, so repeating this only finishes what is left.
    if (back || _outings.byId(d.outingId) != null) {
      var any = back;
      for (final id in d.entryIds) {
        if (await _drinks.restoreDeletedAt(id, d.at)) any = true;
      }
      if (!any) return RestoreOutcome.nothingToRestore;
    } else {
      return RestoreOutcome.nothingToRestore;
    }
    return back && conflict
        ? RestoreOutcome.restoredEnded
        : RestoreOutcome.restored;
  }
}
