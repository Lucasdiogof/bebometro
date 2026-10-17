import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_field.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_entry.dart';
import 'price_fix_cubit.dart';
import '../../l10n/l10n.dart';

/// Fill in missing prices of an outing: one by one, or one price for several
/// equivalent records after a preview.
class PriceFixPage extends StatelessWidget {
  const PriceFixPage({super.key, required this.outingId});

  final String outingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PriceFixCubit>(param1: outingId),
      child: const _PriceFixView(),
    );
  }
}

class _PriceFixView extends StatelessWidget {
  const _PriceFixView();

  Future<void> _applyBatch(BuildContext context) async {
    final cubit = context.read<PriceFixCubit>();
    final rows = cubit.preview();
    final replaced = rows.where((r) => r.replaces).length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.priceFixApplyTitle(rows.length)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (replaced > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: Text(
                    tr.priceFixReplaced(replaced),
                    style: const TextStyle(color: AppColors.amber),
                  ),
                ),
              for (final r in rows)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    r.entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${formatTime(r.entry.consumedAt)}'
                    '${r.entry.isShared ? ' · ${tr.priceFixYourShare}' : ''}',
                    style: AppText.caption,
                  ),
                  trailing: Text(
                    '${r.before} → ${r.after}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: r.replaces ? AppColors.amber : AppColors.text,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.commonSave),
          ),
        ],
      ),
    );
    if (ok == true) {
      await cubit.apply();
      if (context.mounted) showToast(context, tr.priceFixUpdated);
    }
  }

  Future<void> _editOne(BuildContext context, DrinkEntry e) async {
    final cubit = context.read<PriceFixCubit>();
    final controller = TextEditingController(
      text: e.priceKind == PriceKind.informed && e.paidCents != null
          ? centsToInput(e.paidCents!)
          : '',
    );
    String? error;
    final result = await showDialog<_One>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(e.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MoneyField(
                controller: controller,
                autofocus: true,
                label: e.isShared
                    ? tr.priceFixPaidShared
                    : tr.priceFixPaidLabel,
                errorText: error,
                onChanged: (_) {
                  if (error != null) setState(() => error = null);
                },
              ),
              if (e.isShared)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Text(tr.priceFixSharedNote, style: AppText.caption),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, const _One.complimentary()),
              child: Text(tr.priceComplimentary),
            ),
            TextButton(
              onPressed: () {
                final cents = parseCents(controller.text);
                if (cents == null) {
                  setState(
                    () => error =
                        numberInputError(controller.text) ??
                        tr.priceFixEnterValue,
                  );
                  return;
                }
                Navigator.pop(ctx, _One(cents));
              },
              child: Text(tr.commonSave),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result == null) return;
    await cubit.applyTo(
      e,
      cents: result.cents,
      complimentary: result.complimentary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PriceFixCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(tr.priceFixTitle)),
      body: BlocBuilder<PriceFixCubit, PriceFixState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.groups.isEmpty
                    ? EmptyView(
                        icon: Icons.check_circle_outline_rounded,
                        title: tr.priceFixNoneTitle,
                        message: tr.priceFixNoneBody,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpace.gutter,
                          0,
                          AppSpace.gutter,
                          AppSpace.xl,
                        ),
                        children: [
                          Text(tr.priceFixIntro, style: AppText.caption),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(tr.priceFixIncludePriced),
                            value: state.includePriced,
                            activeThumbColor: AppColors.amber,
                            onChanged: cubit.setIncludePriced,
                          ),
                          SectionTitle(tr.priceFixForSelected),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: MoneyField(
                                  enabled: !state.complimentary,
                                  label: tr.priceFixPaidLabel,
                                  onChanged: cubit.setPrice,
                                ),
                              ),
                              const SizedBox(width: AppSpace.sm),
                              FilterChip(
                                label: Text(tr.priceComplimentary),
                                selected: state.complimentary,
                                showCheckmark: false,
                                onSelected: cubit.setComplimentary,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpace.xs),
                            child: Text(
                              tr.priceFixSharedHint,
                              style: AppText.caption,
                            ),
                          ),
                          for (final g in state.groups) ...[
                            SectionTitle(g.label),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => cubit.selectGroup(g, true),
                                  child: Text(
                                    tr.priceFixSelectAll('${g.entries.length}'),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => cubit.selectGroup(g, false),
                                  child: Text(tr.priceFixClear),
                                ),
                              ],
                            ),
                            for (final e in g.entries)
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                activeColor: AppColors.amber,
                                value: state.selected.contains(e.id),
                                onChanged: (_) => cubit.toggle(e.id),
                                title: Text(formatDateTime(e.consumedAt)),
                                subtitle: Text(switch (e.priceKind) {
                                  PriceKind.informed => tr.priceFixCurrent(
                                    formatCents(e.paidCents ?? 0),
                                  ),
                                  PriceKind.complimentary =>
                                    tr.priceComplimentary,
                                  PriceKind.unknown => tr.priceNone,
                                }, style: AppText.caption),
                                secondary: IconButton(
                                  tooltip: tr.priceFixOnlyThis,
                                  onPressed: () => _editOne(context, e),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                              ),
                          ],
                        ],
                      ),
              ),
              BottomActionBar(
                child: FilledButton(
                  onPressed: state.canApply ? () => _applyBatch(context) : null,
                  child: Text(
                    state.selected.isEmpty
                        ? tr.priceFixSelectRecords
                        : tr.priceFixPreview('${state.selected.length}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _One {
  const _One(this.cents) : complimentary = false;
  const _One.complimentary() : cents = null, complimentary = true;

  final int? cents;
  final bool complimentary;
}
