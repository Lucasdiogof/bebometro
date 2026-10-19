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

  static List<String> _takersOf(TabExtra x, TabDoc doc) =>
      x.assign == null
      ? [for (final p in doc.participants) p.id]
      : [
          for (final p in doc.participants)
            if (x.assign!.containsKey(p.id)) p.id,
        ];

  /// Orders of the outing for [filter], newest first.
  static List<OrderRow> rows(
    TabDoc doc,
    Map<String, DrinkEntry> entries,
    PersonFilter filter,
  ) {
    final out = <OrderRow>[];
    final groups = <String, List<DrinkEntry>>{};
    final consumers = <String, List<String>>{};

    for (final e in entries.values) {
      if (e.isDeleted) continue;
      final who = consumersOf(e, doc);
      if (!filter.isTable && !who.contains(filter.personId)) continue;
      final line = TabCalculator.entryLine(e, TabLink(entryId: e.id));
      final key = '${line.groupKey}|${[...who]..sort()}';
      groups.putIfAbsent(key, () => []).add(e);
      consumers[key] = who;
    }
    for (final kv in groups.entries) {
      final list = kv.value..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
      final first = TabCalculator.entryLine(list.first, TabLink(entryId: list.first.id));
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
        ),
      );
    }
    out.sort((a, b) => b.at.compareTo(a.at));
    return out;
  }

  /// People shown as present (not left), owner first, in tab order.
  static List<Participant> present(TabDoc doc) => doc.present;

  /// Who should be preselected for a new item: the filter's person, or
  /// everyone present when the whole table is shown but only if the caller
  /// asked for "everybody" (food). Never an automatic guess for drinks.
  static Set<String> preselect(TabDoc doc, PersonFilter filter) =>
      filter.isTable ? <String>{} : {filter.personId!};
}
