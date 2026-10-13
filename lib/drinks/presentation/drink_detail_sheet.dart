import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import 'catalog_cubit.dart';
import '../../l10n/l10n.dart';

/// What the user chose in the detail sheet.
enum DetailAction { register, edit, delete, copyRecipe }

/// Small tag telling where a drink's data comes from. It never claims
/// certification or safety.
class OriginBadge extends StatelessWidget {
  const OriginBadge(this.origin, {super.key});

  final InfoOrigin origin;

  @override
  Widget build(BuildContext context) {
    final icon = switch (origin) {
      InfoOrigin.verified => Icons.menu_book_outlined,
      InfoOrigin.mixed => Icons.menu_book_outlined,
      InfoOrigin.secondary => Icons.label_outline_rounded,
      InfoOrigin.recipe => Icons.receipt_long_outlined,
      InfoOrigin.generic => Icons.layers_outlined,
      InfoOrigin.user => Icons.person_outline_rounded,
    };
    return InfoPill(origin.label, icon: icon, warning: origin == InfoOrigin.generic);
  }
}

/// Shows a product's data (nothing here is edited) and lets the user favourite
/// it or go register it. Pops a [DetailAction] or null.
Future<DetailAction?> showDrinkDetail(
  BuildContext context, {
  required CatalogItem item,
  required CatalogCubit catalog,
}) {
  return showModalBottomSheet<DetailAction>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: catalog,
      child: _DrinkDetailSheet(item: item),
    ),
  );
}

class _DrinkDetailSheet extends StatelessWidget {
  const _DrinkDetailSheet({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CatalogCubit>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
                children: [
                  Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(item.category.icon,
                          color: AppColors.amber, size: 28),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.displayName, style: AppText.title),
                          Text(
                            [
                              if (item.brand != null) item.brand!,
                              item.category.label,
                            ].join(' · '),
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<CatalogCubit, CatalogState>(
                      builder: (context, state) {
                        final fav = state.favorites.contains(item.id);
                        return IconButton(
                          tooltip: fav ? tr.catalogUnfavorite : tr.catalogFavorite,
                          onPressed: () => catalog.toggleFavorite(item.id),
                          icon: Icon(
                            fav
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: fav ? AppColors.amber : AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: AppSpace.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OriginBadge(item.origin),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  if (item.isRecipe)
                    _RecipeBlock(item: item)
                  else ...[
                    _Row(tr.catalogStyle, item.displayStyle ?? tr.detailNotGiven),
                    _Row(tr.detailAbv, _abvText(item)),
                    if (item.abvSource != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Text(
                          tr.detailAbvFrom(item.abvSource!.displayLabel),
                          style: AppText.caption,
                        ),
                      ),
                    _Row(
                      tr.detailIngredients,
                      item.ingredients == null
                          ? tr.detailIngredientsNone
                          : item.ingredients!.join(', '),
                    ),
                    SectionTitle(tr.detailPresentations),
                    if (item.category == DrinkCategory.spirit)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Text(tr.detailBottleNotDose,
                            style: AppText.caption),
                      ),
                    if (item.documentedPresentations.isEmpty)
                      Text(tr.detailUnverifiedPackages, style: AppText.caption)
                    else ...[
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.sm,
                        children: [
                          for (final p in item.documentedPresentations)
                            Chip(label: Text(p.displayLabel)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.sm),
                        child: Text(tr.detailPackagesNote,
                            style: AppText.caption),
                      ),
                    ],
                  ],
                  if (item.note != null) ...[
                    const SizedBox(height: AppSpace.md),
                    Text(item.note!, style: AppText.caption),
                  ],
                  if (item.source != null) ...[
                    const SizedBox(height: AppSpace.md),
                    _SourceTile(source: item.source!),
                  ],
                  if (item.isRecipe)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, DetailAction.copyRecipe),
                        icon: const Icon(Icons.copy_all_outlined, size: 18),
                        label: Text(tr.detailMakeMine),
                      ),
                    ),
                  if (item.isCustom) ...[
                    const SizedBox(height: AppSpace.md),
                    Row(children: [
                      if (!item.isRecipe)
                        TextButton.icon(
                          onPressed: () =>
                              Navigator.pop(context, DetailAction.edit),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(tr.commonEdit),
                        ),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, DetailAction.delete),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.danger),
                        label: Text(tr.commonDelete,
                            style: const TextStyle(color: AppColors.danger)),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl, AppSpace.sm, AppSpace.xl, AppSpace.sm),
              child: FilledButton(
                onPressed: () => Navigator.pop(context, DetailAction.register),
                child: Text(tr.entryLogDrink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 2),
          Text(value, style: AppText.body),
        ],
      ),
    );
  }
}

/// Discreet "where does this come from" line, expandable to the address.
class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source});

  final SourceRef source;

  String? get _date {
    final raw = source.consultedOn;
    final d = raw == null ? null : DateTime.tryParse(raw);
    return d == null ? null : formatDate(d);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          tr.detailSourceTitle,
          style: AppText.caption.copyWith(color: AppColors.amber),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _date == null
                  ? source.displayLabel
                  : tr.detailSourceLine(source.displayLabel, _date!),
              style: AppText.caption,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Row(children: [
            Expanded(
              child: SelectableText(
                source.url,
                style: AppText.caption.copyWith(fontSize: 12),
              ),
            ),
            IconButton(
              tooltip: tr.detailCopyAddress,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: source.url));
                if (context.mounted) showToast(context, tr.detailAddressCopied);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
            ),
          ]),
          Text(tr.detailMayVary, style: AppText.caption),
        ],
      ),
    );
  }
}


String _abvText(CatalogItem item) {
  if (item.abvPercent != null) return formatAbv(item.abvPercent!);
  if (item.abvVariants.isNotEmpty) {
    final lines = item.abvVariants
        .map((v) => '${formatAbv(v.value)} (${v.displayScope})')
        .join('\n');
    return tr.detailAbvVaries(lines);
  }
  return tr.detailNotGiven;
}

/// A reference or personal recipe: components with their amounts, and what the
/// recipe is (and is not).
class _RecipeBlock extends StatelessWidget {
  const _RecipeBlock({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final recipe = item.recipe!;
    final isReference = item.origin == InfoOrigin.recipe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isReference ? tr.detailRecipeReference : tr.detailRecipeMine,
          style: AppText.caption,
        ),
        SectionTitle(tr.entryCompositionTitle),
        if (recipe.components.isEmpty)
          Text(tr.detailNoIngredientsYet, style: AppText.caption)
        else
          for (final c in recipe.components)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Expanded(
                  child: Text(
                    c.optional ? tr.entryOptionalMark(c.name) : c.name,
                    style: AppText.body,
                  ),
                ),
                Text(c.amountLabel, style: AppText.caption),
                if (c.alcoholic)
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpace.sm),
                    child: Icon(Icons.local_bar_outlined,
                        size: 14, color: AppColors.amber),
                  ),
              ]),
            ),
        const SizedBox(height: AppSpace.sm),
        Text(tr.detailAlcoholLegend, style: AppText.caption),
        if (recipe.method != null) ...[
          SectionTitle(tr.detailMethod),
          Text(recipe.method!, style: AppText.body),
        ],
        if (recipe.garnish != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text(tr.detailGarnish(recipe.garnish!), style: AppText.caption),
        ],
      ],
    );
  }
}
