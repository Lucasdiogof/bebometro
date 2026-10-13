import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../data/tab_repository.dart';
import '../domain/tab_calc.dart';
import '../domain/tab_models.dart';
import '../../l10n/l10n.dart';

class TabState {
  const TabState({
    required this.outingId,
    this.outing,
    required this.doc,
    required this.result,
    this.entries = const {},
  });

  final String outingId;
  final Outing? outing;
  final TabDoc doc;
  final TabResult result;

  /// Live drink records of the outing.
  final Map<String, DrinkEntry> entries;

  /// Drink records not on the tab yet, oldest first.
  List<DrinkEntry> get available {
    final covered = doc.coveredEntryIds;
    return [
      for (final e in entries.values)
        if (!covered.contains(e.id)) e,
    ]..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
  }

  /// "Você" if the person already uses the split.
  Participant? get me => doc.me;
}

/// Edits the tab of one outing. Every change is one write of the whole
/// document; nothing here creates, edits or deletes a drink record, except
/// the explicit "fill in the price" on a linked record.
class TabCubit extends Cubit<TabState> {
  TabCubit(
    this.outingId,
    TabRepository tabs,
    DrinkRepository drinks,
    OutingRepository outings,
  )   : _tabs = tabs,
        _drinks = drinks,
        _outings = outings,
        super(_build(outingId, tabs, outings)) {
    _subs
      ..add(_tabs.changes.listen((_) => _refresh()))
      ..add(_outings.changes.listen((_) => _refresh()));
  }

  final String outingId;
  final TabRepository _tabs;
  final DrinkRepository _drinks;
  final OutingRepository _outings;
  final _subs = <StreamSubscription<void>>[];
  static const _uuid = Uuid();

  static TabState _build(
    String outingId,
    TabRepository tabs,
    OutingRepository outings,
  ) {
    final doc = tabs.load(outingId);
    final entries = tabs.entriesOf(outingId);
    return TabState(
      outingId: outingId,
      outing: outings.byId(outingId),
      doc: doc,
      entries: entries,
      result: TabCalculator.compute(doc, entries),
    );
  }

  void _refresh() {
    if (!isClosed) emit(_build(outingId, _tabs, _outings));
  }

  Future<void> _edit(TabDoc Function(TabDoc) change) =>
      _tabs.update(outingId, change);

  String newId() => _uuid.v4();

  // ---- Extras ----------------------------------------------------------------

  Future<void> saveExtra(TabExtra extra) => _edit((d) {
        final exists = d.extras.any((x) => x.id == extra.id);
        return d.copyWith(extras: [
          for (final x in d.extras) x.id == extra.id ? extra : x,
          if (!exists) extra,
        ]);
      });

  Future<void> removeExtra(String id) =>
      _edit((d) => d.copyWith(extras: [
            for (final x in d.extras)
              if (x.id != id) x,
          ]));

  // ---- Linked drink records --------------------------------------------------

  /// Puts records on the tab. A record can be there only once; [merged] maps
  /// a linked record to other records the user confirmed to be the same
  /// shared bottle/jug (they are not charged again).
  Future<void> linkEntries(
    List<String> ids, {
    Map<String, List<String>> merged = const {},
  }) =>
      _edit((d) {
        final covered = d.coveredEntryIds;
        final links = [...d.links];
        for (final id in ids) {
          if (covered.contains(id)) continue;
          final extra = [
            for (final m in merged[id] ?? const <String>[])
              if (!covered.contains(m) && !ids.contains(m)) m,
          ];
          links.add(TabLink(entryId: id, mergedIds: extra));
          covered.add(id);
        }
        return d.copyWith(links: links);
      });

  Future<void> unlink(String entryId) =>
      _edit((d) => d.copyWith(links: [
            for (final l in d.links)
              if (l.entryId != entryId) l,
          ]));

  /// Price for a linked record whose price is missing. It is written on the
  /// record itself, so there is a single charge and the summary agrees.
  Future<void> fillEntryPrice(DrinkEntry e, int cents) async {
    if (e.isShared) {
      await _drinks.setBillTotal(e.id, cents);
    } else {
      await _drinks.applyPrices({e.id: (kind: PriceKind.informed, paidCents: cents)});
    }
  }

  // ---- Service and discount --------------------------------------------------

  Future<void> setService({required bool on, int? bp}) => _edit(
      (d) => d.copyWith(serviceOn: on, serviceBp: bp ?? d.serviceBp));

  Future<void> setDiscount(DiscountKind kind, int value) =>
      _edit((d) => d.copyWith(discountKind: kind, discountValue: value));

  Future<void> setLineService(TabLine line, bool on) => _edit((d) {
        if (line.source == LineSource.entry) {
          return d.copyWith(links: [
            for (final l in d.links)
              l.entryId == line.id ? l.copyWith(service: on) : l,
          ]);
        }
        return d.copyWith(extras: [
          for (final x in d.extras)
            x.id == line.id ? x.copyWith(service: on) : x,
        ]);
      });

