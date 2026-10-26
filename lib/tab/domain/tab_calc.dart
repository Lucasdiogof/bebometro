import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/domain/presentation_label.dart';
import 'tab_models.dart';
import '../../l10n/l10n.dart';

enum LineSource { entry, extra }

/// One charge on the tab, already read from its source. Built on demand from
/// the linked records and the extras; never stored.
class TabLine {
  const TabLine({
    required this.id,
    required this.source,
    required this.title,
    required this.at,
    required this.service,
    required this.groupKey,
    this.detail,
    this.quantity = 1,
    this.totalCents,
    this.personalOnlyCents,
    this.complimentary = false,
    this.assign,
    this.entry,
    this.extra,
  });

  /// Entry id or extra id.
  final String id;
  final LineSource source;
  final String title;
  final String? detail;
  final DateTime at;
  final int quantity;

  /// Cost of the whole line; null = price unknown (a pending item).
  final int? totalCents;

  /// For a shared record whose bottle/jug total is unknown: the only amount
  /// known, which is the user's own share. It is never the table's cost.
  final int? personalOnlyCents;
  final bool complimentary;
  final bool service;
  final Map<String, int>? assign;
  final String groupKey;
  final DrinkEntry? entry;
  final TabExtra? extra;

  bool get isPending => totalCents == null;
  bool get isPersonalOnly => personalOnlyCents != null && totalCents == null;
}

/// Equivalent lines shown together ("Chopp 400 ml · 12 × R$ 15 = R$ 180").
/// Only a presentation: the lines keep their ids, times and records.
class TabGroup {
  const TabGroup(this.key, this.lines);

  final String key;
  final List<TabLine> lines;

  TabLine get first => lines.first;
  int get count => lines.length;
  bool get isPriced => first.totalCents != null;
  int? get unitCents => first.totalCents;
  int? get sumCents => isPriced ? first.totalCents! * count : null;
}

/// A line with its share of the discount and of the service charge.
class LineResult {
  const LineResult(this.line, this.discount, this.service);

  final TabLine line;
  final int discount;
  final int service;

  /// Final cost of the line, or null while its price is unknown.
  int? get finalCents =>
      line.totalCents == null ? null : line.totalCents! - discount + service;
}

class TabResult {
  const TabResult({
    required this.results,
    required this.groups,
    required this.subtotal,
    required this.pendingCount,
    required this.personalOnlyCount,
    required this.discount,
    required this.serviceBase,
    required this.service,
    required this.total,
    required this.shares,
    required this.unassigned,
    required this.paid,
  });

  final List<LineResult> results;
  final List<TabGroup> groups;

  /// Sum of the known prices only.
  final int subtotal;

  /// Lines whose price is unknown (including shared ones with only the
  /// personal share known).
  final int pendingCount;
  final int personalOnlyCount;
  final int discount;

  /// Sum of the eligible lines after the discount, and the charge on it.
  final int serviceBase;
  final int service;
  final int total;

  /// Cost assigned to each participant (cents), per the active split mode.
  final Map<String, int> shares;

  /// Part of the total nobody was given yet (negative = more than the total).
  final int unassigned;

  /// What each participant says to have paid.
  final Map<String, int> paid;

  /// The total is not final: some price is unknown.
  bool get isPartial => pendingCount > 0;

  /// Every cent of a final total is assigned.
  bool get splitComplete => !isPartial && unassigned == 0 && shares.isNotEmpty;

  int shareOf(String id) => shares[id] ?? 0;
  int paidBy(String id) => paid[id] ?? 0;

  /// Everything reported as paid to the venue, by anybody.
  int get paidTotal => paid.values.fold(0, (a, b) => a + b);

  /// What is still due to the venue (never negative). Whoever paid it does not
  /// matter: one person paying for the table settles the bar.
  int get venueDueCents => (total - paidTotal).clamp(0, 1 << 40).toInt();

  /// The venue was paid in full (or more) and the total is final.
  bool get venueSettled => !isPartial && paidTotal >= total && total > 0;

  /// More than the venue was paid: a mistake or a tip, never silently dropped.
  int get overpaidCents => (paidTotal - total).clamp(0, 1 << 40).toInt();

