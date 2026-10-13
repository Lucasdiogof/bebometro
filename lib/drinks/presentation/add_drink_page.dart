import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/navigation/outing_flow.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/presentation/start_outing_page.dart';
import 'catalog_cubit.dart';
import 'my_drinks_page.dart';
import 'custom_drink_page.dart';
import 'drink_detail_sheet.dart';
import 'drink_entry_page.dart';
import 'recipe_editor_page.dart';

/// The drink catalog. With an [outingId] it is the "add drink" step of that
/// outing (pops `true` once a drink was registered). Without one it is the
/// Catálogo tab: explore, search, filter, favourite and manage own drinks with
/// no running outing; registering from there starts (or reuses) an outing.
class AddDrinkPage extends StatelessWidget {
  const AddDrinkPage({super.key, this.outingId});

  final String? outingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CatalogCubit>(),
      child: _AddDrinkView(outingId: outingId),
    );
  }
}

class _AddDrinkView extends StatelessWidget {
  const _AddDrinkView({required this.outingId});

  final String? outingId;

  bool get _explore => outingId == null;

  Future<void> _pick(BuildContext context, CatalogItem item) async {
    var id = outingId ?? getIt<OutingRepository>().active?.id;
    if (id == null) {
      // Exploring with no outing: registering starts one when the person
      // decides to.
      id = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const StartOutingPage()),
      );
      if (id == null || !context.mounted) return;
    }
    final outcome = await Navigator.of(context).push<EntryOutcome>(
      MaterialPageRoute(
        builder: (_) => DrinkEntryPage.create(outingId: id!, item: item),
      ),
    );
    if (!context.mounted) return;
    if (_explore) {
      if (outcome == EntryOutcome.saved) await OutingFlow.open(context, id);
    } else if (outcome == EntryOutcome.saved) {
      Navigator.of(context).pop(true);
    }
  }

  /// Creates (or edits) a personal drink; a new one goes straight to the
  /// registration form.
  Future<void> _custom(
    BuildContext context, {
    String suggestedName = '',
    CatalogItem? editing,
  }) async {
    final item = await Navigator.of(context).push<CatalogItem>(
      MaterialPageRoute(
        builder: (_) =>
            CustomDrinkPage(initialName: suggestedName, editing: editing),
      ),
    );
    if (item == null || editing != null || !context.mounted) return;
    if (_explore) {
      showToast(context, 'Bebida salva em Minhas bebidas');
    } else {
      await _pick(context, item);
    }
  }

  Future<void> _details(BuildContext context, CatalogItem item) async {
    final cubit = context.read<CatalogCubit>();
    final action =
        await showDrinkDetail(context, item: item, catalog: cubit);
    if (!context.mounted) return;
    switch (action) {
      case DetailAction.register:
        await _pick(context, item);
      case DetailAction.edit:
        await _custom(context, editing: item);
      case DetailAction.copyRecipe:
        final saved = await Navigator.of(context).push<CatalogItem>(
          MaterialPageRoute(builder: (_) => RecipeEditorPage(copyFrom: item)),
        );
        if (saved != null && context.mounted) {
          showToast(context, 'Receita salva em Minhas bebidas');
        }
      case DetailAction.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir esta bebida?'),
            content: const Text(
              'Ela sai do catálogo. Os registros que você já fez com ela '
              'continuam como estão.',
            ),
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
        if (ok == true) await cubit.deleteCustom(item.id);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        final f = state.filters;
        return Scaffold(
          appBar: AppBar(
            title: Text(_explore ? 'Catálogo' : 'Adicionar bebida'),
            actions: _explore
                ? [
                    IconButton(
                      tooltip: 'Minhas bebidas e receitas',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyDrinksPage()),
                      ),
                      icon: const Icon(Icons.bookmark_border_rounded),
                    ),
                    const SettingsAction(),
                  ]
                : null,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter, 0, AppSpace.sm, AppSpace.sm),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      onChanged: cubit.setQuery,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Buscar marca, produto ou estilo',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.xs),
                  Badge(
                    isLabelVisible: f.advancedCount > 0,
                    label: Text('${f.advancedCount}'),
                    child: IconButton(
                      tooltip: 'Mais filtros',
                      onPressed: () => _openFilters(context, cubit),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                  children: [
                    _chip('Todas', f.category == null,
                        () => cubit.setCategory(null)),
                    for (final c in DrinkCategory.values)
                      _chip(
                        c.label,
                        f.category == c,
                        () => cubit.setCategory(f.category == c ? null : c),
                      ),
                  ],
                ),
              ),
              if (f.advancedCount > 0) _ActiveFilters(state: state, cubit: cubit),
              Expanded(child: _body(context, state, cubit)),
              BottomActionBar(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _custom(context, suggestedName: state.query.trim()),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Cadastrar bebida'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openFilters(BuildContext context, CatalogCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _FilterSheet(),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: AppSpace.sm, top: 4, bottom: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => onTap(),
        ),
      );

  Widget _body(BuildContext context, CatalogState state, CatalogCubit cubit) {
    if (state.items.isEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: 'Nenhuma bebida encontrada',
        message: state.filters.isEmpty
            ? 'Cadastre a sua e ela fica salva para os próximos rolês.'
            : 'Tente tirar algum filtro ou cadastre a sua.',
        actionLabel: 'Cadastrar bebida',
        onAction: () => _custom(context, suggestedName: state.query.trim()),
      );
    }
    final showShortcuts = !state.isFiltering;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
      children: [
        if (showShortcuts && state.recents.isNotEmpty) ...[
          const SectionTitle('Recentes'),
          _Shortcuts(
              items: state.recents,
              onTap: (i) => _explore ? _details(context, i) : _pick(context, i)),
        ],
        if (showShortcuts && state.favoriteItems.isNotEmpty) ...[
          const SectionTitle('Favoritas'),
          _Shortcuts(
              items: state.favoriteItems,
              onTap: (i) => _explore ? _details(context, i) : _pick(context, i)),
        ],
        SectionTitle(
            showShortcuts ? 'Todas as bebidas' : '${state.items.length} resultados'),
        for (final item in state.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: _ItemTile(
              item: item,
              favorite: state.favorites.contains(item.id),
              onTap: () =>
                  _explore ? _details(context, item) : _pick(context, item),
              onDetails: () => _details(context, item),
              onFavorite: () => cubit.toggleFavorite(item.id),
            ),
          ),
      ],
    );
  }
}

