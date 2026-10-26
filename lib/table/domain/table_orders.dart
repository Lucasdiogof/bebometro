import '../../drinks/domain/drink_entry.dart';
import '../../tab/domain/tab_calc.dart';
import '../../tab/domain/tab_models.dart';

/// Which part of the table the screen shows: the whole table, or one person.
class PersonFilter {
  const PersonFilter.table() : personId = null;
  const PersonFilter.person(String this.personId);

  /// Participant id; null = the whole table ("Mesa").
  final String? personId;

  bool get isTable => personId == null;

  @override
  bool operator ==(Object other) =>
      other is PersonFilter && other.personId == personId;

  @override
  int get hashCode => personId.hashCode;
}

/// One line of the orders list: servings that are the same order for the same
/// people, or one food/extra item. Only a presentation; every unit keeps its
/// own record and can be corrected or deleted.
class OrderRow {
  const OrderRow({
    required this.key,
    required this.title,
    required this.quantity,
    required this.consumerIds,
    required this.at,
    this.entries = const [],
    this.extra,
    this.totalCents,
    this.unitCents,
    this.complimentary = false,
    this.shared = false,
    this.detail,
    this.payerIds = const [],
  });

  final String key;
  final String title;
  final int quantity;

  /// Participant ids that consumed/take part (the owner as his own id).
  /// "?" stands for a record whose person is not on the tab.
  final List<String> consumerIds;
  final DateTime at;
  final List<DrinkEntry> entries;
  final TabExtra? extra;

  /// Cost of the whole row; null while any price in it is unknown.
  final int? totalCents;
  final int? unitCents;
  final bool complimentary;
  final bool shared;
  final String? detail;

  /// Participant ids that bear the cost ("?" = a payer not on the tab).
  /// Independent from [consumerIds].
  final List<String> payerIds;

  /// The payers are other than the consumers (worth showing on the row).
  bool get payersDiffer {
    final a = {...payerIds}, b = {...consumerIds};
    return payerIds.isNotEmpty && (a.length != b.length || !a.containsAll(b));
  }

  bool get isFood => extra != null;
  bool get isPending => totalCents == null;

  /// The newest unit (what "Mais uma" repeats and what a correction opens).
  DrinkEntry? get latest => entries.isEmpty ? null : entries.last;
}

class TableOrders {
  const TableOrders._();

  /// Participant ids that consumed [e], with the owner as [doc]'s own id.
  static List<String> consumersOf(DrinkEntry e, TabDoc doc) {
    String keyOf(String? raw) {
      if (raw == null || raw == ownerPortionKey) {
        return doc.me?.id ?? ownerPortionKey;
      }
      return doc.participant(raw) == null ? TabCalculator.unassignedKey : raw;
    }

    final p = e.portions;
    if (p != null) return [for (final k in p.keys) keyOf(k)];
    return [keyOf(e.consumerId)];
  }

  /// Who consumed an extra: the people it names, or (lines made before
  /// consumers existed) the people it was split among, or everybody.
  static List<String> _takersOf(TabExtra x, TabDoc doc) {
    final named = x.consumers;
    if (named != null) {
      return [
        for (final id in named)
          if (doc.participant(id) != null) id else TabCalculator.unassignedKey,
      ];
    }
    return x.assign == null
        ? [for (final p in doc.participants) p.id]
        : [
            for (final p in doc.participants)
              if (x.assign!.containsKey(p.id)) p.id,
          ];
  }

  /// Who bears the cost of an extra (everybody when nothing says otherwise).
  static List<String> _extraPayersOf(TabExtra x, TabDoc doc) => x.assign == null
      ? [for (final p in doc.participants) p.id]
      : [
          for (final k in x.assign!.keys)
            if (doc.participant(k) != null) k else TabCalculator.unassignedKey,
        ];

