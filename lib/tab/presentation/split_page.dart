import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../domain/tab_calc.dart';
import '../domain/tab_models.dart';
import 'tab_cubit.dart';

/// "Dividir conta": participants by nickname, the split mode, what each person
/// was assigned and what they say to have paid. Assigned cost, payment and
/// consumption are different things: nothing here changes drink records, the
/// total or the budget. No bank, Pix or transfer is involved.
class SplitPage extends StatelessWidget {
  const SplitPage({super.key, required this.cubit});

  final TabCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: cubit, child: const _SplitView());
  }
}

class _SplitView extends StatefulWidget {
  const _SplitView();

  @override
  State<_SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<_SplitView> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add(TabCubit cubit) async {
    final text = _name.text;
    if (text.trim().isEmpty) return;
    _name.clear();
    await cubit.addParticipant(text);
  }

  Future<void> _rename(TabCubit cubit, Participant p) async {
    final c = TextEditingController(text: p.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renomear'),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Apelido'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (name != null) await cubit.renameParticipant(p.id, name);
  }

  Future<void> _remove(TabCubit cubit, Participant p) async {
    final state = cubit.state;
    if (!cubit.hasLinks(p.id)) {
      await cubit.removeParticipant(p.id);
      return;
    }
    final others = [
      for (final o in state.doc.participants)
        if (o.id != p.id) o,
    ];
    final share = state.result.shareOf(p.id);
    final payments = state.doc.payments.where((x) => x.participantId == p.id);
    final paid = payments.fold<int>(0, (a, x) => a + x.cents);
    String? target;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('Remover ${p.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ele tem ${formatCents(share)} atribuídos'
                '${payments.isEmpty ? '' : ' e ${payments.length} pagamento(s) '
                    '(${formatCents(paid)})'}. Escolha o que acontece com eles:',
              ),
              const SizedBox(height: AppSpace.md),
              DropdownButtonFormField<String?>(
                initialValue: target,
                decoration: const InputDecoration(labelText: 'Passar para'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Ninguém (redistribuir)')),
                  for (final o in others)
                    DropdownMenuItem(value: o.id, child: Text(o.name)),
                ],
                onChanged: (v) => setD(() => target = v),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                target == null
                    ? 'Os itens só dele voltam a ser divididos entre todos e '
                        'os pagamentos dele são apagados.'
                    : 'Itens, valores e pagamentos passam para essa pessoa.',
                style: AppText.caption,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Remover',
                    style: TextStyle(color: AppColors.danger))),
          ],
        ),
      ),
    );
    if (go == true) await cubit.removeParticipant(p.id, transferTo: target);
  }

  Future<void> _payment(TabCubit cubit, {TabPayment? existing}) async {
    final doc = cubit.state.doc;
    final value = TextEditingController(
        text: existing == null ? '' : centsToInput(existing.cents));
    final note = TextEditingController(text: existing?.note ?? '');
    var who = existing?.participantId ??
        (doc.me?.id ?? doc.participants.first.id);
    String? error;
    final saved = await showDialog<TabPayment>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(existing == null ? 'Registrar pagamento' : 'Editar pagamento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: who,
                  decoration: const InputDecoration(labelText: 'Quem pagou'),
                  items: [
                    for (final p in doc.participants)
                      DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (v) => setD(() => who = v ?? who),
                ),
                const SizedBox(height: AppSpace.md),
                TextField(
                  controller: value,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Valor pago ao estabelecimento',
                    prefixText: r'R$ ',
                    errorText: error,
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                TextField(
                  controller: note,
                  decoration:
                      const InputDecoration(labelText: 'Observação (opcional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final cents = parseCents(value.text);
                if (cents == null || cents <= 0) {
                  setD(() => error = 'Informe um valor maior que zero.');
                  return;
                }
                final n = note.text.trim();
                Navigator.pop(
                  ctx,
                  TabPayment(
                    id: existing?.id ?? cubit.newId(),
                    participantId: who,
                    cents: cents,
                    at: existing?.at ?? DateTime.now(),
                    note: n.isEmpty ? null : n,
                  ),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    if (saved != null) await cubit.savePayment(saved);
  }

  Future<void> _assign(TabCubit cubit, TabLine line) async {
    final doc = cubit.state.doc;
    final result = await showDialog<({Map<String, int>? assign})>(
      context: context,
      builder: (_) => _AssignDialog(
        title: line.title,
        participants: doc.participants,
        current: line.assign,
      ),
    );
    if (result != null) await cubit.setLineAssign(line, result.assign);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TabCubit>();
    return BlocBuilder<TabCubit, TabState>(
      builder: (context, state) {
        final doc = state.doc;
        final r = state.result;
        final names = {for (final p in doc.participants) p.id: p.name};
        return Scaffold(
          appBar: AppBar(title: const Text('Dividir conta')),
          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
            children: [
              SurfaceCard(
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.isPartial
                          ? 'Total conhecido ${formatCents(r.total)}'
                          : 'Total ${formatCents(r.total)}',
                      style: AppText.title,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    if (r.isPartial)
                      InfoPill(
                        '${r.pendingCount} item(ns) sem preço: a divisão e os '
                        'saldos são provisórios.',
                        icon: Icons.warning_amber_rounded,
                        warning: true,
                      )
                    else if (r.splitComplete)
                      const InfoPill('Divisão completa: as parcelas somam o total.',
                          icon: Icons.check_circle_outline_rounded)
                    else
                      InfoPill(
                        r.unassigned > 0
                            ? 'Falta distribuir ${formatCents(r.unassigned)}.'
                            : 'Distribuído ${formatCents(-r.unassigned)} a mais que o total.',
                        icon: Icons.info_outline_rounded,
                        warning: true,
                      ),
                  ],
                ),
              ),
              const SectionTitle('Pessoas'),
              for (final p in doc.participants)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.xs),
                  child: SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpace.lg, AppSpace.xs, AppSpace.xs, AppSpace.xs),
                    child: Row(children: [
                      Icon(p.isMe ? Icons.person_rounded : Icons.person_outline,
                          color: AppColors.amber),
                      const SizedBox(width: AppSpace.md),
                      Expanded(child: Text(p.name, style: AppText.subtitle)),
                      IconButton(
                        tooltip: 'Renomear',
                        onPressed: () => _rename(cubit, p),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      if (!p.isMe)
                        IconButton(
                          tooltip: 'Remover',
                          onPressed: () => _remove(cubit, p),
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.danger),
                        ),
                    ]),
                  ),
                ),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(cubit),
                    decoration: const InputDecoration(
                        labelText: 'Adicionar pessoa (apelido)'),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                IconButton.filled(
                  tooltip: 'Adicionar',
                  onPressed: () => _add(cubit),
                  icon: const Icon(Icons.add_rounded),
                ),
              ]),
              const SizedBox(height: AppSpace.xs),
              const Text(
                'Só apelidos, sem login nem convite. Ficam apenas nesta comanda.',
                style: AppText.caption,
              ),
              const SectionTitle('Como dividir'),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<SplitMode>(
                  showSelectedIcon: false,
                  segments: [
                    for (final m in SplitMode.values)
                      ButtonSegment(
                        value: m,
                        label: Text(switch (m) {
                          SplitMode.equal => 'Igual',
                          SplitMode.item => 'Por item',
                          SplitMode.custom => 'Valores',
                        }),
                      ),
                  ],
                  selected: {doc.mode},
                  onSelectionChanged: (s) => cubit.setMode(s.first),
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                switch (doc.mode) {
                  SplitMode.equal =>
                    'Modo ativo: igualmente. O total é dividido entre as '
                        'pessoas marcadas.',
                  SplitMode.item =>
                    'Modo ativo: por item. Cada pedido é dividido entre quem '
                        'participa dele, com serviço e desconto do próprio item.',
                  SplitMode.custom =>
                    'Modo ativo: valores personalizados. Você digita a parcela '
                        'de cada um; só fecha quando a soma bate com o total.',
                },
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpace.md),
              if (doc.mode == SplitMode.equal)
                for (final p in doc.participants)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.amber,
                    value: doc.equalIds.contains(p.id),
                    onChanged: (_) => cubit.toggleEqual(p.id),
                    title: Text(p.name),
                    secondary: Text(formatCents(r.shareOf(p.id)),
                        style: AppText.subtitle),
                  ),
              if (doc.mode == SplitMode.item) ...[
                if (r.results.isEmpty)
                  const Text('Adicione itens à comanda para dividir por item.',
                      style: AppText.caption),
                for (final res in r.results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.xs),
                    child: SurfaceCard(
                      onTap: () => _assign(cubit, res.line),
                      padding: const EdgeInsets.all(AppSpace.md),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(res.line.title, style: AppText.subtitle),
                              Text(_assignText(res.line.assign, names),
                                  style: AppText.caption),
                            ],
                          ),
                        ),
                        Text(
                          res.finalCents == null
                              ? 'sem preço'
                              : formatCents(res.finalCents!),
                          style: AppText.body,
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textMuted),
                      ]),
                    ),
                  ),
              ],
              if (doc.mode == SplitMode.custom) ...[
                for (final p in doc.participants)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.sm),
                    child: _CustomField(
                      key: ValueKey('c-${p.id}'),
                      label: p.name,
                      cents: doc.custom[p.id],
                      onChanged: (c) => cubit.setCustom(p.id, c),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final ids = [for (final p in doc.participants) p.id];
                      final parts = TabCalculator.allocate(
                          r.total, List<int>.filled(ids.length, 1));
                      for (var i = 0; i < ids.length; i++) {
                        await cubit.setCustom(ids[i], parts[i]);
                      }
                    },
                    icon: const Icon(Icons.balance_rounded, size: 18),
                    label: const Text('Preencher igualmente'),
                  ),
                ),
                Text(
                  r.unassigned == 0
                      ? 'Tudo distribuído.'
                      : (r.unassigned > 0
                          ? 'Ainda não distribuído: ${formatCents(r.unassigned)}'
                          : 'Passou do total em ${formatCents(-r.unassigned)}'),
                  style: AppText.subtitle,
                ),
              ],
              const SectionTitle('Resultado'),
              Text(
                r.isPartial || r.unassigned != 0
                    ? 'Provisório: os valores mudam se a conta mudar.'
                    : 'Atribuído é o que cabe a cada um; pago é o que a pessoa '
                        'disse ter pago ao estabelecimento.',
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpace.sm),
              for (final p in doc.participants)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.xs),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(AppSpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(p.name, style: AppText.subtitle)),
                          Text(formatCents(r.shareOf(p.id)),
                              style: AppText.title),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          'Pagou ${formatCents(r.paidBy(p.id))} · '
                          '${_balanceText(r.balanceOf(p.id), provisional: r.isPartial || r.unassigned != 0)}',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              SectionTitle(
                'Pagamentos',
                trailing: TextButton.icon(
                  onPressed: () => _payment(cubit),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Registrar'),
                ),
              ),
              if (doc.payments.isEmpty)
                const Text('Nenhum pagamento registrado.',
                    style: AppText.caption),
              for (final pay in doc.payments)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      '${names[pay.participantId] ?? 'Pessoa removida'} · '
                      '${formatCents(pay.cents)}'),
                  subtitle: Text(
                    [formatDateTime(pay.at), if (pay.note != null) pay.note!]
                        .join(' · '),
                    style: AppText.caption,
                  ),
                  onTap: () => _payment(cubit, existing: pay),
                  trailing: IconButton(
                    tooltip: 'Excluir pagamento',
                    onPressed: () => cubit.removePayment(pay.id),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
                  ),
                ),
              const SizedBox(height: AppSpace.sm),
              const Text(
                'Registrar um pagamento não muda o total, o consumo nem o '
                'orçamento: só o saldo. O app não faz cobrança, Pix nem '
                'transferência, e não diz quem deve pagar a quem. O preço de '
                'um consumo não conta como pagamento.',
                style: AppText.caption,
              ),
            ],
          ),
        );
      },
    );
  }

  static String _assignText(Map<String, int>? a, Map<String, String> names) {
    if (a == null) return 'Todos dividem';
    final parts = [
      for (final e in a.entries)
        if (names.containsKey(e.key))
          e.value > 1 ? '${names[e.key]} ×${e.value}' : names[e.key]!,
    ];
    return parts.isEmpty ? 'Ninguém' : parts.join(', ');
  }

  static String _balanceText(int balance, {required bool provisional}) {
    final tag = provisional ? ' (provisório)' : '';
    if (balance > 0) return 'falta pagar ${formatCents(balance)}$tag';
    if (balance < 0) return 'pagou ${formatCents(-balance)} a mais$tag';
    return 'em dia$tag';
  }
}

