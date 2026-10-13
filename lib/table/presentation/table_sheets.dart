import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_entry.dart';
import '../domain/drink_vessel.dart';
import '../domain/table_scenario.dart';
import '../../drinks/domain/presentation_label.dart';
import '../../l10n/l10n.dart';

/// Details of one record, with the existing edit and delete actions.
Future<void> showEntryDetailSheet(
  BuildContext context,
  DrinkEntry entry, {
  required void Function(DrinkEntry) onEdit,
  required void Function(DrinkEntry) onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _EntryDetail(
      entry: entry,
      onEdit: (e) {
        Navigator.pop(ctx);
        onEdit(e);
      },
      onDelete: (e) {
        Navigator.pop(ctx);
        onDelete(e);
      },
    ),
  );
}

/// The records behind a "×N" group or the "+N" tile; each one opens its detail.
Future<void> showEntryGroupSheet(
  BuildContext context,
  String title,
  List<DrinkEntry> entries, {
  required void Function(DrinkEntry) onEdit,
  required void Function(DrinkEntry) onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
              AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
          children: [
            Text(title, style: AppText.title),
            const SizedBox(height: AppSpace.sm),
            for (final e in entries.reversed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(_summaryLine(e), style: AppText.caption),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showEntryDetailSheet(ctx, e, onEdit: (x) {
                    Navigator.pop(ctx);
                    onEdit(x);
                  }, onDelete: (x) {
                    Navigator.pop(ctx);
                    onDelete(x);
                  });
                },
              ),
          ],
        ),
      ),
    ),
  );
}

String _summaryLine(DrinkEntry e) => [
      formatTime(e.consumedAt),
      if (e.personalMl != null)
        formatMl(e.personalMl!)
      else
        tr.recordsUnknownVolume,
      _price(e),
    ].join(' · ');

String _price(DrinkEntry e) => switch (e.priceKind) {
      PriceKind.informed => formatCents(e.paidCents ?? 0),
      PriceKind.complimentary => tr.priceComplimentary,
      PriceKind.unknown => tr.priceNone,
    };

class _EntryDetail extends StatelessWidget {
  const _EntryDetail({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final DrinkEntry entry;
  final void Function(DrinkEntry) onEdit;
  final void Function(DrinkEntry) onDelete;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final kind = vesselKindFor(e);
    final personal = e.personalMl;
    final container = e.containerMl;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.name, style: AppText.title),
            const SizedBox(height: AppSpace.xs),
            Text(
              [
                kind.label,
                if (e.presentation != null) localizePresentation(e.presentation!),
              ].join(' · '),
              style: AppText.caption,
            ),
            const SizedBox(height: AppSpace.lg),
            _Line(Icons.schedule_rounded, tr.entryTimeSection,
                formatDateTime(e.consumedAt)),
            _Line(
              Icons.opacity_rounded,
              tr.tableYourVolume,
              personal == null ? tr.detailNotGiven : formatMl(personal),
            ),
            if (e.isShared && personal != null && container != null)
              _Line(
                Icons.groups_outlined,
                tr.entryShared,
                tr.tableSharedLine(formatMl(personal), formatMl(container),
                    e.peopleCount),
              ),
            _Line(Icons.payments_outlined, tr.tabFillPriceTitle, _price(e)),
            if (e.isMixed && e.composition!.customized)
              _Line(Icons.tune_rounded, tr.entryCompositionTitle,
                  tr.tableRecipeAdjusted),
            const SizedBox(height: AppSpace.lg),
            FilledButton.icon(
              onPressed: () => onEdit(e),
              icon: const Icon(Icons.edit_outlined),
              label: Text(tr.entryFix),
            ),
            const SizedBox(height: AppSpace.xs),
            Center(
              child: TextButton.icon(
                onPressed: () => onDelete(e),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.danger),
                label: Text(tr.commonDelete,
                    style: const TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.amber),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.caption),
                Text(value, style: AppText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lets the user change the scenery. Only the illustration changes.
Future<void> showScenarioPicker(
  BuildContext context, {
  required TableScenario current,
  required ValueChanged<TableScenario> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.tableScenarioTitle, style: AppText.title),
            const SizedBox(height: AppSpace.xs),
            Text(tr.tableScenarioNote, style: AppText.caption),
            const SizedBox(height: AppSpace.lg),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final s in TableScenario.values)
                  ChoiceChip(
                    avatar: Icon(s.icon,
                        size: 18,
                        color: s == current
                            ? const Color(0xFF241800)
                            : AppColors.amber),
                    label: Text(s.label),
                    selected: s == current,
                    showCheckmark: false,
                    onSelected: (_) {
                      onSelected(s);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// The short explanation reachable from the table's menu.
Future<void> showTableAbout(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr.tableAboutTitle),
      content: Text(tr.tableAboutBody),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: Text(tr.tableUnderstood)),
      ],
    ),
  );
}
