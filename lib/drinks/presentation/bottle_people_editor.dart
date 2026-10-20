import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../l10n/l10n.dart';
import '../../tab/domain/tab_models.dart';
import '../domain/bottle_people.dart';
import '../domain/drink_entry.dart';
import 'drink_form_cubit.dart';

String _nameOf(TabDoc doc, String key) => key == ownerPortionKey
    ? (doc.me?.displayName ?? tr.tabMe)
    : (doc.participant(key)?.displayName ?? tr.ordersUnassigned);

/// "Quanto cada pessoa tomou" and, on a bottle that is already registered, who
/// takes part in it: add or remove people, correct each person's volume and
/// the cost split. Volume and cost are independent; nothing is redistributed
/// or dropped without a choice.
class BottlePeopleEditor extends StatelessWidget {
  const BottlePeopleEditor({
    super.key,
    required this.state,
    required this.doc,
    this.error,
  });

  final DrinkFormState state;
  final TabDoc doc;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    final draft = state.draft;
    final people = state.people;
    final portions = people?.portions ?? draft.portions!;
    final priced = draft.priceKind == PriceKind.informed;
    final bill = draft.billTotalCents;
    final shares = people != null && bill != null && priced
        ? people.costShares(bill)
        : const <String, int>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(tr.formPortionsTitle),
        Text(tr.formPortionsHint, style: AppText.caption),
        const SizedBox(height: AppSpace.sm),
        for (final key in portions.keys)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(_nameOf(doc, key), style: AppText.subtitle),
                    ),
                    SizedBox(
                      width: 120,
                      child: _MlField(
                        key: ValueKey('portion-$key'),
                        value: portions[key],
                        onChanged: (ml) => cubit.setPortion(key, ml),
                      ),
                    ),
                    if (people != null)
                      IconButton(
                        key: ValueKey('remove-$key'),
                        tooltip: tr.bottleRemoveTooltip(_nameOf(doc, key)),
                        icon: const Icon(Icons.person_remove_outlined),
                        onPressed: () => _remove(context, cubit, people, key),
                      ),
                  ],
                ),
                if (people != null && priced)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          [
                            tr.bottleCostParts(people.weightOf(key)),
                            if (shares.containsKey(key))
                              formatCents(shares[key]!),
                          ].join(' · '),
                          style: AppText.caption,
                        ),
                      ),
                      IconButton(
                        key: ValueKey('less-$key'),
                        tooltip: tr.bottleCostLess(_nameOf(doc, key)),
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: people.weightOf(key) <= 0
                            ? null
                            : () => cubit.setWeight(
                                key,
                                people.weightOf(key) - 1,
                              ),
                      ),
                      IconButton(
                        key: ValueKey('more-$key'),
                        tooltip: tr.bottleCostMore(_nameOf(doc, key)),
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: people.weightOf(key) >= 20
                            ? null
                            : () => cubit.setWeight(
                                key,
                                people.weightOf(key) + 1,
                              ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        if (people != null) ...[
          if (priced) Text(tr.bottleCostHint, style: AppText.caption),
          if (priced && !people.hasPayer)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.xs),
              child: Text(
                tr.bottleRemoveNoPayer,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          const SizedBox(height: AppSpace.md),
          SizedBox(
            width: 220,
            child: _MlField(
              key: const ValueKey('bottle-leftover'),
              label: tr.bottleLeftoverLabel,
              value: people.leftoverMl == 0 ? null : people.leftoverMl,
              onChanged: (ml) => cubit.setLeftoverMl(ml ?? 0),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const ValueKey('add-person'),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(tr.bottleAddPerson),
              onPressed: () => _add(context, cubit),
            ),
          ),
        ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.sm),
            child: Text(
              error!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
      ],
    );
  }

  Future<void> _add(BuildContext context, DrinkFormCubit cubit) async {
    final options = cubit.candidatesToAdd;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.bottleAddTitle, style: AppText.title),
              const SizedBox(height: AppSpace.xs),
              Text(
                options.isEmpty ? tr.bottleAddNone : tr.bottleAddHint,
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpace.sm),
              for (final key in options)
                ListTile(
                  key: ValueKey('add-$key'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(_nameOf(doc, key)),
                  onTap: () => Navigator.pop(ctx, key),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) cubit.addPerson(picked);
  }

  Future<void> _remove(
    BuildContext context,
    DrinkFormCubit cubit,
    BottlePeople people,
    String key,
  ) async {
    if (!people.canRemoveAny) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(tr.bottleMinPeople)));
      return;
    }
    if (!people.needsResolution(key)) {
      cubit.removePerson(key);
      return;
    }
    final result = await showDialog<_Resolution>(
      context: context,
      builder: (_) => _RemoveDialog(people: people, doc: doc, keyOf: key),
    );
    if (result == null) return;
    cubit.removePerson(
      key,
      volume: result.volume,
      volumeTo: result.volumeTo,
      money: result.money,
      moneyTo: result.moneyTo,
    );
  }
}

class _Resolution {
  const _Resolution({this.volume, this.volumeTo, this.money, this.moneyTo});
  final VolumeFate? volume;
  final String? volumeTo;
  final MoneyFate? money;
  final String? moneyTo;
}

/// Asks, explicitly, where the volume and the cost share of the person leaving
/// go. Nothing is chosen for the user.
class _RemoveDialog extends StatefulWidget {
  const _RemoveDialog({
    required this.people,
    required this.doc,
    required this.keyOf,
  });

  final BottlePeople people;
  final TabDoc doc;
  final String keyOf;

  @override
  State<_RemoveDialog> createState() => _RemoveDialogState();
}

class _RemoveDialogState extends State<_RemoveDialog> {
  // Encoded choice: 'leftover' | 'to:<key>' | null (nothing chosen yet).
  String? _volume;
  String? _money;

