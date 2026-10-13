import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../outings/presentation/outing_summary_page.dart';

/// The records (or outings) that make up a number shown in the statistics.
class RecordsPage extends StatelessWidget {
  const RecordsPage.entries({
    super.key,
    required this.title,
    required List<DrinkEntry> this.entries,
  }) : outings = null;

  const RecordsPage.outings({
    super.key,
    required this.title,
    required List<Outing> this.outings,
  }) : entries = null;

  final String title;
  final List<DrinkEntry>? entries;
  final List<Outing>? outings;

  @override
  Widget build(BuildContext context) {
    final repo = getIt<OutingRepository>();
    final rows = <Widget>[];
    if (outings != null) {
      for (final o in outings!) {
        rows.add(_row(
          context,
          title: o.displayName,
          subtitle: '${formatDate(o.startedAt)} · ${formatTime(o.startedAt)}'
              '${o.isActive ? ' · em andamento' : ''}',
          outingId: o.id,
        ));
      }
    } else {
      final sorted = [...entries!]
        ..sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
      for (final e in sorted) {
        final outing = repo.byId(e.outingId);
        rows.add(_row(
          context,
          title: e.name,
          subtitle: '${formatDateTime(e.consumedAt)}'
              '${e.personalMl == null ? ' · volume desconhecido' : ' · ${formatMl(e.personalMl!)}'}'
              '${outing == null ? '' : ' · ${outing.displayName}'}',
          trailing: switch (e.priceKind) {
            PriceKind.informed => formatCents(e.paidCents ?? 0),
            PriceKind.complimentary => 'Cortesia',
            PriceKind.unknown => 'Sem preço',
          },
          outingId: e.outingId,
        ));
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
        children: rows,
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? trailing,
    required String outingId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: SurfaceCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OutingSummaryPage(outingId: outingId))),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subtitle),
                Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          if (trailing != null)
            Text(trailing, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}