/// Removable chips for the filters that are not in the category row, plus
/// "Limpar filtros".
class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.state, required this.cubit});

  final CatalogState state;
  final CatalogCubit cubit;

  @override
  Widget build(BuildContext context) {
    final f = state.filters;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
        children: [
          if (f.brand != null)
            _chip(f.brand!, () => cubit.setBrand(null)),
          if (f.styleGroup != null)
            _chip(f.styleGroup!, () => cubit.setStyleGroup(null)),
          if (f.kind != null)
            _chip(f.kind!.label, () => cubit.setKind(null)),
          if (f.nonAlcoholic)
            _chip('Sem álcool', () => cubit.setNonAlcoholic(false)),
          TextButton(
            onPressed: cubit.clearFilters,
            child: const Text('Limpar filtros'),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onRemove) => Padding(
        padding: const EdgeInsets.only(right: AppSpace.sm, top: 4, bottom: 4),
        child: InputChip(
          label: Text(label),
          onDeleted: onRemove,
          deleteIcon: const Icon(Icons.close_rounded, size: 16),
          deleteButtonTooltipMessage: 'Remover filtro',
        ),
      );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          final f = state.filters;
          Widget group<T>(
            String title,
            List<T> options,
            T? selected,
            String Function(T) label,
            ValueChanged<T?> onChanged,
          ) {
            if (options.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: [
                    for (final o in options)
                      ChoiceChip(
                        label: Text(label(o)),
                        selected: selected == o,
                        showCheckmark: false,
                        onSelected: (_) =>
                            onChanged(selected == o ? null : o),
                      ),
                  ],
                ),
              ],
            );
          }

          return SafeArea(
            child: Column(children: [
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
                  children: [
                    Row(children: [
                      const Expanded(
                          child: Text('Filtros', style: AppText.title)),
                      TextButton(
                        onPressed: f.advancedCount == 0
                            ? null
                            : cubit.clearFilters,
                        child: const Text('Limpar filtros'),
                      ),
                    ]),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Só sem álcool'),
                      value: f.nonAlcoholic,
                      activeThumbColor: AppColors.amber,
                      onChanged: cubit.setNonAlcoholic,
                    ),
                    group<String>('Estilo', state.styleGroups, f.styleGroup,
                        (s) => s, cubit.setStyleGroup),
                    group<PresentationKind>('Apresentação', state.kinds,
                        f.kind, (k) => k.label, cubit.setKind),
                    group<String>('Marca', state.brands, f.brand, (s) => s,
                        cubit.setBrand),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.xl, AppSpace.sm, AppSpace.xl, AppSpace.sm),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Ver ${state.items.length} bebidas'),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts({required this.items, required this.onTap});

  final List<CatalogItem> items;
  final ValueChanged<CatalogItem> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpace.sm),
        itemBuilder: (context, i) {
          final item = items[i];
          return ActionChip(
            avatar: Icon(item.category.icon, size: 18, color: AppColors.amber),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(item.displayName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            onPressed: () => onTap(item),
          );
        },
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.favorite,
    required this.onTap,
    required this.onDetails,
    required this.onFavorite,
  });

  final CatalogItem item;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onDetails;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final count = item.documentedPresentations.length;
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
          AppSpace.md, AppSpace.sm, AppSpace.xs, AppSpace.sm),
      child: Row(children: [
        Icon(item.category.icon, color: AppColors.amber),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpace.xs),
              Row(children: [
                OriginBadge(item.origin),
                if (count > 1) ...[
                  const SizedBox(width: AppSpace.sm),
                  Text('$count tamanhos',
                      style: AppText.caption.copyWith(fontSize: 12)),
                ],
              ]),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Detalhes',
          onPressed: onDetails,
          icon: const Icon(Icons.info_outline_rounded,
              color: AppColors.textMuted),
        ),
        IconButton(
          tooltip: favorite ? 'Remover dos favoritos' : 'Favoritar',
          onPressed: onFavorite,
          icon: Icon(
            favorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: favorite ? AppColors.amber : AppColors.textMuted,
          ),
        ),
      ]),
    );
  }
}