  List<String> get _others => [
    for (final k in widget.people.keys)
      if (k != widget.keyOf) k,
  ];

  bool get _needsVolume => widget.people.volumeToSettle(widget.keyOf) > 0;
  bool get _needsMoney => widget.people.weightToSettle(widget.keyOf) > 0;

  _Resolution? get _resolution {
    if (_needsVolume && _volume == null) return null;
    if (_needsMoney && _money == null) return null;
    return _Resolution(
      volume: !_needsVolume
          ? null
          : (_volume == 'leftover'
                ? VolumeFate.toLeftover
                : VolumeFate.toPerson),
      volumeTo: _volume != null && _volume!.startsWith('to:')
          ? _volume!.substring(3)
          : null,
      money: !_needsMoney
          ? null
          : (_money == 'spread'
                ? MoneyFate.spreadOnOthers
                : MoneyFate.toPerson),
      moneyTo: _money != null && _money!.startsWith('to:')
          ? _money!.substring(3)
          : null,
    );
  }

  /// Spreading the share needs someone else who still pays.
  bool get _canSpread {
    final w = widget.people.weights;
    return _others.any((k) => (w[k] ?? 0) > 0);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.people;
    final name = _nameOf(widget.doc, widget.keyOf);
    final resolution = _resolution;
    return AlertDialog(
      title: Text(tr.bottleRemoveTitle(name)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_needsVolume) ...[
              Text(
                tr.bottleRemoveVolumeAsk(
                  name,
                  formatMl(p.volumeToSettle(widget.keyOf)),
                ),
              ),
              RadioGroup<String>(
                groupValue: _volume,
                onChanged: (v) => setState(() => _volume = v),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      key: const ValueKey('volume-leftover'),
                      contentPadding: EdgeInsets.zero,
                      value: 'leftover',
                      title: Text(tr.bottleRemoveVolumeLeftover),
                    ),
                    for (final k in _others)
                      RadioListTile<String>(
                        key: ValueKey('volume-to-$k'),
                        contentPadding: EdgeInsets.zero,
                        value: 'to:$k',
                        title: Text(
                          tr.bottleRemoveVolumeTo(_nameOf(widget.doc, k)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (_needsMoney) ...[
              const SizedBox(height: AppSpace.md),
              Text(tr.bottleRemoveMoneyAsk(name)),
              RadioGroup<String>(
                groupValue: _money,
                onChanged: (v) => setState(() => _money = v),
                child: Column(
                  children: [
                    if (_canSpread)
                      RadioListTile<String>(
                        key: const ValueKey('money-spread'),
                        contentPadding: EdgeInsets.zero,
                        value: 'spread',
                        title: Text(tr.bottleRemoveMoneySpread),
                      ),
                    for (final k in _others)
                      RadioListTile<String>(
                        key: ValueKey('money-to-$k'),
                        contentPadding: EdgeInsets.zero,
                        value: 'to:$k',
                        title: Text(
                          tr.bottleRemoveMoneyTo(_nameOf(widget.doc, k)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr.commonCancel),
        ),
        TextButton(
          key: const ValueKey('remove-confirm'),
          onPressed: resolution == null
              ? null
              : () => Navigator.pop(context, resolution),
          child: Text(
            tr.bottleRemoveConfirm,
            style: TextStyle(
              color: resolution == null ? null : AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}

/// A whole-ml field that follows outside changes (a volume handed over by
/// someone who left) without fighting the person typing.
class _MlField extends StatefulWidget {
  const _MlField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final int? value;
  final ValueChanged<int?> onChanged;
  final String? label;

  @override
  State<_MlField> createState() => _MlFieldState();
}

class _MlFieldState extends State<_MlField> {
  late final TextEditingController _ctl = TextEditingController(
    text: widget.value?.toString() ?? '',
  );

  int? get _typed {
    final t = _ctl.text.trim();
    return t.isEmpty ? null : int.tryParse(t);
  }

  @override
  void didUpdateWidget(_MlField old) {
    super.didUpdateWidget(old);
    if (_typed != widget.value) {
      _ctl.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _ctl,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      labelText: widget.label,
      suffixText: tr.formPortionMl,
      hintText: tr.volumeUnknown,
    ),
    onChanged: (_) => widget.onChanged(_typed),
  );
}

/// "O que muda ao salvar": shown before saving a bottle whose people or cost
/// split changed. Returns true when the user confirms.
Future<bool> confirmBottleImpact(
  BuildContext context, {
  required TabDoc doc,
  required List<BottleImpactRow> rows,
}) async {
  final changed = [
    for (final r in rows)
      if (r.changed) r,
  ];
  if (changed.isEmpty) return true;
  String ml(int? v) => v == null ? tr.volumeUnknown : formatMl(v);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr.bottleImpactTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.bottleImpactBody, style: AppText.caption),
            const SizedBox(height: AppSpace.md),
            for (final r in changed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        _nameOf(doc, r.key),
                        if (!r.wasIn) tr.bottleImpactJoins,
                        if (!r.isIn) tr.bottleImpactLeaves,
                      ].join(' · '),
                      style: AppText.subtitle,
                    ),
                    if (r.mlBefore != r.mlAfter)
                      Text(
                        tr.bottleImpactVolume(ml(r.mlBefore), ml(r.mlAfter)),
                      ),
                    if (r.costBefore != r.costAfter)
                      Text(
                        tr.bottleImpactCost(
                          formatCents(r.costBefore),
                          formatCents(r.costAfter),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(tr.entryKeepEditing),
        ),
        FilledButton(
          key: const ValueKey('impact-confirm'),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(tr.bottleImpactConfirm),
        ),
      ],
    ),
  );
  return ok == true;
}