  /// How much a person paid beyond their own share (for the others at the
  /// table). Informational: the app does not say who should pay whom.
  int paidForOthers(String id) =>
      (paidBy(id) - shareOf(id)).clamp(0, 1 << 40).toInt();

  /// Positive = still has to pay; negative = paid more than the share.
  int balanceOf(String id) => shareOf(id) - paidBy(id);
}

/// One person's side of the bill: the pieces and the balance against what they
/// said they paid the venue. Costs only; consumption lives in [PersonConsumption].
class PersonBreakdown {
  const PersonBreakdown({
    required this.id,
    required this.drinksCents,
    required this.foodCents,
    required this.discountCents,
    required this.serviceCents,
    required this.shareCents,
    required this.paidCents,
  });

  final String id;
  final int drinksCents;
  final int foodCents;
  final int discountCents;
  final int serviceCents;

  /// Cost assigned to the person (same number as [TabResult.shares]).
  final int shareCents;

  /// What the person paid the venue.
  final int paidCents;

  /// Positive = still has to pay; negative = paid more than the share.
  int get balanceCents => shareCents - paidCents;
}

/// What one person drank, apart from who paid.
class PersonConsumption {
  const PersonConsumption({
    required this.count,
    required this.knownMl,
    required this.unknownCount,
    required this.alcoholicCount,
  });

  final int count;
  final int knownMl;

  /// Records of this person whose volume is not known (not counted in ml).
  final int unknownCount;
  final int alcoholicCount;

  bool get volumeComplete => unknownCount == 0;
}

class TabCalculator {
  const TabCalculator._();

  /// Splits [total] in proportion to [weights] with whole cents. The
  /// remainders go to the largest fractions, ties to the first position, so
  /// the result is deterministic and always sums to exactly [total].
  static List<int> allocate(int total, List<int> weights) {
    final n = weights.length;
    final out = List<int>.filled(n, 0);
    var sumW = 0;
    for (final w in weights) {
      sumW += w;
    }
    if (n == 0 || total <= 0 || sumW <= 0) return out;
    final rem = List<int>.filled(n, 0);
    var given = 0;
    for (var i = 0; i < n; i++) {
      final p = total * weights[i];
      out[i] = p ~/ sumW;
      rem[i] = p % sumW;
      given += out[i];
    }
    final order = List<int>.generate(n, (i) => i)
      ..sort((a, b) {
        final c = rem[b].compareTo(rem[a]);
        return c != 0 ? c : a.compareTo(b);
      });
    for (var k = 0; k < total - given; k++) {
      out[order[k % n]]++;
    }
    return out;
  }

  /// Half-up percentage of [cents] with [bp] basis points (100 = 1%).
  static int percentOf(int cents, int bp) => (cents * bp + 5000) ~/ 10000;

  static String _sizeOf(DrinkEntry e) {
    if (e.presentation != null && e.presentation!.trim().isNotEmpty) {
      return localizePresentation(e.presentation!);
    }
    return e.containerMl == null ? '' : formatMl(e.containerMl!);
  }

  static TabLine entryLine(
    DrinkEntry e,
    TabLink link, {
    Map<String, int>? assign,
  }) {
    int? total;
    int? personal;
    var complimentary = false;
    switch (e.priceKind) {
      case PriceKind.complimentary:
        total = 0;
        complimentary = true;
      case PriceKind.unknown:
        break;
      case PriceKind.informed:
        if (e.isShared) {
          // The bottle/jug total counts once. Without it only the user's own
          // share is known, and that must not be passed off as the table's.
          if (e.billTotalCents != null) {
            total = e.billTotalCents;
          } else {
            personal = e.paidCents;
          }
        } else {
          total = e.paidCents;
        }
    }
    final size = _sizeOf(e);
    final title =
        size.isEmpty || e.name.toLowerCase().contains(size.toLowerCase())
        ? e.name
        : '${e.name} $size';
    final key = [
      e.catalogItemId ?? 'n:${normalizeText(e.name)}',
      e.containerMl,
      e.presentation,
      e.isShared,
      total ?? 'x',
      personal ?? 'x',
      // Same drink paid by other people is another group.
      (e.payers?.entries.toList()?..sort((a, b) => a.key.compareTo(b.key)))
              ?.map((p) => '${p.key}:${p.value}')
              .join(',') ??
          '-',
    ].join('|');
    return TabLine(
      id: e.id,
      source: LineSource.entry,
      title: title,
      detail: e.isShared ? tr.tabShared : null,
      at: e.consumedAt,
      totalCents: total,
      personalOnlyCents: personal,
      complimentary: complimentary,
      service: link.service,
      assign: assign ?? link.assign,
      groupKey: 'e|$key',
      entry: e,
    );
  }

