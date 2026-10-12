import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_draft.dart';
import '../domain/drink_entry.dart';
import 'drink_form_cubit.dart';

/// Register a drink (create) or correct an existing record (edit).
/// Pops `true` when something was saved or deleted.
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    return BlocConsumer<DrinkFormCubit, DrinkFormState>(
      listenWhen: (p, c) => !p.saved && c.saved,
      listener: (context, state) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final d = state.draft;
        final errors = state.showErrors ? d.errors : const <String, String>{};
        return Scaffold(
          appBar: AppBar(
            title: Text(d.isEditing ? 'Corrigir registro' : 'Registrar bebida'),
            actions: [
              if (d.isEditing)
                IconButton(
                  tooltip: 'Excluir',
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      _Header(draft: d),
                      if (state.presentations.isNotEmpty) ...[
                        const SectionTitle('TAMANHO'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                        const SizedBox(height: 12),
                      ] else
                        const SectionTitle('TAMANHO'),
                      _NumberField<int>(
                        label: 'Volume (ml)',
                        suffix: 'ml',
                        value: d.containerMl,
                        parse: parseInteger,
                        format: (v) => '$v',
                        keyboardType: TextInputType.number,
                        errorText: errors['volume'],
                        onChanged: cubit.setVolume,
                      ),
                      if (d.category.canBeAlcoholic) ...[
                        const SectionTitle('TEOR ALCOÓLICO'),
                        _NumberField<double>(
                          label: 'Teor (% vol.)',
                          suffix: '% vol.',
                          value: d.abvPercent,
                          parse: parseDecimal,
                          format: decimalToInput,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          errorText: errors['abv'],
                          helper: d.abvPercent == null
                              ? 'Desconhecido: não conta como zero no resumo.'
                              : 'Confira no rótulo se puder.',
                          onChanged: cubit.setAbv,
                        ),
                      ],
                      const SectionTitle('COMPARTILHAMENTO'),
                      _SharingCard(draft: d, errors: errors),
                      const SectionTitle('PREÇO'),
                      _PriceCard(draft: d, errors: errors),
                      const SectionTitle('HORÁRIO'),
                      SurfaceCard(
                        onTap: () async {
                          final picked =
                              await pickDateTime(context, d.consumedAt);
                          if (picked != null) cubit.setConsumedAt(picked);
                        },
                        child: Row(children: [
                          const Icon(Icons.schedule_rounded,
                              color: AppColors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              formatDateTime(d.consumedAt),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Text('Ajustar',
                              style: TextStyle(color: AppColors.amber)),
                        ]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: AppColors.outline)),
                  ),
                  child: FilledButton(
                    onPressed: state.saving ? null : cubit.submit,
                    child: Text(
                        d.isEditing ? 'Salvar alterações' : 'Registrar bebida'),
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
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(draft.category.icon, color: AppColors.amber, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draft.name,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              Text(info, style: const TextStyle(color: AppColors.textMuted)),
              if (draft.ingredients != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Ingredientes: ${draft.ingredients!.join(', ')}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              if (draft.note != null || draft.origin == InfoOrigin.generic)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${draft.origin.label}'
                    '${draft.note != null ? ' · ${draft.note}' : ''}',
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
    return SurfaceCard(
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(draft.isShared ? 'Compartilhada' : 'Só minha'),
          subtitle: const Text('Garrafa ou porção dividida com outras pessoas'),
          value: draft.isShared,
          activeThumbColor: AppColors.amber,
          onChanged: cubit.setShared,
        ),
        if (draft.isShared)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(
                    child: Text('Pessoas (com você)',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  IconButton.filledTonal(
                    onPressed: draft.peopleCount > 2
                        ? () => cubit.setPeople(draft.peopleCount - 1)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${draft.peopleCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: draft.peopleCount < DrinkDraft.maxPeople
                        ? () => cubit.setPeople(draft.peopleCount + 1)
                        : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ]),
                const SizedBox(height: 12),
                _NumberField<int>(
                  label: 'Sua parte (ml)',
                  suffix: 'ml',
                  value: draft.personalMl,
                  parse: parseInteger,
                  format: (v) => '$v',
                  keyboardType: TextInputType.number,
                  errorText: errors['personal'],
                  helper: 'Divisão igual por padrão; ajuste se precisar.',
                  onChanged: cubit.setPersonalMl,
                ),
                const SizedBox(height: 12),
                _NumberField<int>(
                  label: 'Sobra (ml)',
                  suffix: 'ml',
                  value: draft.leftoverMl == 0 ? null : draft.leftoverMl,
                  parse: parseInteger,
                  format: (v) => '$v',
                  keyboardType: TextInputType.number,
                  helper: 'Opcional: o que ficou na garrafa.',
                  onChanged: (v) => cubit.setLeftoverMl(v ?? 0),
                ),
                if (others != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Sobram ${formatMl(others)} para cada uma das outras '
                      '${draft.peopleCount - 1} pessoas.',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
      ]),
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
          const SizedBox(height: 12),
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
              const SizedBox(height: 12),
            ],
            _NumberField<int>(
              label: draft.isShared
                  ? 'Quanto você pagou'
                  : 'Preço pago',
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
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
