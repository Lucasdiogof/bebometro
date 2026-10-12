import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/drink_entry_page.dart';
import '../domain/outing.dart';
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

  Future<void> _edit(DrinkEntry entry) => Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => DrinkEntryPage.edit(entry: entry)),
      );

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
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                SurfaceCard(
                  highlight: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(outing.type.icon, color: AppColors.amber),
                        const SizedBox(width: 8),
                        Text(outing.type.label,
                            style:
                                const TextStyle(color: AppColors.textMuted)),
                      ]),
                      const SizedBox(height: 6),
                      Text(outing.displayName,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w800)),
                      if (outing.subtitleAddress != null)
                        Text(outing.subtitleAddress!,
                            style:
                                const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                          child: StatTile(
                            label: 'Início',
                            value: formatDateTime(outing.startedAt),
                          ),
                        ),
                        Expanded(
                          child: StatTile(
                            label: 'Fim',
                            value: formatDateTime(endedAt),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      StatTile(
                        label: 'Duração',
                        value: formatDuration(outing.durationAt(endedAt)),
                        icon: Icons.timer_outlined,
                      ),
                    ],
                  ),
                ),
                const SectionTitle('CONSUMO'),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: StatTile(
                              label: 'Registros',
                              value: '${s.entryCount}',
                              icon: Icons.local_bar_rounded),
                        ),
                        Expanded(
                          child: StatTile(
                              label: 'Seu volume',
                              value: formatMl(s.personalMl),
                              icon: Icons.opacity_rounded),
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
                const SectionTitle('GASTOS'),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatTile(
                        label: 'Gasto informado',
                        value: formatCents(s.informedCents),
                        icon: Icons.payments_rounded,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.financeLine,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (outing.feedbackMood != null) ...[
                  const SectionTitle('COMO FOI'),
                  SurfaceCard(
                    child: Row(children: [
                      Text(outing.feedbackMood!.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Text(outing.feedbackMood!.label,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      const Text('seu relato',
                          style: TextStyle(color: AppColors.textMuted)),
                    ]),
                  ),
                ],
                const SectionTitle('REGISTROS · TOQUE PARA CORRIGIR'),
                if (state.entries.isEmpty)
                  const EmptyView(
                    icon: Icons.sports_bar_outlined,
                    title: 'Nenhum registro neste rolê',
                  )
                else
                  for (final e in state.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: EntryTile(
                        entry: e,
                        onTap: () => _edit(e),
                        onDelete: () => cubit.deleteEntry(e),
                      ),
                    ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Concluir'),
                ),
              ],
            ),
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
          width: 40,
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
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(group.detail,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        Text(formatMl(group.personalMl),
            style: const TextStyle(color: AppColors.textMuted)),
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
          value: (summary.alcoholIncomplete ? '≥ ' : '') +
              formatGrams(summary.pureAlcoholGrams),
          icon: Icons.science_outlined,
        ),
        const SizedBox(height: 6),
        Text(
          summary.alcoholIncomplete
              ? 'Incompleto: há bebida alcoólica sem teor informado, que não '
                  'entrou na conta.'
              : 'Volume × teor declarado de cada registro.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        const Text(
          'Não é concentração de álcool no sangue nem indica se você está apto a dirigir.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
