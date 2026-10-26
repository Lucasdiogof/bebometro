import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../domain/catalog_item.dart';
import 'custom_drink_page.dart';
import '../../table/presentation/order_page.dart';
import 'my_drinks_cubit.dart';
import 'recipe_editor_page.dart';
import '../../l10n/l10n.dart';

/// Manages the user's own drinks and recipes: list, register, edit,
/// duplicate and delete. Past records are never changed by any of these.
class MyDrinksPage extends StatelessWidget {
  const MyDrinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MyDrinksCubit>(),
      child: const _MyDrinksView(),
    );
  }
}

enum _Action { register, edit, duplicate, delete }

class _MyDrinksView extends StatelessWidget {
  const _MyDrinksView();

  Future<void> _run(
    BuildContext context,
    _Action action,
    CatalogItem item,
  ) async {
    final cubit = context.read<MyDrinksCubit>();
    switch (action) {
      case _Action.register:
        final outingId = cubit.state.activeOutingId;
        if (outingId == null) {
          showToast(context, tr.myDrinksNeedOuting);
          return;
        }
        final outcome = await OrderPage.open(
          context,
          outingId: outingId,
          item: item,
        );
        if (outcome != null && context.mounted) {
          showToast(context, tr.myDrinksLogged);
        }
      case _Action.edit:
        await Navigator.of(context).push<CatalogItem>(
          MaterialPageRoute(
            builder: (_) => item.isRecipe
                ? RecipeEditorPage(editing: item)
                : CustomDrinkPage(editing: item),
          ),
        );
      case _Action.duplicate:
        await cubit.duplicate(item);
        if (context.mounted) showToast(context, tr.myDrinksCopied);
      case _Action.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(tr.myDrinksDeleteTitle(item.name)),
            content: Text(tr.myDrinksDeleteBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  tr.commonDelete,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        );
        if (ok == true) {
          await cubit.delete(item);
          if (context.mounted) showToast(context, tr.myDrinksDeleted);
        }
    }
  }

  String _subtitle(CatalogItem item) {
    final recipe = item.recipe;
    if (recipe != null) {
      return tr.myDrinksRecipeSubtitle(recipe.components.length);
    }
    final parts = <String>[
      item.category.label,
      if (item.presentations.isNotEmpty)
        formatMl(item.presentations.first.volumeMl),
      if (item.abvPercent != null) formatAbv(item.abvPercent!),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr.myDrinksTitle)),
      body: BlocBuilder<MyDrinksCubit, MyDrinksState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.items.isEmpty
                    ? EmptyView(
                        icon: Icons.bookmark_border_rounded,
                        title: tr.myDrinksEmptyTitle,
                        message: tr.myDrinksEmptyBody,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpace.gutter,
                          0,
                          AppSpace.gutter,
                          AppSpace.xl,
                        ),
                        children: [
                          if (state.activeOutingId == null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpace.md,
                              ),
                              child: Text(
                                tr.myDrinksStartFirst,
                                style: AppText.caption,
                              ),
                            ),
                          for (final item in state.items)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpace.sm,
                              ),
                              child: SurfaceCard(
                                onTap: state.activeOutingId == null
                                    ? () => _run(context, _Action.edit, item)
                                    : () =>
                                          _run(context, _Action.register, item),
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpace.md,
                                  AppSpace.sm,
                                  AppSpace.xs,
                                  AppSpace.sm,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.isRecipe
                                          ? Icons.receipt_long_outlined
                                          : item.category.icon,
                                      color: AppColors.amber,
                                    ),
                                    const SizedBox(width: AppSpace.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.displayName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppText.subtitle,
                                          ),
                                          Text(
                                            _subtitle(item),
                                            style: AppText.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<_Action>(
                                      tooltip: tr.commonOptions,
                                      icon: const Icon(
                                        Icons.more_vert_rounded,
                                        color: AppColors.textMuted,
                                      ),
                                      onSelected: (a) => _run(context, a, item),
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: _Action.register,
                                          child: Text(tr.myDrinksActionLog),
                                        ),
                                        PopupMenuItem(
                                          value: _Action.edit,
                                          child: Text(tr.commonEdit),
                                        ),
                                        PopupMenuItem(
                                          value: _Action.duplicate,
                                          child: Text(
                                            tr.myDrinksActionDuplicate,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: _Action.delete,
                                          child: Text(tr.commonDelete),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              BottomActionBar(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CustomDrinkPage(),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(tr.myDrinksNewDrink),
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RecipeEditorPage(),
                          ),
                        ),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(tr.myDrinksNewRecipe),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