  static TabLine extraLine(TabExtra x) => TabLine(
    id: x.id,
    source: LineSource.extra,
    title: x.description.isEmpty ? x.category.label : x.description,
    detail: x.category.label,
    at: x.createdAt,
    quantity: x.quantity,
    totalCents: x.totalCents,
    complimentary: x.priceKind == PriceKind.complimentary,
    service: x.service,
    assign: x.assign,
    groupKey: 'x|${x.id}',
    extra: x,
  );

  /// Who splits the cost of [e] when nobody chose otherwise: the person who
  /// drank it, or the people sharing a bottle/jug. A record whose person is not
  /// on the tab yields an EMPTY map (its cost stays unassigned), never "everybody"
  /// and never the owner by default.
  static Map<String, int> defaultAssign(DrinkEntry e, TabDoc doc) {
    String? idFor(String? key) {
      if (key == null || key == ownerPortionKey) return doc.me?.id;
      return doc.participant(key) == null ? null : key;
    }

    // Who pays was chosen apart from who drank: it wins. A payer that is not
    // on the tab leaves its part unassigned (never moved to someone else).
    final payers = e.payers;
    if (payers != null) {
      return {
        for (final k in payers.keys)
          if (idFor(k) != null) idFor(k)!: payers[k]!,
      };
    }
    final portions = e.portions;
    if (portions != null) {
      return {
        for (final k in portions.keys)
          if (idFor(k) != null) idFor(k)!: 1,
      };
    }
    final id = idFor(e.consumerId);
    return id == null ? <String, int>{} : {id: 1};
  }

  /// Lines of the tab, oldest first. A link whose record was deleted shows
  /// nothing (and comes back if the deletion is undone). On a tab with
  /// [TabDoc.autoLink] every live record of the outing is a line (a link, when
  /// there is one, only adjusts service or the cost split).
  static List<TabLine> lines(TabDoc doc, Map<String, DrinkEntry> entries) {
    final out = <TabLine>[];
    if (doc.autoLink) {
      final merged = {for (final l in doc.links) ...l.mergedIds};
      for (final e in entries.values) {
        if (e.isDeleted || merged.contains(e.id)) continue;
        final link = doc.linkFor(e.id) ?? TabLink(entryId: e.id);
        out.add(
          entryLine(e, link, assign: link.assign ?? defaultAssign(e, doc)),
        );
      }
    } else {
      for (final link in doc.links) {
        final e = entries[link.entryId];
        if (e == null || e.isDeleted) continue;
        // Tabs made before people existed have no default: the link decides,
        // unless the record names its payers.
        out.add(
          entryLine(
            e,
            link,
            assign:
                link.assign ??
                (e.payers == null ? null : defaultAssign(e, doc)),
          ),
        );
      }
    }
    for (final x in doc.extras) {
      out.add(extraLine(x));
    }
    out.sort((a, b) => a.at.compareTo(b.at));
    return out;
  }

