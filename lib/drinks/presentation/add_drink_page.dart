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
import '../../outing_drinks/presentation/outing_drink_review_page.dart';
import '../../outing_drinks/presentation/outing_drinks_section.dart';
import '../../scan/presentation/scan_label_page.dart';
import '../../scan/presentation/scan_menu_page.dart';
import 'catalog_cubit.dart';
import 'my_drinks_page.dart';
import 'custom_drink_page.dart';
import 'drink_detail_sheet.dart';
import 'drink_entry_page.dart';
import 'recipe_editor_page.dart';
import '../../l10n/l10n.dart';

/// The drink catalog. With an [outingId] it is the "add drink" step of that
/// outing (pops `true` once a drink was registered). Without one it is the
/// Catálogo tab: explore, search, filter, favourite and manage own drinks with
/// no running outing; registering from there starts (or reuses) an outing.
class AddDrinkPage extends StatelessWidget {
  const AddDrinkPage({
    super.key,
    this.outingId,
    this.consumerId,
    this.choosePerson = true,
  });

  final String? outingId;

  /// Who the drink is for (null = the owner), already decided by the caller;
  /// with [choosePerson] and no decision, the form asks.
  final String? consumerId;
  final bool choosePerson;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CatalogCubit>(),
      child: _AddDrinkView(
        outingId: outingId,
        consumerId: consumerId,
        choosePerson: choosePerson,
      ),
    );
  }
}

class _AddDrinkView extends StatelessWidget {
  const _AddDrinkView({
    required this.outingId,
    required this.consumerId,
    required this.choosePerson,
  });

  final String? outingId;
  final String? consumerId;
  final bool choosePerson;

  bool get _explore => outingId == null;

  /// One registration or reading flow at a time: a repeated tap while a form
  /// is opening must not stack a second form (and a second record).
  static bool _flowOpen = false;

  Future<void> _once(Future<void> Function() flow) async {
    if (_flowOpen) return;
    _flowOpen = true;
    try {
      await flow();
    } finally {
      _flowOpen = false;
    }
  }

  Future<void> _pick(BuildContext context, CatalogItem item) =>
      _once(() => _pickItem(context, item));

