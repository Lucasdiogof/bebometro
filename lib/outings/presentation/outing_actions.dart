import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../drinks/data/drink_repository.dart';
import '../../l10n/l10n.dart';
import '../data/outing_repository.dart';
import '../domain/outing.dart';
import 'outing_type_picker.dart';

/// Corrects the kind of outing and its start time (the place, budget and
/// people have their own entries). The start cannot move after a record that
/// already exists in the outing, nor into the future.
Future<void> showEditOutingSheet(BuildContext context, Outing outing) async {
  var type = outing.type;
  var start = outing.startedAt;
  String? error;
  var busy = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpace.gutter,
          0,
          AppSpace.gutter,
          MediaQuery.of(ctx).viewInsets.bottom + AppSpace.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.outingEditTitle, style: AppText.title),
              SectionTitle(tr.outingEditKind),
              OutingTypePicker(
                selected: type,
                onSelected: (t) => setSheet(() => type = t),
              ),
              SectionTitle(tr.outingEditStart),
              SurfaceCard(
                onTap: () async {
                  final picked = await pickDateTime(ctx, start);
                  if (picked != null) setSheet(() => start = picked);
                },
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppColors.amber),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text(
                        '${formatDate(start)} · ${formatTime(start)}',
                        style: AppText.subtitle,
                      ),
                    ),
                    const Icon(Icons.edit_outlined, color: AppColors.textMuted),
                  ],
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Text(
                    error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              const SizedBox(height: AppSpace.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          setSheet(() {
                            busy = true;
                            error = null;
                          });
                          try {
                            final records = getIt<DrinkRepository>().entriesFor(
                              outing.id,
                            );
                            await getIt<OutingRepository>().edit(
                              outing.id,
                              type: type,
                              startedAt: start,
                              earliestRecord: records.isEmpty
                                  ? null
                                  : records.first.consumedAt,
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          } on ArgumentError catch (e) {
                            setSheet(() {
                              busy = false;
                              error = '${e.message}';
                            });
                          }
                        },
                  child: Text(tr.commonSave),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Asks, then removes the outing and its records from every list (soft delete:
/// the tombstone reaches the other devices). Returns true when it was deleted.
Future<bool> confirmDeleteOuting(BuildContext context, Outing outing) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr.outingDeleteTitle),
      content: Text(tr.outingDeleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(tr.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            tr.commonDelete,
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  final drinks = getIt<DrinkRepository>();
  for (final e in drinks.entriesFor(outing.id)) {
    await drinks.delete(e.id);
  }
  await getIt<OutingRepository>().delete(outing.id);
  if (context.mounted) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    showToast(context, tr.outingDeleted);
  }
  return true;
}
