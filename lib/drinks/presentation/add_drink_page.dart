import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/state_views.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import 'catalog_cubit.dart';
import 'custom_drink_page.dart';
import 'drink_entry_page.dart';

/// Pops `true` once a drink was registered.
class AddDrinkPage extends StatelessWidget {
  const AddDrinkPage({super.key, required this.outingId});

  final String outingId;

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

  final String outingId;

  Future<void> _pick(BuildContext context, CatalogItem item) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DrinkEntryPage.create(outingId: outingId, item: item),
      ),
    );
    if (saved == true && context.mounted) Navigator.of(context).pop(true);
  }

  Future<void> _createCustom(BuildContext context) async {
    final item = await Navigator.of(context).push<CatalogItem>(
      MaterialPageRoute(builder: (_) => const CustomDrinkPage()),
    );
    if (item != null && context.mounted) await _pick(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar bebida')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCustom(context),
        backgroundColor: AppColors.amber,
        foregroundColor: const Color(0xFF241800),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Bebida própria'),
      ),
      body: SafeArea(
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    onChanged: cubit.setQuery,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome, marca ou estilo',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _filterChip(
                        'Todas',
                        state.filter == CatalogFilter.all,
                        () => cubit.setFilter(CatalogFilter.all),
                      ),
                      _filterChip(
                        'Favoritas',
                        state.filter == CatalogFilter.favorites,
                        () => cubit.setFilter(CatalogFilter.favorites),
                        icon: Icons.star_rounded,
                      ),
                      _filterChip(
                        'Recentes',
                        state.filter == CatalogFilter.recents,
                        () => cubit.setFilter(CatalogFilter.recents),
                        icon: Icons.history_rounded,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _filterChip(
                        'Todos os tipos',
                        state.category == null,
                        () => cubit.setCategory(null),
                      ),
                      for (final c in DrinkCategory.values)
                        _filterChip(
                          c.label,
                          state.category == c,
                          () => cubit.setCategory(
                            state.category == c ? null : c,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.items.isEmpty
                      ? _emptyFor(context, state)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final item = state.items[i];
                            return _ItemTile(
                              item: item,
                              favorite: state.favorites.contains(item.id),
                              onTap: () => _pick(context, item),
                              onFavorite: () => cubit.toggleFavorite(item.id),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap,
      {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      child: ChoiceChip(
        avatar: icon == null
            ? null
            : Icon(icon,
                size: 16,
                color: selected ? const Color(0xFF241800) : AppColors.amber),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _emptyFor(BuildContext context, CatalogState state) {
    if (state.filter == CatalogFilter.favorites && state.query.isEmpty) {
      return const EmptyView(
        icon: Icons.star_outline_rounded,
        title: 'Sem favoritas ainda',
        message: 'Toque na estrela de uma bebida para fixá-la aqui.',
      );
    }
    if (state.filter == CatalogFilter.recents && state.query.isEmpty) {
      return const EmptyView(
        icon: Icons.history_rounded,
        title: 'Nada recente',
        message: 'As bebidas que você registrar aparecem aqui.',
      );
    }
    return EmptyView(
      icon: Icons.search_off_rounded,
      title: 'Nenhuma bebida encontrada',
      message: 'Cadastre uma bebida própria e reutilize quando quiser.',
      actionLabel: 'Criar bebida própria',
      onAction: () => _createCustom(context),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
  });

  final CatalogItem item;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final sizes = item.presentations.map((p) => formatMl(p.volumeMl)).join(' · ');
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.category.icon, color: AppColors.amber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      item.subtitle,
                      if (item.abvPercent != null) formatAbv(item.abvPercent!),
                    ].join(' · '),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sizes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                  if (item.origin != InfoOrigin.verified)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.origin.label,
                        style: TextStyle(
                          color: AppColors.amber.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
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
        ),
      ),
    );
  }
}