  Future<void> _pickItem(BuildContext context, CatalogItem item) async {
    var id = outingId ?? getIt<OutingRepository>().active?.id;
    if (id == null) {
      // Exploring with no outing: registering starts one when the person
      // decides to.
      id = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const StartOutingPage()),
      );
      if (id == null || !context.mounted) return;
    }
    await _register(context, id, item);
  }

  /// Opens the registration form for [item] in outing [id] and leaves the
  /// screen the same way for catalog items and outing-only items.
  Future<void> _register(
    BuildContext context,
    String id,
    CatalogItem item,
  ) async {
    final outcome = await Navigator.of(context).push<EntryOutcome>(
      MaterialPageRoute(
        builder: (_) => DrinkEntryPage.create(
          outingId: id,
          item: item,
          consumerId: consumerId,
          choose: choosePerson,
        ),
      ),
    );
    if (!context.mounted) return;
    if (_explore) {
      if (outcome == EntryOutcome.saved) await OutingFlow.open(context, id);
    } else if (outcome == EntryOutcome.saved) {
      Navigator.of(context).pop(true);
    }
  }

  /// The outing the new flows belong to: the one on screen, the running one,
  /// or one the person chooses to start. Null when they decline.
  Future<String?> _needOuting(BuildContext context) async {
    final existing = outingId ?? getIt<OutingRepository>().active?.id;
    if (existing != null) return existing;
    final start = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.catalogNeedOutingTitle),
        content: Text(tr.catalogNeedOutingBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.commonNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.startTitle),
          ),
        ],
      ),
    );
    if (start != true || !context.mounted) return null;
    return Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const StartOutingPage()));
  }

  Future<void> _afterReview(
    BuildContext context,
    String id,
    ReviewResult? result,
  ) async {
    if (result == null || !context.mounted) return;
    if (result.register) {
      await _register(context, id, result.drink.toCatalogItem());
    } else {
      showToast(context, tr.catalogSavedToOuting);
    }
  }

  Future<void> _scanLabel(BuildContext context) =>
      _once(() => _scanLabelFlow(context));

  Future<void> _scanLabelFlow(BuildContext context) async {
    final id = await _needOuting(context);
    if (id == null || !context.mounted) return;
    final result = await Navigator.of(context).push<ReviewResult>(
      MaterialPageRoute(builder: (_) => ScanLabelPage(outingId: id)),
    );
    if (!context.mounted) return;
    await _afterReview(context, id, result);
  }

  Future<void> _scanMenu(BuildContext context) =>
      _once(() => _scanMenuFlow(context));

  Future<void> _scanMenuFlow(BuildContext context) async {
    final id = await _needOuting(context);
    if (id == null || !context.mounted) return;
    final result = await Navigator.of(context).push<MenuResult>(
      MaterialPageRoute(builder: (_) => ScanMenuPage(outingId: id)),
    );
    if (result != null && context.mounted) {
      showToast(context, tr.catalogMenuSaved(result.saved));
    }
  }

  /// Manual sign-up inside an outing: the drink belongs to this outing only.
  Future<void> _manualInOuting(BuildContext context, String suggestedName) =>
      _once(() => _manualFlow(context, suggestedName));

  Future<void> _manualFlow(BuildContext context, String suggestedName) async {
    final id = outingId;
    if (id == null) return;
    final result = await Navigator.of(context).push<ReviewResult>(
      MaterialPageRoute(
        builder: (_) => OutingDrinkReviewPage(
          outingId: id,
          prefill: ReviewPrefill(
            name: suggestedName.isEmpty ? null : suggestedName,
          ),
        ),
      ),
    );
    if (!context.mounted) return;
    await _afterReview(context, id, result);
  }

  /// Creates (or edits) a personal drink; a new one goes straight to the
  /// registration form.
  Future<void> _custom(
    BuildContext context, {
    String suggestedName = '',
    CatalogItem? editing,
  }) async {
    if (!_explore && editing == null) {
      // Inside an outing a new drink belongs to that outing only.
      await _manualInOuting(context, suggestedName);
      return;
    }
    final item = await Navigator.of(context).push<CatalogItem>(
      MaterialPageRoute(
        builder: (_) =>
            CustomDrinkPage(initialName: suggestedName, editing: editing),
      ),
    );
    if (item == null || editing != null || !context.mounted) return;
    if (_explore) {
      showToast(context, tr.catalogDrinkSaved);
    } else {
      await _pick(context, item);
    }
  }

  Future<void> _details(BuildContext context, CatalogItem item) async {
    final cubit = context.read<CatalogCubit>();
    final action = await showDrinkDetail(context, item: item, catalog: cubit);
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
          showToast(context, tr.catalogRecipeSaved);
        }
      case DetailAction.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(tr.catalogDeleteTitle),
            content: Text(tr.catalogDeleteBody),
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
            title: Text(_explore ? tr.navCatalog : tr.addDrinkTitle),
            actions: _explore
                ? [
                    IconButton(
                      tooltip: tr.catalogMyDrinksTooltip,
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
                  AppSpace.gutter,
                  0,
                  AppSpace.sm,
                  AppSpace.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: cubit.setQuery,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: tr.catalogSearchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.xs),
                    Badge(
                      isLabelVisible: f.advancedCount > 0,
                      label: Text('${f.advancedCount}'),
                      child: IconButton(
                        tooltip: tr.catalogMoreFilters,
                        onPressed: () => _openFilters(context, cubit),
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.gutter,
                  ),
                  children: [
                    _chip(
                      tr.catalogAll,
                      f.category == null,
                      () => cubit.setCategory(null),
                    ),
                    for (final c in DrinkCategory.values)
                      _chip(
                        c.label,
                        f.category == c,
                        () => cubit.setCategory(f.category == c ? null : c),
                      ),
                  ],
                ),
              ),
              if (f.advancedCount > 0)
                _ActiveFilters(state: state, cubit: cubit),
              Expanded(child: _body(context, state, cubit)),
              BottomActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _scanLabel(context),
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: Text(tr.catalogScanLabel),
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _scanMenu(context),
                            icon: const Icon(Icons.menu_book_outlined),
                            label: Text(tr.catalogScanMenu),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.sm),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _custom(context, suggestedName: state.query.trim()),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        _explore ? tr.catalogCreate : tr.catalogCreateOuting,
                      ),
                    ),
                  ],
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
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const _FilterSheet()),
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
        title: tr.catalogEmptyTitle,
        message: !_explore
            ? tr.catalogEmptyOuting
            : (state.filters.isEmpty
                  ? tr.catalogEmptyNoFilter
                  : tr.catalogEmptyFilter),
        actionLabel: _explore ? tr.catalogCreate : tr.catalogCreateOuting,
        onAction: () => _custom(context, suggestedName: state.query.trim()),
      );
    }
    final showShortcuts = !state.isFiltering;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.gutter,
        0,
        AppSpace.gutter,
        AppSpace.xl,
      ),
      children: [
        if (!_explore && showShortcuts)
          OutingDrinksSection(
            outingId: outingId!,
            onRegister: (d) =>
                _once(() => _register(context, outingId!, d.toCatalogItem())),
          ),
        if (showShortcuts && state.recents.isNotEmpty) ...[
          SectionTitle(tr.catalogRecents),
          _Shortcuts(
            items: state.recents,
            onTap: (i) => _explore ? _details(context, i) : _pick(context, i),
          ),
        ],
        if (showShortcuts && state.favoriteItems.isNotEmpty) ...[
          SectionTitle(tr.catalogFavorites),
          _Shortcuts(
            items: state.favoriteItems,
            onTap: (i) => _explore ? _details(context, i) : _pick(context, i),
          ),
        ],
        SectionTitle(
          showShortcuts
              ? tr.catalogAllDrinks
              : tr.catalogResults(state.items.length),
        ),
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
          if (f.brand != null) _chip(f.brand!, () => cubit.setBrand(null)),
          if (f.styleGroup != null)
            _chip(styleLabel(f.styleGroup!), () => cubit.setStyleGroup(null)),
          if (f.kind != null) _chip(f.kind!.label, () => cubit.setKind(null)),
          if (f.nonAlcoholic)
            _chip(tr.categoryNonAlcoholic, () => cubit.setNonAlcoholic(false)),
          TextButton(
            onPressed: cubit.clearFilters,
            child: Text(tr.catalogClearFilters),
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
      deleteButtonTooltipMessage: tr.catalogRemoveFilter,
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
                        onSelected: (_) => onChanged(selected == o ? null : o),
                      ),
                  ],
                ),
              ],
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.xl,
                      0,
                      AppSpace.xl,
                      AppSpace.lg,
                    ),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tr.catalogFilters,
                              style: AppText.title,
                            ),
                          ),
                          TextButton(
                            onPressed: f.advancedCount == 0
                                ? null
                                : cubit.clearFilters,
                            child: Text(tr.catalogClearFilters),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(tr.catalogOnlyNoAlcohol),
                        value: f.nonAlcoholic,
                        activeThumbColor: AppColors.amber,
                        onChanged: cubit.setNonAlcoholic,
                      ),
                      group<String>(
                        tr.catalogStyle,
                        state.styleGroups,
                        f.styleGroup,
                        styleLabel,
                        cubit.setStyleGroup,
                      ),
                      group<PresentationKind>(
                        tr.catalogPresentation,
                        state.kinds,
                        f.kind,
                        (k) => k.label,
                        cubit.setKind,
                      ),
                      group<String>(
                        tr.catalogBrand,
                        state.brands,
                        f.brand,
                        (s) => s,
                        cubit.setBrand,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.xl,
                    AppSpace.sm,
                    AppSpace.xl,
                    AppSpace.sm,
                  ),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(tr.catalogSeeCount(state.items.length)),
                  ),
                ),
              ],
            ),
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
              child: Text(
                item.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
        AppSpace.md,
        AppSpace.sm,
        AppSpace.xs,
        AppSpace.sm,
      ),
      child: Row(
        children: [
          Icon(item.category.icon, color: AppColors.amber),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle,
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpace.xs),
                // Wrap: a long origin label plus the sizes count must break
                // to a second line instead of overflowing the card.
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OriginBadge(item.origin),
                    if (count > 1)
                      Text(
                        tr.catalogSizes('$count'),
                        style: AppText.caption.copyWith(fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: tr.catalogDetails,
            onPressed: onDetails,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textMuted,
            ),
          ),
          IconButton(
            tooltip: favorite ? tr.catalogUnfavorite : tr.catalogFavorite,
            onPressed: onFavorite,
            icon: Icon(
              favorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: favorite ? AppColors.amber : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
