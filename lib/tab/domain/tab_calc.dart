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

  /// Positive = still has to pay; negative = paid more than the share.
  int balanceOf(String id) => shareOf(id) - paidBy(id);
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

  static TabLine entryLine(DrinkEntry e, TabLink link) {
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
      assign: link.assign,
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

  /// Lines of the tab, oldest first. A link whose record was deleted shows
  /// nothing (and comes back if the deletion is undone).
  static List<TabLine> lines(TabDoc doc, Map<String, DrinkEntry> entries) {
    final out = <TabLine>[];
    for (final link in doc.links) {
      final e = entries[link.entryId];
      if (e == null || e.isDeleted) continue;
      out.add(entryLine(e, link));
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
      if (doc.serviceOn && t != null && lines[i].service)
        base += t - discounts[i];
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
}
