import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_entry.dart';
import 'price_fix_cubit.dart';

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
        title: Text('Aplicar a ${rows.length} '
            '${rows.length == 1 ? 'registro' : 'registros'}?'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (replaced > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: Text(
                    '$replaced já tinha${replaced == 1 ? '' : 'm'} preço e '
                    'será substituído${replaced == 1 ? '' : 's'}.',
                    style: const TextStyle(color: AppColors.amber),
                  ),
                ),
              for (final r in rows)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(r.entry.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${formatTime(r.entry.consumedAt)}'
                    '${r.entry.isShared ? ' · sua parcela' : ''}',
                    style: AppText.caption,
                  ),
                  trailing: Text('${r.before} → ${r.after}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: r.replaces ? AppColors.amber : AppColors.text,
                      )),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (ok == true) {
      await cubit.apply();
      if (context.mounted) showToast(context, 'Preços atualizados');
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
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText:
                      e.isShared ? 'Quanto você pagou' : 'Preço pago',
                  prefixText: r'R$ ',
                  errorText: error,
                ),
              ),
              if (e.isShared)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpace.sm),
                  child: Text(
                    'Bebida compartilhada: informe a sua parcela, não o '
                    'preço da garrafa. O consumo não muda.',
                    style: AppText.caption,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, const _One.complimentary()),
                child: const Text('Cortesia')),
            TextButton(
              onPressed: () {
                final cents = parseCents(controller.text);
                if (cents == null) {
                  setState(() => error = 'Informe um valor');
                  return;
                }
                Navigator.pop(ctx, _One(cents));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result == null) return;
    await cubit.applyTo(e,
        cents: result.cents, complimentary: result.complimentary);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PriceFixCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Preços ausentes')),
      body: BlocBuilder<PriceFixCubit, PriceFixState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.groups.isEmpty
                    ? const EmptyView(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Nenhum preço ausente',
                        message: 'Todos os registros deste rolê têm preço ou '
                            'cortesia informados.',
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0,
                            AppSpace.gutter, AppSpace.xl),
                        children: [
                          const Text(
                            'Preencha um por um, ou escolha vários registros '
                            'iguais e aplique o mesmo preço depois de ver a '
                            'prévia. Preços já informados não mudam, a menos '
                            'que você os inclua e selecione de propósito.',
                            style: AppText.caption,
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                                'Incluir também registros que já têm preço'),
                            value: state.includePriced,
                            activeThumbColor: AppColors.amber,
                            onChanged: cubit.setIncludePriced,
                          ),
                          const SectionTitle('Preço para os selecionados'),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  enabled: !state.complimentary,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Preço pago',
                                    prefixText: r'R$ ',
                                  ),
                                  onChanged: (v) => cubit.setPrice(parseCents(v)),
                                ),
                              ),
                              const SizedBox(width: AppSpace.sm),
                              FilterChip(
                                label: const Text('Cortesia'),
                                selected: state.complimentary,
                                showCheckmark: false,
                                onSelected: cubit.setComplimentary,
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: AppSpace.xs),
                            child: Text(
                              'Em bebida compartilhada vale o que você pagou '
                              '(sua parcela), nunca o preço da garrafa.',
                              style: AppText.caption,
                            ),
                          ),
                          for (final g in state.groups) ...[
                            SectionTitle(g.label),
                            Row(children: [
                              TextButton(
                                onPressed: () => cubit.selectGroup(g, true),
                                child: Text('Selecionar os ${g.entries.length}'),
                              ),
                              TextButton(
                                onPressed: () => cubit.selectGroup(g, false),
                                child: const Text('Limpar'),
                              ),
                            ]),
                            for (final e in g.entries)
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                activeColor: AppColors.amber,
                                value: state.selected.contains(e.id),
                                onChanged: (_) => cubit.toggle(e.id),
                                title: Text(formatDateTime(e.consumedAt)),
                                subtitle: Text(
                                  switch (e.priceKind) {
                                    PriceKind.informed =>
                                      'Preço atual: ${formatCents(e.paidCents ?? 0)}',
                                    PriceKind.complimentary => 'Cortesia',
                                    PriceKind.unknown => 'Sem preço',
                                  },
                                  style: AppText.caption,
                                ),
                                secondary: IconButton(
                                  tooltip: 'Informar só este preço',
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
                  child: Text(state.selected.isEmpty
                      ? 'Selecione registros'
                      : 'Ver prévia (${state.selected.length})'),
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
  const _One.complimentary()
      : cents = null,
        complimentary = true;

  final int? cents;
  final bool complimentary;
}
