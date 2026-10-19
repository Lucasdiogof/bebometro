import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_field.dart';
import '../domain/tab_calc.dart';
import '../domain/tab_models.dart';
import 'tab_cubit.dart';
import '../../l10n/l10n.dart';

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
    final c = TextEditingController(text: p.displayName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.splitRename),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: tr.pickerManualNickname),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: Text(tr.commonSave),
          ),
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
          title: Text(tr.splitRemoveTitle(p.displayName)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payments.isEmpty
                    ? tr.splitRemoveBody(p.displayName, formatCents(share))
                    : tr.splitRemoveBodyPay(
                        p.displayName,
                        formatCents(share),
                        payments.length,
                        formatCents(paid),
                      ),
              ),
              const SizedBox(height: AppSpace.md),
              DropdownButtonFormField<String?>(
                initialValue: target,
                decoration: InputDecoration(labelText: tr.splitPassTo),
                items: [
                  DropdownMenuItem(value: null, child: Text(tr.splitNobody)),
                  for (final o in others)
                    DropdownMenuItem(value: o.id, child: Text(o.displayName)),
                ],
                onChanged: (v) => setD(() => target = v),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                target == null
                    ? tr.splitRedistributeNote
                    : tr.splitTransferNote,
                style: AppText.caption,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                tr.commonRemove,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
    if (go == true) await cubit.removeParticipant(p.id, transferTo: target);
  }

  Future<void> _payment(TabCubit cubit, {TabPayment? existing}) async {
    final doc = cubit.state.doc;
    final value = TextEditingController(
      text: existing == null ? '' : centsToInput(existing.cents),
    );
    final note = TextEditingController(text: existing?.note ?? '');
    var who =
        existing?.participantId ?? (doc.me?.id ?? doc.participants.first.id);
    String? error;
    final saved = await showDialog<TabPayment>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(
            existing == null ? tr.splitRegisterPayment : tr.splitEditPayment,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: who,
                  decoration: InputDecoration(labelText: tr.splitWhoPaid),
                  items: [
                    for (final p in doc.participants)
                      DropdownMenuItem(value: p.id, child: Text(p.displayName)),
                  ],
                  onChanged: (v) => setD(() => who = v ?? who),
                ),
                const SizedBox(height: AppSpace.md),
                MoneyField(
                  controller: value,
                  label: tr.splitPaidAmount,
                  errorText: error,
                  onChanged: (_) {
                    if (error != null) setD(() => error = null);
                  },
                ),
                const SizedBox(height: AppSpace.md),
                TextField(
                  controller: note,
                  decoration: InputDecoration(labelText: tr.splitNoteOptional),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr.commonCancel),
            ),
            TextButton(
              onPressed: () {
                final cents = parseCents(value.text);
                if (cents == null || cents <= 0) {
                  setD(
                    () => error =
                        numberInputError(value.text) ?? tr.splitPaymentPositive,
                  );
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
              child: Text(tr.commonSave),
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
        final names = {for (final p in doc.participants) p.id: p.displayName};
        return Scaffold(
          appBar: AppBar(title: Text(tr.splitTitle)),
          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpace.gutter,
              0,
              AppSpace.gutter,
              AppSpace.xxl,
            ),
            children: [
              SurfaceCard(
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.isPartial
                          ? tr.splitTotalKnown(formatCents(r.total))
                          : tr.splitTotal(formatCents(r.total)),
                      style: AppText.title,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    if (r.isPartial)
                      InfoPill(
                        tr.splitPendingPill(r.pendingCount),
                        icon: Icons.warning_amber_rounded,
                        warning: true,
                      )
                    else if (r.splitComplete)
                      InfoPill(
                        tr.splitComplete,
                        icon: Icons.check_circle_outline_rounded,
                      )
                    else
                      InfoPill(
                        r.unassigned > 0
                            ? tr.splitMissing(formatCents(r.unassigned))
                            : tr.splitOver(formatCents(-r.unassigned)),
                        icon: Icons.info_outline_rounded,
                        warning: true,
                      ),
                  ],
                ),
              ),
              SectionTitle(tr.splitPeople),
              for (final p in doc.participants)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.xs),
                  child: SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.lg,
                      AppSpace.xs,
                      AppSpace.xs,
                      AppSpace.xs,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          p.isMe ? Icons.person_rounded : Icons.person_outline,
                          color: AppColors.amber,
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Text(p.displayName, style: AppText.subtitle),
                        ),
                        IconButton(
                          tooltip: tr.splitRename,
                          onPressed: () => _rename(cubit, p),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        if (!p.isMe)
                          IconButton(
                            tooltip: tr.commonRemove,
                            onPressed: () => _remove(cubit, p),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.danger,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _add(cubit),
                      decoration: InputDecoration(labelText: tr.splitAddPerson),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  IconButton.filled(
                    tooltip: tr.commonAdd,
                    onPressed: () => _add(cubit),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xs),
              Text(tr.splitNicknamesOnly, style: AppText.caption),
              SectionTitle(tr.splitHow),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<SplitMode>(
                  showSelectedIcon: false,
                  segments: [
                    for (final m in SplitMode.values)
                      ButtonSegment(
                        value: m,
                        label: Text(switch (m) {
                          SplitMode.equal => tr.splitModeEqualShort,
                          SplitMode.item => tr.splitModeItemShort,
                          SplitMode.custom => tr.splitModeValuesShort,
                        }),
                      ),
                  ],
                  selected: {doc.mode},
                  onSelectionChanged: (s) => cubit.setMode(s.first),
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(switch (doc.mode) {
                SplitMode.equal => tr.splitModeEqualNote,
                SplitMode.item => tr.splitModeItemNote,
                SplitMode.custom => tr.splitModeCustomNote,
              }, style: AppText.caption),
              const SizedBox(height: AppSpace.md),
              if (doc.mode == SplitMode.equal)
                for (final p in doc.participants)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.amber,
                    value: doc.equalIds.contains(p.id),
                    onChanged: (_) => cubit.toggleEqual(p.id),
                    title: Text(p.displayName),
                    secondary: Text(
                      formatCents(r.shareOf(p.id)),
                      style: AppText.subtitle,
                    ),
                  ),
              if (doc.mode == SplitMode.item) ...[
                if (r.results.isEmpty)
                  Text(tr.splitAddItemsHint, style: AppText.caption),
                for (final res in r.results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.xs),
                    child: SurfaceCard(
                      onTap: () => _assign(cubit, res.line),
                      padding: const EdgeInsets.all(AppSpace.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(res.line.title, style: AppText.subtitle),
                                Text(
                                  _assignText(res.line.assign, names),
                                  style: AppText.caption,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            res.finalCents == null
                                ? tr.tabNoPrice
                                : formatCents(res.finalCents!),
                            style: AppText.body,
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              if (doc.mode == SplitMode.custom) ...[
                for (final p in doc.participants)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.sm),
                    child: _CustomField(
                      key: ValueKey('c-${p.id}'),
                      label: p.displayName,
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
                        r.total,
                        List<int>.filled(ids.length, 1),
                      );
                      for (var i = 0; i < ids.length; i++) {
                        await cubit.setCustom(ids[i], parts[i]);
                      }
                    },
                    icon: const Icon(Icons.balance_rounded, size: 18),
                    label: Text(tr.splitFillEqually),
                  ),
                ),
                Text(
                  r.unassigned == 0
                      ? tr.splitAllDistributed
                      : (r.unassigned > 0
                            ? tr.splitNotDistributed(formatCents(r.unassigned))
                            : tr.splitPassedTotal(formatCents(-r.unassigned))),
                  style: AppText.subtitle,
                ),
              ],
              SectionTitle(tr.splitResult),
              Text(
                r.isPartial || r.unassigned != 0
                    ? tr.splitProvisionalNote
                    : tr.splitAttributedNote,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.displayName,
                                style: AppText.subtitle,
                              ),
                            ),
                            Text(
                              formatCents(r.shareOf(p.id)),
                              style: AppText.title,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr.splitPaidLine(
                            formatCents(r.paidBy(p.id)),
                            r.venueSettled && r.balanceOf(p.id) > 0
                                ? tr.splitBalanceCovered
                                : _balanceText(
                                    r.balanceOf(p.id),
                                    provisional:
                                        r.isPartial || r.unassigned != 0,
                                  ),
                          ),
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              SectionTitle(
                tr.splitPayments,
                trailing: TextButton.icon(
                  onPressed: () => _payment(cubit),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(tr.myDrinksActionLog),
                ),
              ),
              if (doc.payments.isEmpty)
                Text(tr.splitNoPayments, style: AppText.caption),
              for (final pay in doc.payments)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${names[pay.participantId] ?? tr.splitRemovedPerson} · '
                    '${formatCents(pay.cents)}',
                  ),
                  subtitle: Text(
                    [
                      formatDateTime(pay.at),
                      if (pay.note != null) pay.note!,
                    ].join(' · '),
                    style: AppText.caption,
                  ),
                  onTap: () => _payment(cubit, existing: pay),
                  trailing: IconButton(
                    tooltip: tr.splitDeletePayment,
                    onPressed: () => cubit.removePayment(pay.id),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpace.sm),
              Text(tr.splitPaymentNote, style: AppText.caption),
            ],
          ),
        );
      },
    );
  }

  static String _assignText(Map<String, int>? a, Map<String, String> names) {
    if (a == null) return tr.splitAssignEveryone;
    final parts = [
      for (final e in a.entries)
        if (names.containsKey(e.key))
          e.value > 1 ? '${names[e.key]} ×${e.value}' : names[e.key]!,
    ];
    return parts.isEmpty ? tr.splitAssignNobody : parts.join(', ');
  }

  static String _balanceText(int balance, {required bool provisional}) {
    final tag = provisional.toString();
    if (balance > 0) return tr.splitBalanceMissing(formatCents(balance), tag);
    if (balance < 0) return tr.splitBalanceOver(formatCents(-balance), tag);
    return tr.splitBalanceEven(tag);
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
    text: widget.cents == null ? '' : centsToInput(widget.cents!),
  );

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
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: r'R$ ',
        errorText: numberInputError(_c.text),
        errorMaxLines: 3,
      ),
      onChanged: (v) =>
          widget.onChanged(v.trim().isEmpty ? null : parseCents(v)),
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
            Text(tr.splitAssignIntro, style: AppText.caption),
            for (final p in widget.participants)
              Row(
                children: [
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
                  Expanded(child: Text(p.displayName)),
                  if (_w.containsKey(p.id))
                    DropdownButton<int>(
                      value: _w[p.id],
                      underline: const SizedBox.shrink(),
                      items: [
                        for (var i = 1; i <= 9; i++)
                          DropdownMenuItem(
                            value: i,
                            child: Text(tr.splitWeight('$i')),
                          ),
                      ],
                      onChanged: (v) => setState(() => _w[p.id] = v ?? 1),
                    ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr.commonCancel),
        ),
        TextButton(
          onPressed: () {
            final all =
                _w.length == widget.participants.length &&
                _w.values.every((v) => v == 1);
            Navigator.pop(context, (
              assign: all ? null : Map<String, int>.of(_w),
            ));
          },
          child: Text(tr.commonSave),
        ),
      ],
    );
  }
}