/// Money field that keeps what is being typed while the shares recompute.
class _CustomField extends StatefulWidget {
  const _CustomField({
    super.key,
    required this.label,
    required this.cents,
    required this.onChanged,
  });

  final String label;
  final int? cents;
  final ValueChanged<int?> onChanged;

  @override
  State<_CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<_CustomField> {
  late final TextEditingController _c = TextEditingController(
      text: widget.cents == null ? '' : centsToInput(widget.cents!));

  @override
  void didUpdateWidget(_CustomField old) {
    super.didUpdateWidget(old);
    // Changed from outside ("Preencher igualmente"), not by typing here.
    if (widget.cents != old.cents && parseCents(_c.text) != widget.cents) {
      _c.text = widget.cents == null ? '' : centsToInput(widget.cents!);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: widget.label, prefixText: r'R$ '),
      onChanged: (v) => widget.onChanged(v.trim().isEmpty ? null : parseCents(v)),
    );
  }
}

/// Who takes part in one order, with a weight each. Everybody ticked with the
/// same weight means "all" (stored as no assignment).
class _AssignDialog extends StatefulWidget {
  const _AssignDialog({
    required this.title,
    required this.participants,
    required this.current,
  });

  final String title;
  final List<Participant> participants;
  final Map<String, int>? current;

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  late final Map<String, int> _w = {
    for (final p in widget.participants)
      if (widget.current == null || widget.current!.containsKey(p.id))
        p.id: widget.current?[p.id] ?? 1,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quem participa e com que peso. Quem não participa não recebe '
              'parcela deste item.',
              style: AppText.caption,
            ),
            for (final p in widget.participants)
              Row(children: [
                Checkbox(
                  value: _w.containsKey(p.id),
                  activeColor: AppColors.amber,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _w[p.id] = 1;
                    } else {
                      _w.remove(p.id);
                    }
                  }),
                ),
                Expanded(child: Text(p.name)),
                if (_w.containsKey(p.id))
                  DropdownButton<int>(
                    value: _w[p.id],
                    underline: const SizedBox.shrink(),
                    items: [
                      for (var i = 1; i <= 9; i++)
                        DropdownMenuItem(value: i, child: Text('peso $i')),
                    ],
                    onChanged: (v) => setState(() => _w[p.id] = v ?? 1),
                  ),
              ]),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            final all = _w.length == widget.participants.length &&
                _w.values.every((v) => v == 1);
            Navigator.pop(context, (assign: all ? null : Map<String, int>.of(_w)));
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