  static TabResult compute(TabDoc doc, Map<String, DrinkEntry> entries) {
    final lines = TabCalculator.lines(doc, entries);

    var subtotal = 0;
    var pending = 0;
    var personalOnly = 0;
    for (final l in lines) {
      if (l.totalCents == null) {
        pending++;
        if (l.isPersonalOnly) personalOnly++;
      } else {
        subtotal += l.totalCents!;
      }
    }

    // 1. Discount on the known subtotal, never above it.
    var discount = 0;
    switch (doc.discountKind) {
      case DiscountKind.none:
        break;
      case DiscountKind.amount:
        discount = doc.discountValue.clamp(0, subtotal).toInt();
      case DiscountKind.percent:
        discount = percentOf(
          subtotal,
          doc.discountValue.clamp(0, 10000).toInt(),
        ).clamp(0, subtotal).toInt();
    }
    final discounts = allocate(discount, [
      for (final l in lines) l.totalCents ?? 0,
    ]);

    // 2. Service on the eligible lines, after the discount.
    var base = 0;
    for (var i = 0; i < lines.length; i++) {
      final t = lines[i].totalCents;
      if (doc.serviceOn && t != null && lines[i].service) {
        base += t - discounts[i];
      }
    }
    final serviceTotal = doc.serviceOn
        ? percentOf(base, doc.serviceBp.clamp(0, 10000).toInt())
        : 0;
    final services = allocate(serviceTotal, [
      for (var i = 0; i < lines.length; i++)
        (doc.serviceOn && lines[i].totalCents != null && lines[i].service)
            ? lines[i].totalCents! - discounts[i]
            : 0,
    ]);

    final results = [
      for (var i = 0; i < lines.length; i++)
        LineResult(lines[i], discounts[i], services[i]),
    ];
    final total = subtotal - discount + serviceTotal;

    // Groups: equivalent entries together; extras stay on their own.
    final byKey = <String, List<TabLine>>{};
    for (final l in lines) {
      byKey.putIfAbsent(l.groupKey, () => []).add(l);
    }
    final groups = [for (final e in byKey.entries) TabGroup(e.key, e.value)];

    final split = _split(doc, results, total);

    final paid = <String, int>{};
    for (final p in doc.payments) {
      paid[p.participantId] = (paid[p.participantId] ?? 0) + p.cents;
    }

    return TabResult(
      results: results,
      groups: groups,
      subtotal: subtotal,
      pendingCount: pending,
      personalOnlyCount: personalOnly,
      discount: discount,
      serviceBase: base,
      service: serviceTotal,
      total: total,
      shares: split.shares,
      unassigned: split.unassigned,
      paid: paid,
    );
  }

  static ({Map<String, int> shares, int unassigned}) _split(
    TabDoc doc,
    List<LineResult> results,
    int total,
  ) {
    final ids = [for (final p in doc.participants) p.id];
    if (ids.isEmpty) return (shares: <String, int>{}, unassigned: total);
    final shares = {for (final id in ids) id: 0};

    switch (doc.mode) {
      case SplitMode.equal:
        final chosen = [
          for (final id in ids)
            if (doc.equalIds.contains(id)) id,
        ];
        if (chosen.isEmpty) return (shares: shares, unassigned: total);
        final parts = allocate(total, List<int>.filled(chosen.length, 1));
        for (var i = 0; i < chosen.length; i++) {
          shares[chosen[i]] = parts[i];
        }
        return (shares: shares, unassigned: 0);

      case SplitMode.item:
        var unassigned = 0;
        for (final r in results) {
          final cents = r.finalCents;
          if (cents == null) continue;
          final weights = <String, int>{};
          final a = r.line.assign;
          if (a == null) {
            for (final id in ids) {
              weights[id] = 1;
            }
          } else {
            for (final id in ids) {
              final w = a[id] ?? 0;
              if (w > 0) weights[id] = w;
            }
          }
          if (weights.isEmpty) {
            unassigned += cents;
            continue;
          }
          final order = [
            for (final id in ids)
              if (weights.containsKey(id)) id,
          ];
          final parts = allocate(cents, [for (final id in order) weights[id]!]);
          for (var i = 0; i < order.length; i++) {
            shares[order[i]] = shares[order[i]]! + parts[i];
          }
        }
        return (shares: shares, unassigned: unassigned);

      case SplitMode.custom:
        var sum = 0;
        for (final id in ids) {
          final v = (doc.custom[id] ?? 0).clamp(0, 1 << 40).toInt();
          shares[id] = v;
          sum += v;
        }
        return (shares: shares, unassigned: total - sum);
    }
  }