  /// Who takes part in a line, with weights; null = everybody.
  Future<void> setLineAssign(TabLine line, Map<String, int>? assign) =>
      _edit((d) {
        if (line.source == LineSource.entry) {
          return d.copyWith(links: [
            for (final l in d.links)
              l.entryId == line.id ? l.copyWith(assign: () => assign) : l,
          ]);
        }
        return d.copyWith(extras: [
          for (final x in d.extras)
            x.id == line.id ? x.copyWith(assign: () => assign) : x,
        ]);
      });

  // ---- Participants ----------------------------------------------------------

  /// Creates "Você" the first time the split is used.
  Future<void> ensureMe() async {
    if (state.doc.me != null) return;
    await _edit((d) {
      if (d.me != null) return d;
      final id = newId();
      return d.copyWith(
        participants: [
          Participant(id: id, name: tr.tabMe, isMe: true),
          ...d.participants,
        ],
        equalIds: [id, ...d.equalIds],
      );
    });
  }

  Future<void> addParticipant(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return Future.value();
    return _edit((d) {
      final id = newId();
      return d.copyWith(
        participants: [...d.participants, Participant(id: id, name: clean)],
        // Whoever is added joins the equal split, which is what most people
        // expect; it can be unticked.
        equalIds: [...d.equalIds, id],
      );
    });
  }

  Future<void> renameParticipant(String id, String name) {
    final clean = name.trim();
    if (clean.isEmpty) return Future.value();
    return _edit((d) => d.copyWith(participants: [
          for (final p in d.participants)
            p.id == id ? p.copyWith(name: clean) : p,
        ]));
  }

  /// True when removing the participant would change shares or payments.
  bool hasLinks(String id) {
    final d = state.doc;
    if (d.payments.any((p) => p.participantId == id)) return true;
    if ((d.custom[id] ?? 0) > 0) return true;
    if (d.mode == SplitMode.equal && d.equalIds.contains(id)) return true;
    bool inAssign(Map<String, int>? a) => a != null && a.containsKey(id);
    return d.extras.any((x) => inAssign(x.assign)) ||
        d.links.any((l) => inAssign(l.assign)) ||
        state.result.shareOf(id) > 0;
  }

  /// Removes a participant. With [transferTo] their shares, weights and
  /// payments go to that person; without it the shares go back to the others
  /// and their payments are deleted. The caller asks the user first.
  Future<void> removeParticipant(String id, {String? transferTo}) =>
      _edit((d) {
        if (d.participant(id)?.isMe ?? true) return d;
        Map<String, int>? fix(Map<String, int>? a) {
          if (a == null || !a.containsKey(id)) return a;
          final next = {...a};
          final w = next.remove(id)!;
          if (transferTo != null) next[transferTo] = (next[transferTo] ?? 0) + w;
          return next.isEmpty ? null : next;
        }

        final custom = {...d.custom};
        final typed = custom.remove(id);
        if (transferTo != null && typed != null) {
          custom[transferTo] = (custom[transferTo] ?? 0) + typed;
        }
        final equal = [
          for (final e in d.equalIds)
            if (e != id) e,
        ];
        if (transferTo != null &&
            d.equalIds.contains(id) &&
            !equal.contains(transferTo)) {
          equal.add(transferTo);
        }
        return d.copyWith(
          participants: [
            for (final p in d.participants)
              if (p.id != id) p,
          ],
          equalIds: equal,
          custom: custom,
          extras: [
            for (final x in d.extras)
              x.copyWith(assign: () => fix(x.assign)),
          ],
          links: [
            for (final l in d.links) l.copyWith(assign: () => fix(l.assign)),
          ],
          payments: [
            for (final p in d.payments)
              if (p.participantId != id)
                p
              else if (transferTo != null)
                p.copyWith(participantId: transferTo),
          ],
        );
      });

  // ---- Split -----------------------------------------------------------------

  Future<void> setMode(SplitMode mode) => _edit((d) => d.copyWith(mode: mode));

  Future<void> toggleEqual(String id) => _edit((d) {
        final ids = [...d.equalIds];
        if (!ids.remove(id)) ids.add(id);
        return d.copyWith(equalIds: ids);
      });

  Future<void> setCustom(String id, int? cents) => _edit((d) {
        final next = {...d.custom};
        if (cents == null) {
          next.remove(id);
        } else {
          next[id] = cents;
        }
        return d.copyWith(custom: next);
      });

  // ---- Payments --------------------------------------------------------------

  Future<void> savePayment(TabPayment payment) => _edit((d) {
        final exists = d.payments.any((p) => p.id == payment.id);
        return d.copyWith(payments: [
          for (final p in d.payments) p.id == payment.id ? payment : p,
          if (!exists) payment,
        ]);
      });

  Future<void> removePayment(String id) =>
      _edit((d) => d.copyWith(payments: [
            for (final p in d.payments)
              if (p.id != id) p,
          ]));

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
