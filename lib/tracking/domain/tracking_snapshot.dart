import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';
import '../../drinks/domain/presentation_label.dart';
import '../../l10n/l10n.dart';

/// What the lock screen shows, computed from the persisted records with the
/// same rules as the app: [alcoholicCount] is the number of alcoholic drink
/// RECORDS (water and soft drinks excluded; a shared bottle is one record,
/// never "the whole bottle drunk"; it is not a count of standard doses), and
/// [spendCents] is the informed spending on drinks, i.e. what the user paid
/// (their share for shared drinks), never the table's total.
class TrackingSnapshot {
  const TrackingSnapshot({
    required this.outingId,
    required this.startedAt,
    required this.alcoholicCount,
    required this.unpricedCount,
    this.spendCents,
    this.place,
    this.nextLabel,
    this.repeatEntryId,
    this.accountId,
    this.pendingCommands = 0,
    this.texts = const {},
  });

  factory TrackingSnapshot.of({
    required Outing outing,
    required List<DrinkEntry> entries,
    required DrinkEntry? lastAlcoholic,
    required bool showSpend,
    required bool showPlace,
    String? accountId,
    int pendingCommands = 0,
  }) {
    final summary = OutingSummary.of(entries);
    // Nickname first, then the name from the map data; never the address.
    final nick = [outing.nickname, outing.placeName]
        .map((v) => v?.trim())
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    return TrackingSnapshot(
      outingId: outing.id,
      startedAt: outing.startedAt,
      alcoholicCount: summary.alcoholicCount,
      unpricedCount: summary.unpricedCount,
      spendCents: showSpend ? summary.informedCents : null,
      place: showPlace ? nick : null,
      nextLabel: lastAlcoholic == null ? null : _labelOf(lastAlcoholic),
      repeatEntryId: lastAlcoholic?.id,
      accountId: accountId,
      pendingCommands: pendingCommands,
      texts: _texts(
        count: summary.alcoholicCount,
        spendCents: showSpend ? summary.informedCents : null,
        unpriced: summary.unpricedCount,
        next: lastAlcoholic == null ? null : _labelOf(lastAlcoholic),
      ),
    );
  }

  /// Every text the native surfaces show, already in the language chosen in
  /// the app (not the system's): the native side only displays them and keeps
  /// its own Portuguese wording as a fallback for an older payload.
  static Map<String, String?> _texts({
    required int count,
    required int? spendCents,
    required int unpriced,
    required String? next,
  }) =>
      {
        'language': trLanguage,
        'title': tr.trackingTitleFallback,
        'count': tr.trackingCount(count),
        'spend': spendCents == null
            ? null
            : (unpriced > 0
                ? tr.trackingSpendUnpriced(formatCents(spendCents), '$unpriced')
                : tr.trackingSpend(formatCents(spendCents))),
        'open': tr.trackingOpen,
        'another': tr.trackingAnother,
        'anotherWith': next == null ? null : tr.trackingAnotherWith(next),
        'anotherA11y': next == null ? null : tr.trackingAnotherA11y(next),
        'water': tr.trackingWater,
        'pending': tr.trackingAwaitingSave,
        'channelName': tr.trackingTitleFallback,
        'channelDescription': tr.trackingChannelDescription,
      };

  final String outingId;
  final DateTime startedAt;
  final int alcoholicCount;
  final int unpricedCount;

  /// Null = spending hidden by the user's choice.
  final int? spendCents;
  final String? place;

  /// Ready-made texts for the native surfaces (see [_texts]).
  final Map<String, String?> texts;

  /// The drink "Mais uma" would repeat, e.g. "Chopp 400 ml"; null when there
  /// is none (the action then does not exist).
  final String? nextLabel;

  /// Record "Mais uma" repeats now; a lock-screen tap stores it.
  final String? repeatEntryId;

  /// Account that owns the outing; a lock-screen tap stores it.
  final String? accountId;

  /// Lock-screen taps received for this outing and not saved yet.
  final int pendingCommands;

  static String _labelOf(DrinkEntry e) {
    final size = (e.presentation != null && e.presentation!.trim().isNotEmpty)
        ? localizePresentation(e.presentation!)
        : (e.containerMl == null ? '' : formatMl(e.containerMl!));
    if (size.isEmpty || e.name.toLowerCase().contains(size.toLowerCase())) {
      return e.name;
    }
    return '${e.name} $size';
  }

  Map<String, Object?> toMap() => {
        'outingId': outingId,
        'startedAtMs': startedAt.millisecondsSinceEpoch,
        'alcoholicCount': alcoholicCount,
        'unpricedCount': unpricedCount,
        'spendCents': spendCents,
        'place': place,
        'nextLabel': nextLabel,
        'repeatEntryId': repeatEntryId,
        'accountId': accountId,
        'pendingCommands': pendingCommands,
        'texts': texts,
      };

  @override
  bool operator ==(Object other) =>
      other is TrackingSnapshot &&
      other.outingId == outingId &&
      other.startedAt == startedAt &&
      other.alcoholicCount == alcoholicCount &&
      other.unpricedCount == unpricedCount &&
      other.spendCents == spendCents &&
      other.place == place &&
      other.nextLabel == nextLabel &&
      other.repeatEntryId == repeatEntryId &&
      other.accountId == accountId &&
      other.pendingCommands == pendingCommands &&
      _sameTexts(other.texts, texts);

  static bool _sameTexts(Map<String, String?> a, Map<String, String?> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (!b.containsKey(e.key) || b[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(outingId, startedAt, alcoholicCount,
      unpricedCount, spendCents, place, nextLabel, texts['language']);
}
