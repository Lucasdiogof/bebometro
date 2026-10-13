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
                          tooltip: fav ? 'Remover dos favoritos' : 'Favoritar',
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
                    _Row('Estilo', item.style ?? 'Não informado'),
                    _Row('Teor alcoólico', _abvText(item)),
                    if (item.abvSource != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Text(
                          'Teor: ${item.abvSource!.label}. Não é dado do '
                          'fabricante.',
                          style: AppText.caption,
                        ),
                      ),
                    _Row(
                      'Ingredientes declarados',
                      item.ingredients == null
                          ? 'Não informados'
                          : item.ingredients!.join(', '),
                    ),
                    const SectionTitle('Apresentações'),
                    if (item.category == DrinkCategory.spirit)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpace.sm),
                        child: Text(
                          'Tamanho da garrafa não é tamanho da dose. Ao '
                          'registrar, você escolhe uma dose sugerida (editável) '
                          'ou compartilha a garrafa.',
                          style: AppText.caption,
                        ),
                      ),
                    if (item.documentedPresentations.isEmpty)
                      const Text(
                        'Embalagens não verificadas para este produto. Ao '
                        'registrar, você pode escolher um tamanho sugerido ou '
                        'digitar o volume.',
                        style: AppText.caption,
                      )
                    else ...[
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.sm,
                        children: [
                          for (final p in item.documentedPresentations)
                            Chip(label: Text(p.label)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpace.sm),
                        child: Text(
                          'Embalagens citadas pelo fabricante. O tamanho da '
                          'embalagem não é o que você bebeu: isso você define '
                          'ao registrar.',
                          style: AppText.caption,
                        ),
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
                        label: const Text('Criar minha versão'),
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
                          label: const Text('Editar'),
                        ),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, DetailAction.delete),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.danger),
                        label: const Text('Excluir',
                            style: TextStyle(color: AppColors.danger)),
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
                child: const Text('Registrar bebida'),
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
          'Fonte dos dados',
          style: AppText.caption.copyWith(color: AppColors.amber),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${source.label}${_date == null ? '' : ' · consultado em $_date'}',
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
              tooltip: 'Copiar endereço',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: source.url));
                if (context.mounted) showToast(context, 'Endereço copiado');
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
            ),
          ]),
          const Text(
            'Os dados podem variar por versão e mercado. Confira sempre o '
            'rótulo da embalagem.',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}


String _abvText(CatalogItem item) {
  if (item.abvPercent != null) return formatAbv(item.abvPercent!);
  if (item.abvVariants.isNotEmpty) {
    final lines = item.abvVariants
        .map((v) => '${formatAbv(v.value)} (${v.scope})')
        .join('\n');
    return 'Varia conforme a fonte, sem um valor único:\n$lines';
  }
  return 'Não informado';
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
          isReference
              ? 'Receita de referência: mostra como a receita é publicada, '
                  'não o que um bar serviu.'
              : 'Sua receita salva. Ao registrar, você ajusta o que '
                  'realmente foi servido.',
          style: AppText.caption,
        ),
        const SectionTitle('Composição'),
        if (recipe.components.isEmpty)
          const Text('Sem ingredientes ainda: você monta ao registrar.',
              style: AppText.caption)
        else
          for (final c in recipe.components)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Expanded(
                  child: Text(
                    c.name + (c.optional ? ' (opcional)' : ''),
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
        const Text(
          'Ingredientes com copo ao lado têm álcool. O teor de cada um é '
          'informado ao registrar; sem ele o álcool total fica incompleto. '
          'Gelo não entra na conta.',
          style: AppText.caption,
        ),
        if (recipe.method != null) ...[
          const SectionTitle('Preparo'),
          Text(recipe.method!, style: AppText.body),
        ],
        if (recipe.garnish != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text('Decoração: ${recipe.garnish}', style: AppText.caption),
        ],
      ],
    );
  }
}