  /// Who bears the cost of a drink record: a typed split on the tab, the
  /// record's own payers, or (older records) the people who drank it.
  static List<String> payersOf(DrinkEntry e, TabDoc doc) {
    final typed = doc.linkFor(e.id)?.assign;
    if (typed != null) {
      return [
        for (final k in typed.keys)
          if (doc.participant(k) != null) k else TabCalculator.unassignedKey,
      ];
    }
    final p = e.payers;
    if (p == null) return consumersOf(e, doc);
    return [
      for (final k in p.keys)
        if (k == ownerPortionKey)
          doc.me?.id ?? ownerPortionKey
        else if (doc.participant(k) != null)
          k
        else
          TabCalculator.unassignedKey,
    ];
  }

  /// Orders of the outing for [filter], newest first.
  static List<OrderRow> rows(
    TabDoc doc,
    Map<String, DrinkEntry> entries,
    PersonFilter filter,
  ) {
    final out = <OrderRow>[];
    final groups = <String, List<DrinkEntry>>{};
    final consumers = <String, List<String>>{};
    final payers = <String, List<String>>{};

    for (final e in entries.values) {
      if (e.isDeleted) continue;
      final who = consumersOf(e, doc);
      if (!filter.isTable && !who.contains(filter.personId)) continue;
      final line = TabCalculator.entryLine(e, TabLink(entryId: e.id));
      final pay = payersOf(e, doc);
      final key = '${line.groupKey}|${[...who]..sort()}|${[...pay]..sort()}';
      groups.putIfAbsent(key, () => []).add(e);
      consumers[key] = who;
      payers[key] = pay;
    }
    for (final kv in groups.entries) {
      final list = kv.value
        ..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
      final first = TabCalculator.entryLine(
        list.first,
        TabLink(entryId: list.first.id),
      );
      final total = first.totalCents == null
          ? null
          : first.totalCents! * list.length;
      out.add(
        OrderRow(
          key: kv.key,
          title: first.title,
          quantity: list.length,
          consumerIds: consumers[kv.key]!,
          at: list.last.consumedAt,
          entries: list,
          totalCents: total,
          unitCents: first.totalCents,
          complimentary: first.complimentary,
          shared: list.first.isShared,
          detail: first.detail,
          payerIds: payers[kv.key]!,
        ),
      );
    }

    for (final x in doc.extras) {
      final who = _takersOf(x, doc);
      if (!filter.isTable && !who.contains(filter.personId)) continue;
      out.add(
        OrderRow(
          key: 'x|${x.id}',
          title: x.description.isEmpty ? x.category.label : x.description,
          quantity: x.quantity,
          consumerIds: who,
          at: x.createdAt,
          extra: x,
          totalCents: x.totalCents,
          unitCents: x.basis == PriceBasis.unit ? x.cents : null,
          complimentary: x.priceKind == PriceKind.complimentary,
          detail: x.category.label,
          payerIds: _extraPayersOf(x, doc),
        ),
      );
    }
    out.sort((a, b) => b.at.compareTo(a.at));
    return out;
  }

  /// Units on the table: every live drink record plus every unit of the extras
  /// (a dish with quantity 2 is two). This is the number of the "Itens" tile;
  /// the list heading counts [rows] (one row groups equal orders, so
  /// "4x Chopp" is one row and four items).
  static int itemCount(TabDoc doc, Iterable<DrinkEntry> entries) {
    var n = 0;
    for (final e in entries) {
      if (!e.isDeleted) n++;
    }
    for (final x in doc.extras) {
      n += x.quantity < 1 ? 1 : x.quantity;
    }
    return n;
  }

  /// The order row of one drink record, never a food/extra row. [rows] puts
  /// extras in the list too, so `rows(...).first` is not "the row of this
  /// record" when a dish was added after the drink.
  static OrderRow? rowOfEntry(TabDoc doc, DrinkEntry entry) {
    for (final r in rows(doc, {entry.id: entry}, const PersonFilter.table())) {
      if (r.extra == null && r.entries.any((e) => e.id == entry.id)) return r;
    }
    return null;
  }

  /// People shown as present (not left), owner first, in tab order.
  static List<Participant> present(TabDoc doc) => doc.present;

  /// Who should be preselected for a new item: the filter's person, or
  /// everyone present when the whole table is shown but only if the caller
  /// asked for "everybody" (food). Never an automatic guess for drinks.
  static Set<String> preselect(TabDoc doc, PersonFilter filter) =>
      filter.isTable ? <String>{} : {filter.personId!};
}
