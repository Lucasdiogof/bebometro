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
import '../domain/price_history.dart';
import 'drink_form_cubit.dart';
import 'unit_dropdown.dart';
import '../../l10n/l10n.dart';

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
        title: Text(tr.entryDeleteTitle),
        content: Text(tr.entryDeleteBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr.commonCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr.commonDelete,
                  style: const TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await cubit.delete();
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.entryDiscardTitle),
        content: Text(tr.entryDiscardBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr.entryKeepEditing)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr.entryDiscard,
                  style: const TextStyle(color: AppColors.danger))),
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
                  ? tr.entryFix
                  : (d.isRecipe ? tr.entryLogCocktail : tr.entryLogDrink)),
              actions: [
                if (d.isEditing)
                  IconButton(
                    tooltip: tr.commonDelete,
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
                      SectionTitle(tr.entryDrinkAndSize),
                      if (state.presentations.isNotEmpty) ...[
                        Wrap(
                          spacing: AppSpace.sm,
                          runSpacing: AppSpace.sm,
                          children: [
                            for (final p in state.presentations)
                              ChoiceChip(
                                label: Text(p.displayLabel),
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
                                  ? tr.entryGenericSpirit
                                  : tr.entryGenericSizes,
                              style: AppText.caption,
                            ),
                          ),
                        const SizedBox(height: AppSpace.md),
                      ],
                      _NumberField<int>(
                        label: state.presentations.isEmpty
                            ? tr.entryVolume
                            : tr.entryOtherSize,
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
                          label: tr.entryAbvOptional,
                          suffix: '% vol.',
                          numeric: true,
                          value: d.abvPercent,
                          parse: parseDecimal,
                          format: decimalToInput,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          errorText: errors['abv'],
                          helper: d.abvPercent == null
                              ? tr.entryAbvBlank
                              : tr.entryAbvCheck,
                          onChanged: cubit.setAbv,
                        ),
                        if (state.abvVariants.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.sm),
                          Text(tr.entryAbvVariantsIntro,
                              style: AppText.caption),
                          const SizedBox(height: AppSpace.xs),
                          Wrap(
                            spacing: AppSpace.sm,
                            runSpacing: AppSpace.sm,
                            children: [
                              for (final v in state.abvVariants)
                                ActionChip(
                                  label: Text(
                                      '${formatAbv(v.value)} · ${v.displayScope}'),
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
                              ? tr.entryBottleShared
                              : tr.entryBottlesInfo(state.bottles
                                  .map((b) => b.displayLabel)
                                  .join(', ')),
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
                                    label: Text(b.displayLabel),
                                    selected: d.containerMl == b.volumeMl,
                                    showCheckmark: false,
                                    onSelected: (_) =>
                                        cubit.selectPresentation(b),
                                  ),
                              ],
                            ),
                          ),
                      ],
                      SectionTitle(tr.entryIndividualOrShared),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                                value: false, label: Text(tr.entryOnlyMine)),
                            ButtonSegment(
                                value: true, label: Text(tr.entryShared)),
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
                      SectionTitle(tr.entryPriceSection),
                      _PriceCard(
                        draft: d,
                        errors: errors,
                        suggestion: state.suggestion,
                        scope: state.suggestionAtPlace
                            ? tr.entryScopeAtPlace
                            : tr.entryScopeAtOuting,
                        advertisedCents: state.advertisedCents,
                      ),
                      SectionTitle(tr.entryTimeSection),
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
                          Text(tr.commonAdjust,
                              style: const TextStyle(color: AppColors.amber)),
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
                            tr.entryYourShare(formatMl(d.personalMl!)),
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
                                ? tr.entrySaveChanges
                                : (d.isRecipe
                                    ? tr.entryLogCocktail
                                    : tr.entryLogDrink)),
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
      if (draft.style != null) styleLabel(draft.style!),
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
                    tr.entryIngredients(draft.ingredients!.join(', ')),
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
            personal == null
                ? tr.entryYourShareUnknown
                : tr.entryYourShare(formatMl(personal)),
            style: AppText.headline.copyWith(fontSize: 26),
          ),
          if (draft.containerMl != null)
            Text(
              tr.entrySharedLine(
                  formatMl(draft.containerMl!), draft.peopleCount),
              style: AppText.caption,
            ),
          const SizedBox(height: AppSpace.md),
          Row(children: [
            Expanded(
              child: Text(tr.entryPeople, style: AppText.body),
            ),
            IconButton.filledTonal(
              tooltip: tr.entryFewerPeople,
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
              tooltip: tr.entryMorePeople,
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
              title: Text(tr.entryAdjustShare,
                  style: const TextStyle(color: AppColors.amber)),
              children: [
                _NumberField<int>(
                  label: tr.entryYourShareMl,
                  suffix: 'ml',
                  value: draft.personalMl,
                  parse: parseInteger,
                  format: (v) => '$v',
                  keyboardType: TextInputType.number,
                  helper: tr.entryEqualSplit,
                  onChanged: cubit.setPersonalMl,
                ),
                const SizedBox(height: AppSpace.md),
                _NumberField<int>(
                  label: tr.entryLeftover,
                  suffix: 'ml',
                  value: draft.leftoverMl == 0 ? null : draft.leftoverMl,
                  parse: parseInteger,
                  format: (v) => '$v',
                  keyboardType: TextInputType.number,
                  helper: tr.entryOptionalDot,
                  onChanged: (v) => cubit.setLeftoverMl(v ?? 0),
                ),
                if (others != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.md),
                    child: Text(
                      tr.entryOthersEach(
                          formatMl(others), draft.peopleCount - 1),
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
  const _PriceCard({
    required this.draft,
    required this.errors,
    required this.suggestion,
    required this.scope,
    this.advertisedCents,
  });

  final DrinkDraft draft;
  final Map<String, String> errors;
  final PriceSuggestion suggestion;
  final String scope;
  final int? advertisedCents;

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
              segments: [
                ButtonSegment(
                    value: PriceKind.informed, label: Text(tr.entryPriceValue)),
                ButtonSegment(
                    value: PriceKind.complimentary,
                    label: Text(tr.priceComplimentary)),
                ButtonSegment(
                    value: PriceKind.unknown, label: Text(tr.entryPriceDontKnow)),
              ],
              selected: {draft.priceKind},
              onSelectionChanged: (s) => cubit.setPriceKind(s.first),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          if (advertisedCents != null) ...[
            _AdvertisedBanner(draft: draft, cents: advertisedCents!),
            const SizedBox(height: AppSpace.md),
          ],
          if (!suggestion.isEmpty) ...[
            _SuggestionBanner(
                draft: draft, suggestion: suggestion, scope: scope),
            const SizedBox(height: AppSpace.md),
          ],
          if (draft.priceKind == PriceKind.informed) ...[
            if (draft.isShared) ...[
              _NumberField<int>(
                label: tr.entryBillTotal,
                prefix: r'R$ ',
                numeric: true,
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
              label:
                  draft.isShared ? tr.priceFixPaidShared : tr.priceFixPaidLabel,
              prefix: r'R$ ',
              numeric: true,
              value: draft.paidCents,
              parse: parseCents,
              format: centsToInput,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              errorText: errors['paid'],
              helper: draft.isShared ? tr.entryPaidHelper : null,
              onChanged: cubit.setPaidCents,
            ),
            if (draft.isShared && draft.billTotalCents != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: cubit.suggestPayment,
                  icon: const Icon(Icons.call_split_rounded, size: 18),
                  label: Text(tr.entrySplitEqually(draft.peopleCount)),
                ),
              ),
          ] else
            Text(
              draft.priceKind == PriceKind.complimentary
                  ? tr.entryComplimentaryNote(formatCents(0))
                  : tr.entryNoPriceNote,
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
    this.numeric = false,
  });

  /// A decimal or money field: an unreadable or ambiguous text ("1.500") is
  /// flagged in the field instead of being guessed.
  final bool numeric;
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
  String? _formatError;

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
      onChanged: (text) {
        if (widget.numeric) {
          setState(() => _formatError = numberInputError(text));
        }
        widget.onChanged(widget.parse(text));
      },
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: widget.suffix,
        prefixText: widget.prefix,
        helperText: widget.helper,
        helperMaxLines: 2,
        errorText: widget.errorText ?? _formatError,
        errorMaxLines: 3,
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
          title: Text(tr.entryAddIngredient),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: tr.entryIngredientField),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr.entryHasAlcohol),
                value: alcoholic,
                activeThumbColor: AppColors.amber,
                onChanged: (v) => setState(() => alcoholic = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr.commonCancel)),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr.commonAdd)),
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
      text: d.composition?.customized == true
          ? tr.entryMineSuffix(d.name)
          : d.name,
    );
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.entrySaveRecipeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: tr.entryRecipeName),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(tr.entrySaveRecipeBody, style: AppText.caption),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr.commonCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text(tr.commonSave)),
        ],
      ),
    );
    controller.dispose();
    if (name == null || !context.mounted) return;
    final error = await cubit.saveAsMyRecipe(name);
    if (context.mounted) {
      showToast(context, error ?? tr.entryRecipeSaved);
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
        SectionTitle(tr.entryCompositionTitle),
        Text(
          comp.recipeId == null || comp.sourceLabel == null
              ? tr.entryCompositionSimple
              : tr.entryCompositionReference(comp.sourceLabel!),
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
                comp.customized
                    ? tr.entryCompositionAdjusted
                    : tr.entryCompositionView,
                style: AppText.subtitle,
              ),
              subtitle: Text(
                summary.isEmpty ? tr.entryNoIngredients : summary,
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
                    label: Text(tr.entryAddIngredient),
                  ),
                ),
              ],
            ),
          ),
        ),
        SectionTitle(tr.entryDrinkVolumeSection),
        _NumberField<int>(
          label: tr.entryServedVolume,
          suffix: 'ml',
          value: d.containerMl,
          parse: parseInteger,
          format: (v) => '$v',
          keyboardType: TextInputType.number,
          errorText: errors['volume'],
          helper: tr.entryServedVolumeHelper,
          onChanged: cubit.setVolume,
        ),
        if (estimate != null) ...[
          const SizedBox(height: AppSpace.md),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatTile(
                  label: tr.entryPureAlcohol,
                  value: estimate.isComplete
                      ? formatGrams(estimate.grams)
                      : tr.entryAtLeast(formatGrams(estimate.grams)),
                  icon: Icons.science_outlined,
                ),
                const SizedBox(height: AppSpace.sm),
                if (!estimate.isComplete)
                  InfoPill(
                    tr.entryMissingParts(estimate.missing.join(', ')),
                    icon: Icons.help_outline_rounded,
                    warning: true,
                  ),
                const SizedBox(height: AppSpace.sm),
                Text(tr.entryDeclaredNote, style: AppText.caption),
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
              label: Text(tr.entrySaveRecipeTitle),
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
            Text(tr.entryWhichProduct(component.name.toLowerCase()),
                style: AppText.title),
            const SizedBox(height: AppSpace.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined),
              title: Text(tr.entryNoBrand),
              onTap: () => Navigator.pop(ctx, const _ProductChoice(null)),
            ),
            for (final p in products)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(p.category.icon, color: AppColors.amber),
                title: Text(p.displayName),
                subtitle: Text(
                  p.abvPercent != null
                      ? tr.entryProductAbv(formatAbv(p.abvPercent!))
                      : (p.abvVariants.isNotEmpty
                          ? tr.entryProductAbvVaries
                          : tr.entryProductAbvUnknown),
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
                  c.optional ? tr.entryOptionalMark(c.name) : c.name,
                  style: AppText.subtitle,
                ),
              ),
              if (c.alcoholic)
                const Icon(Icons.local_bar_outlined,
                    size: 16, color: AppColors.amber),
              IconButton(
                tooltip: tr.entryRemoveIngredient,
                onPressed: () => cubit.removeComponent(index),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ]),
            if (c.amount == null && c.amountText != null)
              Text(tr.entryInRecipe(c.amountText!), style: AppText.caption),
            const SizedBox(height: AppSpace.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.unit != RecipeUnit.toTaste && c.unit != RecipeUnit.other)
                  Expanded(
                    child: _NumberField<double>(
                      label: tr.entryAmount,
                      suffix: c.unit.shortLabel,
                      numeric: true,
                      value: c.amount,
                      parse: parseDecimal,
                      format: decimalToInput,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      helper: c.amount == null
                          ? tr.entryAmountUnknown
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
                    c.productName ?? tr.entryChooseProduct,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (c.role != null) const SizedBox(height: AppSpace.sm),
              _NumberField<double>(
                label: tr.entryComponentAbv,
                suffix: '% vol.',
                numeric: true,
                value: c.abvPercent,
                parse: parseDecimal,
                format: decimalToInput,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                errorText: abvError,
                helper: c.abvPercent == null
                    ? tr.entryComponentAbvUnknown
                    : null,
                onChanged: (v) => cubit.setComponentAbv(index, v),
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                pure == null
                    ? tr.entryComponentAlcoholNone(
                        c.alcoholGap ?? tr.entryIncompleteData)
                    : tr.entryComponentAlcohol(formatGrams(pure * 0.789)),
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


/// The price written in the menu photo. A suggestion for this outing only:
/// what was actually paid may differ (promotion, a different order, a shared
/// bill), so it only applies when the user taps.
class _AdvertisedBanner extends StatelessWidget {
  const _AdvertisedBanner({required this.draft, required this.cents});

  final DrinkDraft draft;
  final int cents;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.entryMenuPrice, style: AppText.overline),
          const SizedBox(height: AppSpace.xs),
          Text(
            tr.entryMenuPriceBody(formatCents(cents)),
            style: AppText.body,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: cubit.applyAdvertised,
              child: Text(draft.isShared
                  ? tr.entryUseAsBillTotal
                  : tr.entryUseAsPaid),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Seu histórico": the user's own last price for this drink and size. It only
/// becomes the price when the user taps to confirm; a paid share and a package
/// total are never swapped.
class _SuggestionBanner extends StatelessWidget {
  const _SuggestionBanner({
    required this.draft,
    required this.suggestion,
    required this.scope,
  });

  final DrinkDraft draft;
  final PriceSuggestion suggestion;
  final String scope;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrinkFormCubit>();
    final paid = suggestion.paidCents;
    final total = suggestion.totalCents;
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.entryHistory, style: AppText.overline),
          const SizedBox(height: AppSpace.xs),
          if (paid != null) ...[
            Text(
              draft.isShared
                  ? tr.entryHistoryShare(formatCents(paid), scope,
                      formatDate(suggestion.paidAt!))
                  : tr.entryHistoryPaid(formatCents(paid), scope,
                      formatDate(suggestion.paidAt!)),
              style: AppText.body,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: cubit.applySuggestedPaid,
                child: Text(draft.isShared
                    ? tr.entryUseAsShare
                    : tr.entryUseValue),
              ),
            ),
          ],
          if (draft.isShared && total != null) ...[
            Text(
              tr.entryHistoryTotal(
                  formatCents(total), formatDate(suggestion.totalAt!)),
              style: AppText.body,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: cubit.applySuggestedTotal,
                child: Text(tr.entryUseAsTotal),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
