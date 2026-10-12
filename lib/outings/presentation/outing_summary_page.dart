import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/drink_entry_page.dart';
import '../domain/outing_summary.dart';
import 'outing_cubit.dart';
import 'outing_page.dart' show EntryTile;

/// Summary of a finished outing. Records can still be corrected here, and the
/// totals are recalculated from the records.
class OutingSummaryPage extends StatelessWidget {
  const OutingSummaryPage({super.key, required this.outingId});

  final String outingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OutingCubit>(param1: outingId),
      child: const _SummaryView(),
    );
  }
}

class _SummaryView extends StatefulWidget {
  const _SummaryView();

  @override
  State<_SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<_SummaryView> {
  StreamSubscription<OutingNotice>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = context.read<OutingCubit>().notices.listen((n) {
      if (!mounted) return;
      final m = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      m.showSnackBar(SnackBar(
        content: Text(n.text),
        duration: const Duration(seconds: 5),
        action: n.undo == null
            ? null
            : SnackBarAction(
                label: n.undoLabel ?? 'Desfazer', onPressed: () => n.undo!()),
      ));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _edit(DrinkEntry entry) async {
    final outcome = await Navigator.of(context).push<EntryOutcome>(
      MaterialPageRoute(builder: (_) => DrinkEntryPage.edit(entry: entry)),
    );
    if (!mounted || outcome == null) return;
    showToast(
      context,
      outcome == EntryOutcome.deleted
          ? 'Registro excluído'
          : 'Registro atualizado, resumo recalculado',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OutingCubit>();
    return BlocBuilder<OutingCubit, OutingState>(
      builder: (context, state) {
        if (state.loading) return const Scaffold(body: LoadingView());
        final outing = state.outing;
        if (outing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorView(message: 'Esse rolê não foi encontrado.'),
          );
        }
        final s = state.summary!;
        final endedAt = outing.endedAt ?? DateTime.now();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Resumo do rolê'),
            actions: const [SyncBadge()],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                  children: [
                    SurfaceCard(
                      highlight: true,
                      padding: const EdgeInsets.all(AppSpace.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(outing.type.icon,
                                color: AppColors.amber, size: 20),
                            const SizedBox(width: AppSpace.sm),
                            Text(outing.type.label, style: AppText.caption),
                          ]),
                          const SizedBox(height: AppSpace.sm),
                          Text(outing.displayName, style: AppText.headline),
                          const SizedBox(height: AppSpace.xs),
                          Text(formatWeekdayDate(outing.startedAt),
                              style: AppText.subtitle
                                  .copyWith(color: AppColors.amber)),
                          if (outing.subtitleAddress != null)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpace.xs),
                              child: Text(outing.subtitleAddress!,
                                  style: AppText.caption),
                            ),
                          const SizedBox(height: AppSpace.lg),
                          Row(children: [
                            Expanded(
                              child: StatTile(
                                label: 'Início',
                                value: formatTime(outing.startedAt),
                              ),
                            ),
                            Expanded(
                              child: StatTile(
                                label: 'Fim',
                                value: formatTime(endedAt),
                              ),
                            ),
                            Expanded(
                              child: StatTile(
                                label: 'Duração',
                                value: formatDuration(
                                    outing.durationAt(endedAt)),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SectionTitle('Consumo'),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: StatTile(
                                label: 'Bebidas',
                                value: '${s.entryCount}',
                                icon: Icons.local_bar_rounded,
                              ),
                            ),
                            Expanded(
                              child: StatTile(
                                label: 'Seu volume',
                                value: formatMl(s.personalMl),
                                icon: Icons.opacity_rounded,
                              ),
                            ),
                          ]),
                          if (s.groups.isNotEmpty) ...[
                            const Divider(height: 28),
                            for (final g in s.groups) _GroupRow(group: g),
                          ],
                          if (s.alcoholicCount > 0) ...[
                            const Divider(height: 28),
                            _AlcoholInfo(summary: s),
                          ],
                        ],
                      ),
                    ),
                    const SectionTitle('Gastos'),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatTile(
                            label: 'Gasto informado',
                            value: formatCents(s.informedCents),
                            icon: Icons.payments_outlined,
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Text(s.financeLine, style: AppText.caption),
                          if (s.unpricedCount > 0) ...[
                            const SizedBox(height: AppSpace.md),
                            InfoPill(
                              '${s.unpricedCount} '
                              '${s.unpricedCount == 1 ? 'bebida' : 'bebidas'} '
                              'sem preço: o total pode estar maior',
                              icon: Icons.sell_outlined,
                              warning: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (outing.feedbackMood != null) ...[
                      const SectionTitle('Como foi'),
                      SurfaceCard(
                        child: Row(children: [
                          Icon(outing.feedbackMood!.icon,
                              color: AppColors.amber, size: 28),
                          const SizedBox(width: AppSpace.md),
                          Text(outing.feedbackMood!.label,
                              style: AppText.title),
                          const Spacer(),
                          const Text('seu relato', style: AppText.caption),
                        ]),
                      ),
                    ],
                    SectionTitle('Registros (${state.entries.length})'),
                    if (state.entries.isEmpty)
                      const EmptyView(
                        icon: Icons.sports_bar_outlined,
                        title: 'Nenhum registro neste rolê',
                      )
                    else ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpace.sm),
                        child: Text(
                          'Toque em um registro para corrigir; o resumo '
                          'se recalcula.',
                          style: AppText.caption,
                        ),
                      ),
                      for (final e in state.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.sm),
                          child: EntryTile(
                            entry: e,
                            onTap: () => _edit(e),
                            onDelete: () => cubit.deleteEntry(e),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              BottomActionBar(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Concluir'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});

  final DrinkGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Text('${group.count}×',
              style: const TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(group.detail,
                  style: AppText.caption.copyWith(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Text(formatMl(group.personalMl), style: AppText.caption),
      ]),
    );
  }
}

class _AlcoholInfo extends StatelessWidget {
  const _AlcoholInfo({required this.summary});

  final OutingSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatTile(
          label: 'Álcool puro declarado',
          value: (summary.alcoholIncomplete ? 'pelo menos ' : '') +
              formatGrams(summary.pureAlcoholGrams),
          icon: Icons.science_outlined,
        ),
        const SizedBox(height: AppSpace.sm),
        if (summary.unknownAbvCount > 0) ...[
          InfoPill(
            '${summary.unknownAbvCount} '
            '${summary.unknownAbvCount == 1 ? 'registro' : 'registros'} '
            'sem teor informado ficaram fora da conta',
            icon: Icons.help_outline_rounded,
            warning: true,
          ),
          const SizedBox(height: AppSpace.sm),
        ],
        const Text(
          'Volume × teor declarado de cada registro. Não é a concentração de '
          'álcool no sangue e não indica se você pode dirigir.',
          style: AppText.caption,
        ),
      ],
    );
  }
}
