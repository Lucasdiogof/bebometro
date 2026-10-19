import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_category.dart';
import '../../l10n/l10n.dart';
import '../../tab/domain/tab_models.dart';
import '../domain/table_orders.dart';
import 'person_avatar.dart';

typedef OrderAction = void Function(OrderRow row);

/// The orders of the table (or of one person): drinks and food in one list,
/// each with its quantity, value and who it is for.
class OrdersView extends StatelessWidget {
  const OrdersView({
    super.key,
    required this.rows,
    required this.doc,
    required this.active,
    required this.onEdit,
    required this.onRepeat,
    required this.onDelete,
    required this.onMove,
  });

  final List<OrderRow> rows;
  final TabDoc doc;
  final bool active;
  final OrderAction onEdit;
  final OrderAction onRepeat;
  final OrderAction onDelete;
  final OrderAction onMove;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.xl),
        child: EmptyView(
          icon: Icons.receipt_long_outlined,
          title: tr.ordersEmptyTitle,
          message: tr.ordersEmptyBody,
        ),
      );
    }
    return Column(
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: OrderTile(
              row: r,
              doc: doc,
              active: active,
              onEdit: () => onEdit(r),
              onRepeat: () => onRepeat(r),
              onDelete: () => onDelete(r),
              onMove: () => onMove(r),
            ),
          ),
      ],
    );
  }
}

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.row,
    required this.doc,
    required this.active,
    required this.onEdit,
    required this.onRepeat,
    required this.onDelete,
    required this.onMove,
  });

  final OrderRow row;
  final TabDoc doc;
  final bool active;
  final VoidCallback onEdit;
  final VoidCallback onRepeat;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  String get _price {
    if (row.complimentary) return tr.priceComplimentary;
    final t = row.totalCents;
    return t == null ? tr.priceNone : formatCents(t);
  }

  String? get _each {
    if (row.quantity <= 1 || row.unitCents == null || row.complimentary) {
      return null;
    }
    return tr.orderEachPrice(formatCents(row.unitCents!));
  }

  String _who() {
    final ids = row.consumerIds;
    if (ids.length == doc.participants.length && ids.length > 1) {
      return tr.ordersEveryone;
    }
    return [
      for (final id in ids)
        doc.participant(id)?.displayName ?? tr.ordersUnassigned,
    ].join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final entry = row.latest;
    final icon = row.isFood
        ? row.extra!.category.icon
        : (entry?.category.icon ?? Icons.local_bar_outlined);
    final title = row.quantity > 1 ? '${row.quantity}× ${row.title}' : row.title;
    final subtitle = [
      _who(),
      if (row.shared) tr.tabShared,
      ?_each,
    ].join(' · ');
    return SurfaceCard(
      key: ValueKey('order-${row.key}'),
      onTap: onEdit,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.md,
        AppSpace.sm,
        AppSpace.xs,
        AppSpace.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.amber),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.subtitle),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _Faces(row: row, doc: doc),
                    const SizedBox(width: AppSpace.xs),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          // With a large system font the price may wrap onto two lines
          // ("R$" / "60,00") instead of squeezing the title to nothing.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: Text(
              _price,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: row.isPending ? AppColors.textMuted : AppColors.text,
              ),
            ),
          ),
          PopupMenuButton<String>(
            key: ValueKey('order-menu-${row.key}'),
            tooltip: tr.entryOptions,
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  onEdit();
                case 'repeat':
                  onRepeat();
                case 'move':
                  onMove();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(tr.entryCorrect)),
              if (active && !row.isFood)
                PopupMenuItem(value: 'repeat', child: Text(tr.entryRepeat)),
              if (active && !row.isFood && !row.shared)
                PopupMenuItem(value: 'move', child: Text(tr.ordersMoveTo)),
              PopupMenuItem(
                value: 'delete',
                child: Text(row.quantity > 1 ? tr.ordersDeleteOne : tr.commonDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Faces extends StatelessWidget {
  const _Faces({required this.row, required this.doc});

  final OrderRow row;
  final TabDoc doc;

  @override
  Widget build(BuildContext context) {
    final people = [
      for (final id in row.consumerIds)
        if (doc.participant(id) != null) doc.participant(id)!,
    ];
    if (people.isEmpty) {
      return const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.textMuted);
    }
    final shown = people.take(3).toList();
    return SizedBox(
      width: 18.0 + (shown.length - 1) * 13,
      height: 18,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * 13.0,
              child: PersonAvatar(
                person: shown[i],
                size: 18,
                index: doc.participants.indexOf(shown[i]),
              ),
            ),
        ],
      ),
    );
  }
}

/// A category icon shared by the add button labels.
IconData iconFor(DrinkCategory c) => c.icon;
