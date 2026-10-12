import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/beer_glass.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/add_drink_page.dart';
import '../../drinks/presentation/drink_entry_page.dart';
import 'outing_cubit.dart';

/// Running outing. Pops with the outing id after it is finished, so the
/// caller can show the summary.
class OutingPage extends StatelessWidget {
  const OutingPage({super.key, required this.outingId});

  final String outingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OutingCubit>(param1: outingId),
      child: const _OutingView(),
    );
  }
}

class _OutingView extends StatefulWidget {
  const _OutingView();

  @override
  State<_OutingView> createState() => _OutingViewState();
}

class _OutingViewState extends State<_OutingView> {
  StreamSubscription<OutingNotice>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = context.read<OutingCubit>().notices.listen(_showNotice);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _showNotice(OutingNotice notice) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(notice.text),
      duration: const Duration(seconds: 5),
      action: notice.undo == null
          ? null
          : SnackBarAction(
              label: notice.undoLabel ?? 'Desfazer',
              onPressed: () => notice.undo!(),
            ),
    ));
  }

  Future<void> _addDrink() async {
    final id = context.read<OutingCubit>().outingId;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddDrinkPage(outingId: id)),
    );
  }

  Future<void> _edit(DrinkEntry entry) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DrinkEntryPage.edit(entry: entry)),
    );
  }

  Future<void> _finish() async {
    final cubit = context.read<OutingCubit>();
    final outing = cubit.state.outing;
    if (outing == null) return;
    final endedAt = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FinishSheet(
        startedAt: outing.startedAt,
        entryCount: cubit.state.entries.length,
      ),
    );
    if (endedAt == null) return;
    try {
      await cubit.finish(endedAt);
      if (mounted) Navigator.of(context).pop(outing.id);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OutingCubit>();
    return BlocBuilder<OutingCubit, OutingState>(
      builder: (context, state) {
        if (state.loading) {
          return const Scaffold(body: LoadingView());
        }
        final outing = state.outing;
        if (outing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorView(message: 'Esse rolê não foi encontrado.'),
          );
        }
        final summary = state.summary!;
        final last = state.lastAlcoholic;
        final entries = state.entries.reversed.toList();
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outing.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  outing.type.label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
            actions: const [SyncBadge()],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                SurfaceCard(
                  highlight: true,
                  child: Column(children: [
                    Row(children: [
                      BeerGlass(
                        size: 92,
                        fill: summary.alcoholicCount == 0
                            ? 0.15
                            : (0.25 + summary.alcoholicCount * 0.12),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Rolando há',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 13)),
                            ElapsedText(
                              since: outing.startedAt,
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'desde ${formatTime(outing.startedAt)}',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: StatTile(
                          label: 'Registros',
                          value: '${summary.entryCount}',
                          icon: Icons.local_bar_rounded,
                        ),
                      ),
                      Expanded(
                        child: StatTile(
                          label: 'Seu volume',
                          value: formatMl(summary.personalMl),
                          icon: Icons.opacity_rounded,
                        ),
                      ),
                      Expanded(
                        child: StatTile(
                          label: 'Gasto informado',
                          value: formatCents(summary.informedCents),
                          icon: Icons.payments_rounded,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        summary.financeLine,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                if (last != null)
                  _RepeatButton(entry: last, onPressed: cubit.repeatLast),
                if (last != null) const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: FilledButton.icon(
                      style: last == null
                          ? null
                          : FilledButton.styleFrom(
                              backgroundColor: AppColors.surfaceHigh,
                              foregroundColor: AppColors.text,
                            ),
                      onPressed: _addDrink,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Adicionar bebida'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56)),
                      onPressed: cubit.addWater,
                      icon: const Icon(Icons.water_drop_rounded,
                          color: Color(0xFF6EC1E4)),
                      label: const Text('Água'),
                    ),
                  ),
                ]),
                const SectionTitle('REGISTROS'),
                if (entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyView(
                      icon: Icons.sports_bar_outlined,
                      title: 'Nenhuma bebida ainda',
                      message:
                          'Registre a primeira e o botão "Mais uma" aparece aqui.',
                    ),
                  )
                else
                  for (final e in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: EntryTile(
                        entry: e,
                        onTap: () => _edit(e),
                        onDelete: () => cubit.deleteEntry(e),
                      ),
                    ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _finish,
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('Encerrar rolê'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({required this.entry, required this.onPressed});

  final DrinkEntry entry;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.amber,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            const Icon(Icons.replay_rounded,
                color: Color(0xFF241800), size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mais uma',
                    style: TextStyle(
                      color: Color(0xFF241800),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    [
                      entry.name,
                      formatMl(entry.personalMl),
                      if (entry.priceKind == PriceKind.informed &&
                          entry.paidCents != null)
                        formatCents(entry.paidCents!),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xCC241800)),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A drink record row, used in the running outing and in the summary.
class EntryTile extends StatelessWidget {
  const EntryTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.onDelete,
  });

  final DrinkEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  String get _priceText => switch (entry.priceKind) {
        PriceKind.informed => formatCents(entry.paidCents ?? 0),
        PriceKind.complimentary => 'Cortesia',
        PriceKind.unknown => 'Sem preço',
      };

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      formatTime(entry.consumedAt),
      if (entry.isShared)
        '${formatMl(entry.personalMl)} de ${formatMl(entry.containerMl)} '
            '(÷${entry.peopleCount})'
      else
        formatMl(entry.personalMl),
      if (entry.abvPercent != null && entry.category.canBeAlcoholic)
        formatAbv(entry.abvPercent!),
    ];
    final tile = SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(children: [
        Icon(entry.category.icon, color: AppColors.amber),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(meta.join(' · '),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ),
        Text(
          _priceText,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: entry.hasPrice ? AppColors.text : AppColors.textMuted,
          ),
        ),
      ]),
    );
    if (onDelete == null) return tile;
    return Dismissible(
      key: ValueKey('entry-${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete!(),
      child: tile,
    );
  }
}

class _FinishSheet extends StatefulWidget {
  const _FinishSheet({required this.startedAt, required this.entryCount});

  final DateTime startedAt;
  final int entryCount;

  @override
  State<_FinishSheet> createState() => _FinishSheetState();
}

class _FinishSheetState extends State<_FinishSheet> {
  late DateTime _endedAt = DateTime.now();

  bool get _valid => !_endedAt.isBefore(widget.startedAt);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Encerrar rolê?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            '${widget.entryCount} registro(s). Você ainda poderá corrigir '
            'registros depois, pelo histórico.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            onTap: () async {
              final picked = await pickDateTime(context, _endedAt);
              if (picked != null) setState(() => _endedAt = picked);
            },
            child: Row(children: [
              const Icon(Icons.flag_rounded, color: AppColors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Fim: ${formatDateTime(_endedAt)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Text('Ajustar', style: TextStyle(color: AppColors.amber)),
            ]),
          ),
          if (!_valid)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('O fim não pode ser antes do início.',
                  style: TextStyle(color: AppColors.danger)),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _valid ? () => Navigator.pop(context, _endedAt) : null,
            child: const Text('Encerrar e ver resumo'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar o rolê'),
          ),
        ],
      ),
    );
  }
}
