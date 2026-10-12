import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
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
    final outcome = await Navigator.of(context).push<EntryOutcome>(
      MaterialPageRoute(
        builder: (_) => DrinkEntryPage.create(outingId: outingId, item: item),
      ),
    );
    if (outcome == EntryOutcome.saved && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// Creates a personal drink and goes straight to registering it.
  Future<void> _createCustom(BuildContext context, String suggestedName) async {
    final item = await Navigator.of(context).push<CatalogItem>(
      MaterialPageRoute(
        builder: (_) => CustomDrinkPage(initialName: suggestedName),
      ),
    );
    if (item != null && context.mounted) await _pick(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Adicionar bebida')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter, 0, AppSpace.gutter, AppSpace.sm),
                child: TextField(
                  onChanged: cubit.setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nome, marca ou estilo',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                  children: [
                    _chip('Todas', state.category == null,
                        () => cubit.setCategory(null)),
                    for (final c in DrinkCategory.values)
                      _chip(
                        c.label,
                        state.category == c,
                        () => cubit.setCategory(
                            state.category == c ? null : c),
                      ),
                  ],
                ),
              ),
              Expanded(child: _body(context, state, cubit)),
              BottomActionBar(
                child: OutlinedButton.icon(
                  onPressed: () => _createCustom(context, state.query.trim()),
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
        message: 'Cadastre a sua e ela fica salva para os próximos rolês.',
        actionLabel: 'Cadastrar bebida',
        onAction: () => _createCustom(context, state.query.trim()),
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
            onTap: (i) => _pick(context, i),
          ),
        ],
        if (showShortcuts && state.favoriteItems.isNotEmpty) ...[
          const SectionTitle('Favoritas'),
          _Shortcuts(
            items: state.favoriteItems,
            onTap: (i) => _pick(context, i),
          ),
        ],
        SectionTitle(showShortcuts ? 'Todas as bebidas' : 'Resultados'),
        for (final item in state.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: _ItemTile(
              item: item,
              favorite: state.favorites.contains(item.id),
              onTap: () => _pick(context, item),
              onFavorite: () => cubit.toggleFavorite(item.id),
            ),
          ),
      ],
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
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(item.name,
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
    required this.onFavorite,
  });

  final CatalogItem item;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final sizes =
        item.presentations.map((p) => formatMl(p.volumeMl)).toSet().join(' · ');
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
              Text(item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption,
              ),
              Text(
                sizes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(fontSize: 12),
              ),
              if (item.origin != InfoOrigin.verified)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.xs),
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
    );
  }
}
