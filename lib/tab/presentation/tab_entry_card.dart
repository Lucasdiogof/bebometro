import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../data/tab_repository.dart';
import '../domain/tab_calc.dart';
import '../domain/tab_models.dart';
import 'tab_page.dart';

/// Access to the tab from inside an outing and from its summary. It is not a
/// tab of the main navigation. Totals here are the tab's own: they are never
/// added to the spending recorded on drinks, which keeps its own meaning.
class TabEntryCard extends StatefulWidget {
  const TabEntryCard({super.key, required this.outingId, this.detailed = false});

  final String outingId;

  /// In the summary: separate lines for the tab's total and the user's part.
  final bool detailed;

  @override
  State<TabEntryCard> createState() => _TabEntryCardState();
}

class _TabEntryCardState extends State<TabEntryCard> {
  final _repo = getIt<TabRepository>();
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _repo.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = _repo.load(widget.outingId);
    final used = !doc.isEmpty;
    final TabResult? r = used ? _repo.compute(widget.outingId) : null;
    final me = doc.me;
    final mine = (r != null && me != null && doc.participants.length > 1)
        ? r.shareOf(me.id)
        : null;
    final partial = r != null && (r.isPartial || r.unassigned != 0);

    final lines = <String>[];
    if (r == null) {
      lines.add('Opcional: petiscos, serviço e divisão da conta.');
    } else if (widget.detailed) {
      lines.add('${r.isPartial ? 'Total da comanda (parcial)' : 'Total da comanda'}: '
          '${formatCents(r.total)}');
      if (mine != null) {
        lines.add('Sua parte da comanda${partial ? ' (provisória)' : ''}: '
            '${formatCents(mine)}');
      }
    } else {
      lines.add('${r.isPartial ? 'Total conhecido' : 'Total'} '
          '${formatCents(r.total)}'
          '${mine == null ? '' : ' · sua parte ${formatCents(mine)}'}');
    }

    return SurfaceCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TabPage(outingId: widget.outingId),
      )),
      child: Row(children: [
        const Icon(Icons.receipt_long_outlined, color: AppColors.amber),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Comanda', style: AppText.subtitle),
              for (final l in lines) Text(l, style: AppText.caption),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      ]),
    );
  }
}
