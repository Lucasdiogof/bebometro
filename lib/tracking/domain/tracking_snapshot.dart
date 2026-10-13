import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';
import '../../drinks/domain/presentation_label.dart';

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
  });

  factory TrackingSnapshot.of({
    required Outing outing,
    required List<DrinkEntry> entries,
    required DrinkEntry? lastAlcoholic,
    required bool showSpend,
    required bool showPlace,
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
    );
  }

  final String outingId;
  final DateTime startedAt;
  final int alcoholicCount;
  final int unpricedCount;

  /// Null = spending hidden by the user's choice.
  final int? spendCents;
  final String? place;

  /// The drink "Mais uma" would repeat, e.g. "Chopp 400 ml"; null when there
  /// is none (the action then does not exist).
  final String? nextLabel;

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
      other.nextLabel == nextLabel;

  @override
  int get hashCode => Object.hash(outingId, startedAt, alcoholicCount,
      unpricedCount, spendCents, place, nextLabel);
}
