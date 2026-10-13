import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import '../domain/recipe.dart';
import '../domain/drink_draft.dart';
import '../domain/drink_entry.dart';
import 'drink_form_cubit.dart';
import 'unit_dropdown.dart';

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
              title: Text(d.isEditing
                  ? 'Corrigir registro'
                  : (d.isRecipe ? 'Registrar drink' : 'Registrar bebida')),
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
                      if (d.isRecipe)
                        ...[
                        _RecipeSection(state: state, errors: errors),
                        ]
                      else ...[
                      const SectionTitle('Bebida e tamanho'),
                      if (state.presentations.isNotEmpty) ...[
                        Wrap(
                          spacing: AppSpace.sm,
                          runSpacing: AppSpace.sm,
                          children: [
                            for (final p in state.presentations)
                              ChoiceChip(
                                label: Text(p.label),
                                selected: p.isSuggestion
                                    ? (d.presentationLabel == null &&
                                        d.containerMl == p.volumeMl)
                                    : d.presentationLabel == p.label,
                                showCheckmark: false,
                                onSelected: (_) => cubit.selectPresentation(p),
                              ),
                          ],
                        ),
                        if (state.sizesAreGeneric)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpace.sm),
                            child: Text(
                              d.category == DrinkCategory.spirit
                                  ? 'Doses sugeridas, editáveis: não são '
                                      'medidas oficiais de nenhum '
                                      'estabelecimento. A garrafa é a '
                                      'embalagem, não a sua dose.'
                                  : 'Tamanhos sugeridos: este produto não tem '
                                      'embalagens verificadas no catálogo. '
                                      'Confira na embalagem.',
                              style: AppText.caption,
                            ),
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
                        if (state.abvVariants.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.sm),
                          const Text(
                            'As fontes divergem. Escolha o que estiver no seu '
                            'rótulo ou digite:',
                            style: AppText.caption,
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Wrap(
                            spacing: AppSpace.sm,
                            runSpacing: AppSpace.sm,
                            children: [
                              for (final v in state.abvVariants)
                                ActionChip(
                                  label: Text(
                                      '${formatAbv(v.value)} · ${v.scope}'),
                                  onPressed: () => cubit.setAbv(v.value),
                                ),
                            ],
                          ),
                        ],
                      ],
                      if (state.bottles.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.md),
                        Text(
                          d.isShared
                              ? 'Garrafa que está sendo dividida (preenche o '
                                  'volume da garrafa):'
                              : 'Embalagens do produto: '
                                  '${state.bottles.map((b) => b.label).join(', ')}. '
                                  'Para dividir uma garrafa, marque '
                                  '"Compartilhada" abaixo.',
                          style: AppText.caption,
                        ),
                        if (d.isShared)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpace.sm),
                            child: Wrap(
                              spacing: AppSpace.sm,
                              runSpacing: AppSpace.sm,
                              children: [
                                for (final b in state.bottles)
                                  ChoiceChip(
                                    label: Text(b.label),
                                    selected: d.containerMl == b.volumeMl,
                                    showCheckmark: false,
                                    onSelected: (_) =>
                                        cubit.selectPresentation(b),
                                  ),
                              ],
                            ),
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
                                : (d.isRecipe
                                    ? 'Registrar drink'
                                    : 'Registrar bebida')),
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


/// Mixed drink: the composition (collapsed by default), the optional served
/// volume and the honest alcohol preview.
class _RecipeSection extends StatelessWidget {
  const _RecipeSection({required this.state, required this.errors});

  final DrinkFormState state;
  final Map<String, String> errors;

