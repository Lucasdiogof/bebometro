import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../scan/presentation/photo_widgets.dart';
import '../data/outing_drink_repository.dart';
import '../domain/outing_drink.dart';
import 'outing_drink_review_page.dart';

/// "Bebidas deste rolê": items that exist only in this outing (manual, label
/// or menu). Choosing one opens the usual registration form; picking it here
/// is not a consumption by itself.
class OutingDrinksSection extends StatefulWidget {
  const OutingDrinksSection({
    super.key,
    required this.outingId,
    required this.onRegister,
  });

  final String outingId;
  final ValueChanged<OutingDrink> onRegister;

  @override
  State<OutingDrinksSection> createState() => _OutingDrinksSectionState();
}

class _OutingDrinksSectionState extends State<OutingDrinksSection> {
  final _repo = getIt<OutingDrinkRepository>();
  StreamSubscription<void>? _sub;
  var _items = <OutingDrink>[];

  @override
  void initState() {
    super.initState();
    _items = _repo.forOuting(widget.outingId);
    _sub = _repo.changes.listen((_) {
      if (mounted) setState(() => _items = _repo.forOuting(widget.outingId));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _edit(OutingDrink d) async {
    await Navigator.of(context).push<ReviewResult>(
      MaterialPageRoute(
        builder: (_) =>
            OutingDrinkReviewPage(outingId: widget.outingId, existing: d),
      ),
    );
  }

  Future<void> _remove(OutingDrink d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tirar da lista do rolê?'),
        content: const Text(
            'Ela sai de "Bebidas deste rolê". Os registros que você já fez '
            'continuam no histórico.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tirar',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await _repo.remove(d.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Bebidas deste rolê'),
        const Text('Só existem neste rolê. Toque para registrar uma.',
            style: AppText.caption),
        const SizedBox(height: AppSpace.sm),
        for (final d in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: SurfaceCard(
              onTap: () => widget.onRegister(d),
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.md, AppSpace.sm, AppSpace.xs, AppSpace.sm),
              child: Row(children: [
                if (d.photoIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpace.md),
                    child: PhotoThumb(photoId: d.photoIds.first, size: 44),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpace.md),
                    child: Icon(d.category.icon, color: AppColors.amber),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.subtitle),
                      Text(_subtitle(d),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Mais ações',
                  onSelected: (v) {
                    if (v == 'edit') _edit(d);
                    if (v == 'remove') _remove(d);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(
                        value: 'remove', child: Text('Tirar da lista')),
                  ],
                ),
              ]),
            ),
          ),
      ],
    );
  }

  String _subtitle(OutingDrink d) {
    final parts = <String>[
      d.category.label,
      if (d.volumeMl != null) formatMl(d.volumeMl!),
      if (d.abvPercent != null) formatAbv(d.abvPercent!),
      if (d.advertisedCents != null)
        'cardápio ${formatCents(d.advertisedCents!)}',
    ];
    return parts.join(' · ');
  }
}
