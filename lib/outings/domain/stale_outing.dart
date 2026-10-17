import 'outing.dart';

/// An outing left open for a long time with nothing happening: the app may ask
/// "Esse rolê ainda está acontecendo?". It never ends the outing by itself.
const Duration kStaleAfter = Duration(hours: 8);

/// How long to leave the person alone after they chose to continue.
const Duration kStaleSnooze = Duration(hours: 24);

/// True when [outing] is running and nothing was registered (and it did not
/// start) in the last [kStaleAfter].
bool isStaleOuting(Outing outing, DateTime? lastEntryAt, DateTime now) {
  if (!outing.isActive) return false;
  final reference =
      (lastEntryAt != null && lastEntryAt.isAfter(outing.startedAt))
      ? lastEntryAt
      : outing.startedAt;
  return now.difference(reference) >= kStaleAfter;
}

/// A sensible end time to offer: a little after the last registered drink (or
/// the start), never in the future. The person can adjust it.
DateTime suggestedEnd(Outing outing, DateTime? lastEntryAt, DateTime now) {
  final base = (lastEntryAt != null && lastEntryAt.isAfter(outing.startedAt))
      ? lastEntryAt
      : outing.startedAt;
  final guess = base.add(const Duration(hours: 1));
  return guess.isAfter(now) ? now : guess;
}