  /// Weights of a line's cost among participants, in participant order, as the
  /// "by item" split uses them. Empty = nobody (stays unassigned).
  static Map<String, int> _weightsOf(
    Map<String, int>? assign,
    List<String> ids,
  ) {
    final weights = <String, int>{};
    if (assign == null) {
      for (final id in ids) {
        weights[id] = 1;
      }
    } else {
      for (final id in ids) {
        final w = assign[id] ?? 0;
        if (w > 0) weights[id] = w;
      }
    }
    return weights;
  }

  static bool _isDrinkLine(TabLine l) =>
      l.source == LineSource.entry ||
      l.extra?.category == ExtraCategory.drink ||
      l.extra?.category == ExtraCategory.soft;

  /// What each person owes, split in drinks, food/other, discount and service.
  /// Only the "by item" mode knows which line is whose; in the other modes the
  /// pieces are zero and only [PersonBreakdown.shareCents] is meaningful. The
  /// service row absorbs the cents of rounding so the rows always add up to the
  /// share shown in [TabResult.shares].
  static Map<String, PersonBreakdown> breakdown(TabDoc doc, TabResult r) {
    final ids = [for (final p in doc.participants) p.id];
    final drinks = {for (final id in ids) id: 0};
    final food = {for (final id in ids) id: 0};
    final discount = {for (final id in ids) id: 0};
    final service = {for (final id in ids) id: 0};
    final itemMode = doc.mode == SplitMode.item;
    if (itemMode) {
      for (final res in r.results) {
        final total = res.line.totalCents;
        if (total == null) continue;
        final weights = _weightsOf(res.line.assign, ids);
        if (weights.isEmpty) continue;
        final order = [
          for (final id in ids)
            if (weights.containsKey(id)) id,
        ];
        final w = [for (final id in order) weights[id]!];
        final base = allocate(total, w);
        final disc = allocate(res.discount, w);
        final serv = allocate(res.service, w);
        final bucket = _isDrinkLine(res.line) ? drinks : food;
        for (var i = 0; i < order.length; i++) {
          bucket[order[i]] = bucket[order[i]]! + base[i];
          discount[order[i]] = discount[order[i]]! + disc[i];
          service[order[i]] = service[order[i]]! + serv[i];
        }
      }
    }
    return {
      for (final id in ids)
        id: () {
          final share = r.shareOf(id);
          final known = drinks[id]! + food[id]! - discount[id]! + service[id]!;
          return PersonBreakdown(
            id: id,
            drinksCents: drinks[id]!,
            foodCents: food[id]!,
            discountCents: discount[id]!,
            serviceCents: itemMode
                ? service[id]! + (share - known)
                : service[id]!,
            shareCents: share,
            paidCents: r.paidBy(id),
          );
        }(),
    };
  }

  /// Key of the consumption that belongs to nobody on the tab.
  static const unassignedKey = '?';

  /// Consumption per person (never mixed with money): how many records and the
  /// known ml; unknown volumes are counted apart, never as zero. A record whose
  /// person is not on the tab is "unassigned" under [unassignedKey].
  static Map<String, PersonConsumption> consumption(
    TabDoc doc,
    Iterable<DrinkEntry> entries,
  ) {
    final acc = <String, List<int>>{}; // id -> [count, ml, unknown, alcoholic]
    String keyOf(String? raw) {
      if (raw == null || raw == ownerPortionKey) {
        return doc.me?.id ?? ownerPortionKey;
      }
      return doc.participant(raw) == null ? unassignedKey : raw;
    }

    void add(String key, int? ml, bool alcoholic) {
      final a = acc.putIfAbsent(key, () => [0, 0, 0, 0]);
      a[0]++;
      if (ml == null) {
        a[2]++;
      } else {
        a[1] += ml;
      }
      if (alcoholic) a[3]++;
    }

    for (final e in entries) {
      if (e.isDeleted) continue;
      final p = e.portions;
      if (p != null) {
        for (final kv in p.entries) {
          add(keyOf(kv.key), kv.value, e.isAlcoholic);
        }
      } else {
        add(keyOf(e.consumerId), e.personalMl, e.isAlcoholic);
      }
    }
    return {
      for (final kv in acc.entries)
        kv.key: PersonConsumption(
          count: kv.value[0],
          knownMl: kv.value[1],
          unknownCount: kv.value[2],
          alcoholicCount: kv.value[3],
        ),
    };
  }
}
