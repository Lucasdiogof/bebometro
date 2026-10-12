import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_draft.dart';
import '../domain/drink_entry.dart';
import 'drink_form_cubit.dart';

/// How the entry screen was closed, when it changed something.
enum EntryOutcome { saved, deleted }

/// Register a drink (create) or correct an existing record (edit).
/// Pops an [EntryOutcome] when something was saved or deleted.
class DrinkEntryPage extends StatelessWidget {
  const DrinkEntryPage._(this._create, {super.key});

  factory DrinkEntryPage.create({
    Key? key,
    required String outingId,
    required CatalogItem item,
  }) =>
      DrinkEntryPage._(
        () => getIt<DrinkFormCubit>(
          param1: (outingId: outingId, item: item),
          instanceName: 'new',
        ),
        key: key,
      );

  factory DrinkEntryPage.edit({Key? key, required DrinkEntry entry}) =>
      DrinkEntryPage._(
        () => getIt<DrinkFormCubit>(param1: entry, instanceName: 'edit'),
        key: key,
      );

  final DrinkFormCubit Function() _create;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _create(),
      child: const _DrinkEntryView(),
    );
  }
}

class _DrinkEntryView extends StatelessWidget {
  const _DrinkEntryView();

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<DrinkFormCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: const Text('Ele sai do rolê e do resumo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await cubit.delete();
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você preencheu aqui será perdido.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continuar editando')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Descartar',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (leave == true && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    return BlocConsumer<DrinkFormCubit, DrinkFormState>(
      listenWhen: (p, c) =>
          (!p.saved && c.saved) ||
          (!p.deleted && c.deleted) ||
          (c.error != null && c.error != p.error),
      listener: (context, state) {
        if (state.saved) {
          Navigator.of(context).pop(EntryOutcome.saved);
        } else if (state.deleted) {
          Navigator.of(context).pop(EntryOutcome.deleted);
        } else if (state.error != null) {
          showToast(context, state.error!);
        }
      },
      builder: (context, state) {
        final d = state.draft;
        final errors = state.showErrors ? d.errors : const <String, String>{};
        final canLeave = !state.dirty || state.saved || state.deleted;
        return PopScope(
          canPop: canLeave,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmDiscard(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(d.isEditing ? 'Corrigir registro' : 'Registrar bebida'),
              actions: [
                if (d.isEditing)
                  IconButton(
                    tooltip: 'Excluir',
                    onPressed:
                        state.saving ? null : () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
                  ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                        AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                    children: [
                      _Header(draft: d),
                      const SectionTitle('Bebida e tamanho'),
                      if (state.presentations.isNotEmpty) ...[
                        Wrap(
                          spacing: AppSpace.sm,
                          runSpacing: AppSpace.sm,
                          children: [
                            for (final p in state.presentations)
                              ChoiceChip(
                                label: Text(p.label),
                                selected: d.presentationLabel == p.label,
                                showCheckmark: false,
                                onSelected: (_) => cubit.selectPresentation(p),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.md),
                      ],
                      _NumberField<int>(
                        label: state.presentations.isEmpty
                            ? 'Volume (ml)'
                            : 'Outro tamanho (ml)',
                        suffix: 'ml',
                        value: d.containerMl,
                        parse: parseInteger,
                        format: (v) => '$v',
                        keyboardType: TextInputType.number,
                        errorText: errors['volume'],
                        onChanged: cubit.setVolume,
                      ),
                      if (d.category.canBeAlcoholic) ...[
                        const SizedBox(height: AppSpace.md),
                        _NumberField<double>(
                          label: 'Teor alcoólico (opcional)',
                          suffix: '% vol.',
                          value: d.abvPercent,
                          parse: parseDecimal,
                          format: decimalToInput,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          errorText: errors['abv'],
                          helper: d.abvPercent == null
                              ? 'Em branco = desconhecido (não conta como zero).'
                              : 'Confira no rótulo se puder.',
                          onChanged: cubit.setAbv,
                        ),
                      ],
                      const SectionTitle('Individual ou compartilhada'),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(value: false, label: Text('Só minha')),
                            ButtonSegment(
                                value: true, label: Text('Compartilhada')),
                          ],
                          selected: {d.isShared},
                          onSelectionChanged: (s) => cubit.setShared(s.first),
                        ),
                      ),
                      if (d.isShared) ...[
                        const SizedBox(height: AppSpace.md),
                        _SharingCard(draft: d, errors: errors),
                      ],
                      const SectionTitle('Preço (opcional)'),
                      _PriceCard(draft: d, errors: errors),
                      const SectionTitle('Horário'),
                      SurfaceCard(
                        onTap: () async {
                          final picked =
                              await pickDateTime(context, d.consumedAt);
                          if (picked != null) cubit.setConsumedAt(picked);
                        },
                        child: Row(children: [
                          const Icon(Icons.schedule_rounded,
                              color: AppColors.amber),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Text(formatDateTime(d.consumedAt),
                                style: AppText.subtitle),
                          ),
                          const Text('Ajustar',
                              style: TextStyle(color: AppColors.amber)),
                        ]),
                      ),
                      if (errors['time'] != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: AppSpace.sm, left: AppSpace.xs),
                          child: Text(errors['time']!,
                              style: const TextStyle(color: AppColors.danger)),
                        ),
                    ],
                  ),
                ),
                BottomActionBar(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (d.isShared && d.personalMl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.sm),
                          child: Text(
                            'Sua parte: ${formatMl(d.personalMl!)}',
                            style: AppText.caption,
                          ),
                        ),
                      FilledButton(
                        onPressed: state.saving ? null : cubit.submit,
                        child: state.saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(d.isEditing
                                ? 'Salvar alterações'
                                : 'Registrar bebida'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.draft});

  final DrinkDraft draft;

  @override
  Widget build(BuildContext context) {
    final info = <String>[
      if (draft.brand != null) draft.brand!,
      if (draft.style != null) draft.style!,
      draft.category.label,
    ].join(' · ');
    return SurfaceCard(
      highlight: true,
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(draft.category.icon, color: AppColors.amber, size: 28),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(draft.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title),
              Text(info, style: AppText.caption),
              if (draft.ingredients != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.xs),
                  child: Text(
                    'Ingredientes: ${draft.ingredients!.join(', ')}',
                    style: AppText.caption.copyWith(fontSize: 12),
                  ),
                ),
              if (draft.note != null || draft.origin == InfoOrigin.generic)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.xs),
                  child: Text(
                    draft.origin.label +
                        (draft.note != null ? ' · ${draft.note}' : ''),
                    style: TextStyle(
                      color: AppColors.amber.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _SharingCard extends StatelessWidget {
  const _SharingCard({required this.draft, required this.errors});

  final DrinkDraft draft;
  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    final others = draft.othersEachMl;
    final personal = draft.personalMl;
    return SurfaceCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            personal == null ? 'Sua parte: —' : 'Sua parte: ${formatMl(personal)}',
            style: AppText.headline.copyWith(fontSize: 26),
          ),
          if (draft.containerMl != null)
            Text(
              'de ${formatMl(draft.containerMl!)} · '
              '${draft.peopleCount} pessoas, com você',
              style: AppText.caption,
            ),
          const SizedBox(height: AppSpace.md),
          Row(children: [
            const Expanded(
              child: Text('Pessoas (incluindo você)', style: AppText.body),
            ),
            IconButton.filledTonal(
              tooltip: 'Menos uma pessoa',
              onPressed: draft.peopleCount > 2
                  ? () => cubit.setPeople(draft.peopleCount - 1)
                  : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            SizedBox(
              width: 44,
              child: Text('${draft.peopleCount}',
                  textAlign: TextAlign.center, style: AppText.value),
            ),
            IconButton.filledTonal(
              tooltip: 'Mais uma pessoa',
              onPressed: draft.peopleCount < DrinkDraft.maxPeople
                  ? () => cubit.setPeople(draft.peopleCount + 1)
                  : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ]),
          if (errors['personal'] != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.sm),
              child: Text(errors['personal']!,
                  style: const TextStyle(color: AppColors.danger)),
            ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: AppSpace.sm),
              initiallyExpanded: errors['personal'] != null,
              title: const Text('Ajustar parcela e sobra',
                  style: TextStyle(color: AppColors.amber)),
              children: [
                _NumberField<int>(
                  label: 'Sua parte (ml)',
                  suffix: 'ml',
                  value: draft.personalMl,
                  parse: parseInteger,
                  format: (v) => '$v',
                  keyboardType: TextInputType.number,
                  helper: 'Divisão igual por padrão.',
                  onChanged: cubit.setPersonalMl,
                ),
                const SizedBox(height: AppSpace.md),
                _NumberField<int>(
                  label: 'Sobra na garrafa (ml)',
                  suffix: 'ml',
                  value: draft.leftoverMl == 0 ? null : draft.leftoverMl,
                  parse: parseInteger,
                  format: (v) => '$v',
                  keyboardType: TextInputType.number,
                  helper: 'Opcional.',
                  onChanged: (v) => cubit.setLeftoverMl(v ?? 0),
                ),
                if (others != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.md),
                    child: Text(
                      'Sobram ${formatMl(others)} para cada uma das outras '
                      '${draft.peopleCount - 1} pessoas.',
                      style: AppText.caption,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.draft, required this.errors});

  final DrinkDraft draft;
  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<PriceKind>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: PriceKind.informed, label: Text('Valor')),
                ButtonSegment(
                    value: PriceKind.complimentary, label: Text('Cortesia')),
                ButtonSegment(value: PriceKind.unknown, label: Text('Não sei')),
              ],
              selected: {draft.priceKind},
              onSelectionChanged: (s) => cubit.setPriceKind(s.first),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          if (draft.priceKind == PriceKind.informed) ...[
            if (draft.isShared) ...[
              _NumberField<int>(
                label: 'Total da conta/garrafa (opcional)',
                prefix: r'R$ ',
                value: draft.billTotalCents,
                parse: parseCents,
                format: centsToInput,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: cubit.setBillTotalCents,
              ),
              const SizedBox(height: AppSpace.md),
            ],
            _NumberField<int>(
              label: draft.isShared ? 'Quanto você pagou' : 'Preço pago',
              prefix: r'R$ ',
              value: draft.paidCents,
              parse: parseCents,
              format: centsToInput,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              errorText: errors['paid'],
              helper: draft.isShared
                  ? 'O que você pagou, não o que bebeu.'
                  : null,
              onChanged: cubit.setPaidCents,
            ),
            if (draft.isShared && draft.billTotalCents != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: cubit.suggestPayment,
                  icon: const Icon(Icons.call_split_rounded, size: 18),
                  label: Text(
                      'Dividir igualmente (${draft.peopleCount} pessoas)'),
                ),
              ),
          ] else
            Text(
              draft.priceKind == PriceKind.complimentary
                  ? 'Cortesia conta como R\$ 0,00 informado.'
                  : 'Sem preço: aparece como "sem preço" no resumo.',
              style: AppText.caption,
            ),
        ],
      ),
    );
  }
}