  Future<void> _addComponent(BuildContext context) async {
    final cubit = context.read<DrinkFormCubit>();
    final nameController = TextEditingController();
    var alcoholic = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Adicionar ingrediente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Ingrediente'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tem álcool'),
                value: alcoholic,
                activeThumbColor: AppColors.amber,
                onChanged: (v) => setState(() => alcoholic = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Adicionar')),
          ],
        ),
      ),
    );
    if (ok == true) {
      cubit.addComponent(nameController.text, alcoholic: alcoholic);
    }
    nameController.dispose();
  }

  Future<void> _saveRecipe(BuildContext context) async {
    final cubit = context.read<DrinkFormCubit>();
    final d = state.draft;
    final controller = TextEditingController(
      text: d.composition?.customized == true ? '${d.name} (minha)' : d.name,
    );
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salvar como minha receita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome da receita'),
            ),
            const SizedBox(height: AppSpace.sm),
            const Text(
              'Guarda ingredientes, quantidades e teores para reutilizar. '
              'Registros antigos não mudam.',
              style: AppText.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Salvar')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || !context.mounted) return;
    final error = await cubit.saveAsMyRecipe(name);
    if (context.mounted) {
      showToast(context, error ?? 'Receita salva no seu catálogo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    final d = state.draft;
    final comp = d.composition!;
    final estimate = d.alcoholEstimate;
    final summary = d.components.map((c) => c.name).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Composição'),
        Text(
          comp.recipeId == null || comp.sourceLabel == null
              ? 'Informe só o que você sabe.'
              : 'Receita de referência (${comp.sourceLabel}). Ajuste para '
                  'o que foi realmente servido.',
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpace.sm),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: AppSpace.md),
              title: Text(
                comp.customized ? 'Composição ajustada' : 'Ver e ajustar composição',
                style: AppText.subtitle,
              ),
              subtitle: Text(
                summary.isEmpty ? 'Nenhum ingrediente ainda' : summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption,
              ),
              children: [
                for (var i = 0; i < d.components.length; i++)
                  _ComponentCard(
                    key: ValueKey('component-$i-${d.components[i].name}'),
                    index: i,
                    component: d.components[i],
                    abvError: errors['component_abv_$i'],
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _addComponent(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Adicionar ingrediente'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('Volume do drink (opcional)'),
        _NumberField<int>(
          label: 'Volume servido (ml)',
          suffix: 'ml',
          value: d.containerMl,
          parse: parseInteger,
          format: (v) => '$v',
          keyboardType: TextInputType.number,
          errorText: errors['volume'],
          helper: 'Se não souber, deixe em branco: o resumo mostra como '
              'desconhecido. O tamanho do copo e o gelo não contam como '
              'volume bebido.',
          onChanged: cubit.setVolume,
        ),
        if (estimate != null) ...[
          const SizedBox(height: AppSpace.md),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatTile(
                  label: 'Álcool puro da composição acima',
                  value: (estimate.isComplete ? '' : 'pelo menos ') +
                      formatGrams(estimate.grams),
                  icon: Icons.science_outlined,
                ),
                const SizedBox(height: AppSpace.sm),
                if (!estimate.isComplete)
                  InfoPill(
                    'Faltam teor ou quantidade de: ${estimate.missing.join(', ')}',
                    icon: Icons.help_outline_rounded,
                    warning: true,
                  ),
                const SizedBox(height: AppSpace.sm),
                const Text(
                  'Vale a composição declarada, assumindo a porção inteira. '
                  'Não é concentração no sangue.',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
        ],
        if (d.components.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _saveRecipe(context),
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: const Text('Salvar como minha receita'),
            ),
          ),
      ],
    );
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({
    super.key,
    required this.index,
    required this.component,
    this.abvError,
  });

  final int index;
  final EntryComponent component;
  final String? abvError;

  Future<void> _pickProduct(BuildContext context) async {
    final cubit = context.read<DrinkFormCubit>();
    final products = cubit.productsForRole(component.role!);
    final picked = await showModalBottomSheet<_ProductChoice>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
              AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
          children: [
            Text('Qual ${component.name.toLowerCase()}?', style: AppText.title),
            const SizedBox(height: AppSpace.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Sem marca: informar o teor'),
              onTap: () => Navigator.pop(ctx, const _ProductChoice(null)),
            ),
            for (final p in products)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(p.category.icon, color: AppColors.amber),
                title: Text(p.displayName),
                subtitle: Text(
                  p.abvPercent != null
                      ? 'Teor ${formatAbv(p.abvPercent!)}'
                      : (p.abvVariants.isNotEmpty
                          ? 'Teor varia conforme a fonte'
                          : 'Teor não informado'),
                  style: AppText.caption,
                ),
                onTap: () => Navigator.pop(ctx, _ProductChoice(p)),
              ),
          ],
        ),
      ),
    );
    if (picked != null) cubit.pickComponentProduct(index, picked.product);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    final c = component;
    final pure = c.pureAlcoholMl;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  c.name + (c.optional ? ' (opcional)' : ''),
                  style: AppText.subtitle,
                ),
              ),
              if (c.alcoholic)
                const Icon(Icons.local_bar_outlined,
                    size: 16, color: AppColors.amber),
              IconButton(
                tooltip: 'Remover ingrediente',
                onPressed: () => cubit.removeComponent(index),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ]),
            if (c.amount == null && c.amountText != null)
              Text('Na receita: ${c.amountText}', style: AppText.caption),
            const SizedBox(height: AppSpace.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.unit != RecipeUnit.toTaste && c.unit != RecipeUnit.other)
                  Expanded(
                    child: _NumberField<double>(
                      label: 'Quantidade',
                      suffix: c.unit.shortLabel,
                      value: c.amount,
                      parse: parseDecimal,
                      format: decimalToInput,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      helper: c.amount == null
                          ? 'Em branco = desconhecida.'
                          : null,
                      onChanged: (v) => cubit.setComponentAmount(index, v),
                    ),
                  ),
                if (c.unit != RecipeUnit.toTaste && c.unit != RecipeUnit.other)
                  const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: UnitDropdown(
                    value: c.unit,
                    onChanged: (u) => cubit.setComponentUnit(index, u),
                  ),
                ),
              ],
            ),
            if (c.alcoholic) ...[
              const SizedBox(height: AppSpace.sm),
              if (c.role != null)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44)),
                  onPressed: () => _pickProduct(context),
                  icon: const Icon(Icons.local_offer_outlined, size: 18),
                  label: Text(
                    c.productName ?? 'Escolher marca/produto',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (c.role != null) const SizedBox(height: AppSpace.sm),
              _NumberField<double>(
                label: 'Teor alcoólico (% vol.)',
                suffix: '% vol.',
                value: c.abvPercent,
                parse: parseDecimal,
                format: decimalToInput,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                errorText: abvError,
                helper: c.abvPercent == null
                    ? 'Desconhecido: sem ele o álcool total fica incompleto.'
                    : null,
                onChanged: (v) => cubit.setComponentAbv(index, v),
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                pure == null
                    ? 'Álcool deste ingrediente: não calculado '
                        '(${c.alcoholGap ?? 'dados incompletos'}).'
                    : 'Álcool deste ingrediente: ${formatGrams(pure * 0.789)}',
                style: AppText.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Result of the product picker (null product = "no brand").
class _ProductChoice {
  const _ProductChoice(this.product);

  final CatalogItem? product;
}
