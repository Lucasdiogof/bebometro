import '../../drinks/domain/drink_entry.dart';
import 'drink_vessel.dart';

/// One thing on the table: a single record, a group of identical records
/// ("×3"), or the "+N" tile that holds what did not fit.
class TableItem {
  const TableItem(this.entries, {this.isOverflow = false});

  /// Records in time order. Never empty.
  final List<DrinkEntry> entries;

  /// The "+N" tile: opens the list of the records that are not drawn.
  final bool isOverflow;

  int get count => entries.length;

  /// The vessel shown for the item is the newest record's.
  DrinkEntry get lead => entries.last;

  /// Stable across updates so animations and positions are not reset.
  String get key => isOverflow
      ? 'overflow'
      : (count == 1
            ? 'e:${entries.first.id}'
            : 'g:${_groupKey(entries.first)}');
}

String _groupKey(DrinkEntry e) =>
    '${vesselKindFor(e).name}|${e.name}|${e.presentation}|${e.personalMl}|'
    '${e.isShared}|${e.composition?.customized}';

class Slot {
  const Slot({
    required this.cx,
    required this.baseY,
    required this.scale,
    required this.row,
  });

  /// Horizontal centre and the y of the vessel's base.
  final double cx;
  final double baseY;
  final double scale;
  final int row;
}

class TablePlan {
  const TablePlan({
    required this.items,
    required this.slots,
    required this.height,
    required this.tableTop,
    required this.cols,
    required this.compact,
  });

  /// `items[i]` sits at `slots[i]`.
  final List<TableItem> items;
  final List<Slot> slots;
  final double height;

  /// y where the table surface starts.
  final double tableTop;
  final int cols;
  final bool compact;
}

/// Positions the records on a two-row table.
///
/// * Each record has a fixed slot (by order), so existing vessels do not move
///   when a new one is added.
/// * Up to `capacity` records are drawn one by one. Beyond that, identical
///   records are grouped with a count; if there are still too many groups,
///   the last slot becomes a "+N" tile.
TablePlan planTable(
  List<DrinkEntry> entries,
  double width, {
  bool compact = false,
}) {
  final height = compact ? 200.0 : 300.0;
  final baseScale = compact ? 0.7 : 1.0;
  final cols = (width / (60 * baseScale + 10)).floor().clamp(2, 8).toInt();
  final capacity = cols * 2;
  final tableTop = height * 0.46;
  final depth = height - tableTop;

  final items = <TableItem>[];
  if (entries.length <= capacity) {
    for (final e in entries) {
      items.add(TableItem([e]));
    }
  } else {
    final groups = <String, List<DrinkEntry>>{};
    for (final e in entries) {
      groups.putIfAbsent(_groupKey(e), () => []).add(e);
    }
    final list = groups.values.toList();
    if (list.length <= capacity) {
      for (final g in list) {
        items.add(TableItem(g));
      }
    } else {
      for (final g in list.take(capacity - 1)) {
        items.add(TableItem(g));
      }
      final rest = [for (final g in list.skip(capacity - 1)) ...g]
        ..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
      items.add(TableItem(rest, isOverflow: true));
    }
  }

  final slots = <Slot>[
    for (var i = 0; i < items.length; i++)
      Slot(
        cx: ((i % cols) + 0.5) * width / cols,
        row: i ~/ cols,
        baseY: tableTop + (i ~/ cols == 0 ? 0.32 : 0.82) * depth,
        scale: baseScale * (i ~/ cols == 0 ? 0.82 : 1.0),
      ),
  ];

  return TablePlan(
    items: items,
    slots: slots,
    height: height,
    tableTop: tableTop,
    cols: cols,
    compact: compact,
  );
}