/// Text field bound to a typed value. Keeps the on-screen text in sync when
/// the value is changed by the form logic (e.g. equal split), without
/// fighting what the user is typing.
class _NumberField<T> extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.parse,
    required this.format,
    required this.onChanged,
    required this.keyboardType,
    this.suffix,
    this.prefix,
    this.helper,
    this.errorText,
  });

  final String label;
  final String? suffix;
  final String? prefix;
  final String? helper;
  final String? errorText;
  final T? value;
  final T? Function(String) parse;
  final String Function(T) format;
  final ValueChanged<T?> onChanged;
  final TextInputType keyboardType;

  @override
  State<_NumberField<T>> createState() => _NumberFieldState<T>();
}

class _NumberFieldState<T> extends State<_NumberField<T>> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value == null ? '' : widget.format(widget.value as T),
  );

  @override
  void didUpdateWidget(_NumberField<T> old) {
    super.didUpdateWidget(old);
    if (widget.parse(_controller.text) != widget.value) {
      final text =
          widget.value == null ? '' : widget.format(widget.value as T);
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      onChanged: (text) => widget.onChanged(widget.parse(text)),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: widget.suffix,
        prefixText: widget.prefix,
        helperText: widget.helper,
        helperMaxLines: 2,
        errorText: widget.errorText,
        errorMaxLines: 2,
      ),
    );
  }
}
