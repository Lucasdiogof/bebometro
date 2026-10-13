import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/beer_glass.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/add_drink_page.dart';
import '../../drinks/presentation/drink_entry_page.dart';
import '../../scan/data/scan_draft_store.dart';
import '../../table/data/table_prefs_cubit.dart';
import '../../table/presentation/table_scene.dart';
import '../../table/presentation/table_sheets.dart';
import '../../glass/presentation/accumulated_glass.dart';
import '../../glass/presentation/tip_glass_page.dart';
import 'budget_section.dart';
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
  bool _finishing = false;

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
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddDrinkPage(outingId: id)),
    );
    if (saved == true && mounted) showToast(context, 'Bebida registrada');
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
          : 'Registro atualizado',
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
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
    setState(() => _finishing = true);
    try {
      await cubit.finish(endedAt);
      if (mounted &&
          getIt<ScanDraftStore>().openFor(outing.id).isNotEmpty) {
        // An unfinished label/menu reading stays tied to this outing.
        showToast(
          context,
          'Há uma leitura de rótulo ou cardápio em aberto. Ela continua '
          'ligada a este rolê e aparece no resumo dele.',
        );
      }
      if (mounted) Navigator.of(context).pop(outing.id);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() => _finishing = false);
      showToast(context, '${e.message}');
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
        final prefs = context.watch<TablePrefsCubit>().state;
        final prefsCubit = context.read<TablePrefsCubit>();
        final scenario = prefs.scenarioFor(outing.id, outing.type);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outing.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title),
                Text(
                  '${outing.type.label} · desde ${formatTime(outing.startedAt)}',
                  style: AppText.caption,
                ),
              ],
            ),
            actions: [
              const SyncBadge(),
              PopupMenuButton<String>(
                tooltip: 'Mais opções',
                onSelected: (v) {
                  if (v == 'finish') _finish();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'finish', child: Text('Encerrar rolê')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                  children: [
                    SurfaceCard(
                      child: Column(children: [
                        Row(children: [
                          BeerGlass(
                            size: 64,
                            fill: summary.alcoholicCount == 0
                                ? 0.15
                                : (0.25 + summary.alcoholicCount * 0.12),
                          ),
                          const SizedBox(width: AppSpace.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rolando há', style: AppText.caption),
                                ElapsedText(
                                  since: outing.startedAt,
                                  style: AppText.headline,
                                ),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: AppSpace.lg),
                        Row(children: [
                          Expanded(
                            child: StatTile(
                              label: 'Bebidas',
                              value: '${summary.entryCount}',
                            ),
                          ),
                          Expanded(
                            child: StatTile(
                              label: 'Seu volume',
                              value: summary.volumeLabel,
                            ),
                          ),
                          Expanded(
                            child: StatTile(
                              label: 'Gasto informado',
                              value: formatCents(summary.informedCents),
                            ),
                          ),
                        ]),
                        if (summary.unpricedCount > 0 ||
                            summary.unknownVolumeCount > 0 ||
                            summary.incompleteAlcoholCount > 0) ...[
                          const SizedBox(height: AppSpace.md),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: AppSpace.sm,
                              runSpacing: AppSpace.sm,
                              children: [
                                if (summary.unpricedCount > 0)
                                  InfoPill(
                                    '${summary.unpricedCount} sem preço',
                                    icon: Icons.sell_outlined,
                                    warning: true,
                                  ),
                                if (summary.unknownVolumeCount > 0)
                                  InfoPill(
                                    '${summary.unknownVolumeCount} sem volume',
                                    icon: Icons.opacity_outlined,
                                    warning: true,
                                  ),
                                if (summary.incompleteAlcoholCount > 0)
                                  InfoPill(
                                    '${summary.incompleteAlcoholCount} com álcool incompleto',
                                    icon: Icons.help_outline_rounded,
                                    warning: true,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ]),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    BudgetSection(
                      budgetCents: outing.budgetCents,
                      summary: summary,
                      onChange: cubit.setBudget,
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Row(children: [
                      Expanded(
                        child: SegmentedButton<TableView>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: TableView.table,
                              icon: Icon(Icons.table_restaurant_outlined),
                              label: Text('Mesa'),
                            ),
                            ButtonSegment(
                              value: TableView.list,
                              icon: Icon(Icons.view_list_rounded),
                              label: Text('Lista'),
                            ),
                          ],
                          selected: {prefs.view},
                          onSelectionChanged: (s) =>
                              prefsCubit.setView(s.first),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Opções da mesa',
                        onSelected: (v) {
                          if (v == 'scenario') {
                            showScenarioPicker(
                              context,
                              current: scenario,
                              onSelected: (s) =>
                                  prefsCubit.setScenario(outing.id, s),
                            );
                          } else if (v == 'about') {
                            showTableAbout(context);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'scenario', child: Text('Trocar cenário')),
                          PopupMenuItem(
                              value: 'about',
                              child: Text('Animação ilustrativa das bebidas '
                                  'registradas')),
                        ],
                      ),
                    ]),
                    if (prefs.view == TableView.table) ...[
                      const SizedBox(height: AppSpace.sm),
                      TableScene(
                        entries: state.entries,
                        scenario: scenario,
                        animate: prefs.animations,
                        onEdit: _edit,
                        onDelete: cubit.deleteEntry,
                      ),
                      if (state.entries.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: AppSpace.sm),
                          child: Text(
                            'Registre a primeira bebida e o botão "Mais uma" '
                            'aparece aqui embaixo.',
                            style: AppText.caption,
                          ),
                        ),
                    ] else ...[
                      SectionTitle('Registros (${entries.length})'),
                      if (entries.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpace.xl),
                          child: EmptyView(
                            icon: Icons.sports_bar_outlined,
                            title: 'Nenhuma bebida ainda',
                            message: 'Registre a primeira e o botão '
                                '"Mais uma" aparece aqui embaixo.',
                          ),
                        )
                      else
                        for (final e in entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpace.sm),
                            child: EntryTile(
                              entry: e,
                              onTap: () => _edit(e),
                              onDelete: () => cubit.deleteEntry(e),
                            ),
                          ),
                    ],
                    const SizedBox(height: AppSpace.md),
                    SurfaceCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding:
                              const EdgeInsets.only(bottom: AppSpace.md),
                          title: const Text('Copão (opcional)',
                              style: AppText.subtitle),
                          subtitle: const Text(
                              'O volume informado, somado, num copo.',
                              style: AppText.caption),
                          children: [
                            AccumulatedGlass(
                              alcoholicMl: summary.alcoholicMl,
                              otherMl: summary.otherMl,
                              unknownVolumeCount: summary.unknownVolumeCount,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const TipGlassPage()),
                                ),
                                icon: const Icon(Icons.rotate_right_rounded,
                                    size: 18),
                                label: const Text('Brincar de virar o copo'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Center(
                      child: TextButton.icon(
                        onPressed: _finishing ? null : _finish,
                        icon: const Icon(Icons.flag_outlined),
                        label: const Text('Encerrar rolê'),
                      ),
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (last != null) ...[
                      _RepeatButton(entry: last, onPressed: cubit.repeatLast),
                      const SizedBox(height: AppSpace.sm),
                    ],
                    Row(children: [
                      Expanded(
                        child: last == null
                            ? FilledButton.icon(
                                onPressed: _addDrink,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Adicionar bebida'),
                              )
                            : OutlinedButton.icon(
                                onPressed: _addDrink,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Adicionar bebida'),
                              ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                        ),
                        onPressed: cubit.addWater,
                        icon: const Icon(Icons.water_drop_outlined,
                            color: Color(0xFF6EC1E4)),
                        label: const Text('Água'),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
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

  String get _what {
    final container = entry.containerMl;
    final personal = entry.personalMl;
    if (entry.isMixed) {
      return entry.composition!.customized
          ? '${entry.name} (ajustada)'
          : entry.name;
    }
    final size = container == null ? '' : ' ${formatMl(container)}';
    return entry.isShared && personal != null
        ? '${entry.name}$size · sua parte ${formatMl(personal)}'
        : '${entry.name}$size';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Mais uma: $_what',
      child: Material(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.lg, vertical: AppSpace.sm),
              child: Row(children: [
                const Icon(Icons.replay_rounded,
                    color: Color(0xFF241800), size: 26),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Mais uma',
                        style: TextStyle(
                          color: Color(0xFF241800),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        [
                          _what,
                          if (entry.priceKind == PriceKind.informed &&
                              entry.paidCents != null)
                            formatCents(entry.paidCents!),
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xCC241800), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
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
    final personal = entry.personalMl;
    final container = entry.containerMl;
    final alcohol = entry.alcohol;
    final meta = <String>[
      formatTime(entry.consumedAt),
      if (entry.isMixed && entry.composition!.customized) 'receita ajustada',
      if (entry.presentation != null && !entry.isShared) entry.presentation!,
      if (entry.isShared && personal != null && container != null)
        'sua parte ${formatMl(personal)} de ${formatMl(container)} '
            '(${entry.peopleCount} pessoas)'
      else if (personal == null)
        'volume desconhecido'
      else if (entry.presentation == null)
        formatMl(personal),
      if (entry.isMixed && alcohol != null && !alcohol.isComplete)
        'álcool incompleto',
    ];
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
          AppSpace.md, AppSpace.sm, AppSpace.xs, AppSpace.sm),
      child: Row(children: [
        Icon(entry.category.icon, color: AppColors.amber),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
              const SizedBox(height: 2),
              Text(meta.join(' · '), style: AppText.caption),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Text(
          _priceText,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: entry.hasPrice ? AppColors.text : AppColors.textMuted,
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Opções do registro',
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.textMuted),
          onSelected: (v) {
            if (v == 'edit') onTap();
            if (v == 'delete') onDelete?.call();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Corrigir')),
            if (onDelete != null)
              const PopupMenuItem(value: 'delete', child: Text('Excluir')),
          ],
        ),
      ]),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl,
            AppSpace.lg + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Encerrar rolê?', style: AppText.title),
            const SizedBox(height: AppSpace.xs),
            Text(
              '${widget.entryCount} registro(s). Você ainda poderá corrigir '
              'registros depois, pelo histórico.',
              style: AppText.caption,
            ),
            const SizedBox(height: AppSpace.lg),
            SurfaceCard(
              onTap: () async {
                final picked = await pickDateTime(context, _endedAt);
                if (picked != null) setState(() => _endedAt = picked);
              },
              child: Row(children: [
                const Icon(Icons.flag_rounded, color: AppColors.amber),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text('Fim: ${formatDateTime(_endedAt)}',
                      style: AppText.subtitle),
                ),
                const Text('Ajustar',
                    style: TextStyle(color: AppColors.amber)),
              ]),
            ),
            if (!_valid)
              const Padding(
                padding: EdgeInsets.only(top: AppSpace.sm),
                child: Text('O fim não pode ser antes do início.',
                    style: TextStyle(color: AppColors.danger)),
              ),
            const SizedBox(height: AppSpace.xl),
            FilledButton(
              onPressed:
                  _valid ? () => Navigator.pop(context, _endedAt) : null,
              child: const Text('Encerrar e ver resumo'),
            ),
            const SizedBox(height: AppSpace.xs),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuar o rolê'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
