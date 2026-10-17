import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../outings/domain/outing.dart';
import '../../places/presentation/places_page.dart';
import '../../stats/presentation/stats_page.dart';
import '../../outings/presentation/outing_summary_page.dart';
import 'history_cubit.dart';
import '../../l10n/l10n.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HistoryCubit>(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HistoryCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.navHistory),
        actions: [
          IconButton(
            tooltip: tr.statsTitle,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const StatsPage())),
            icon: const Icon(Icons.insights_outlined),
          ),
          IconButton(
            tooltip: tr.settingsSavedPlaces,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PlacesPage())),
            icon: const Icon(Icons.place_outlined),
          ),
          const SettingsAction(),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.total == 0) {
            return EmptyView(
              icon: Icons.history_rounded,
              title: tr.historyEmptyTitle,
              message: tr.historyEmptyBody,
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  0,
                  AppSpace.gutter,
                  AppSpace.sm,
                ),
                child: TextField(
                  onChanged: cubit.setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: tr.historySearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              _Filters(state: state, cubit: cubit),
              Expanded(
                child: state.items.isEmpty
                    ? EmptyView(
                        icon: Icons.filter_alt_off_outlined,
                        title: tr.historyNoMatchTitle,
                        message: tr.historyNoMatchBody,
                        actionLabel: tr.catalogClearFilters,
                        onAction: cubit.clearFilters,
                      )
                    : _List(items: state.items),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.state, required this.cubit});

  final HistoryState state;
  final HistoryCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            children: [
              for (final p in HistoryPeriod.values)
                _chip(p.label, state.period == p, () => cubit.setPeriod(p)),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
            children: [
              _chip(
                tr.historyAllTypes,
                state.type == null,
                () => cubit.setType(null),
              ),
              for (final t in OutingType.values)
                _chip(
                  t.label,
                  state.type == t,
                  () => cubit.setType(state.type == t ? null : t),
                ),
            ],
          ),
        ),
      ],
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
}

class _List extends StatelessWidget {
  const _List({required this.items});

  final List<HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    // Items arrive newest first; insert a header whenever the month changes.
    final rows = <Object>[];
    String? lastKey;
    for (final item in items) {
      final d = item.outing.startedAt;
      final key = '${d.year}-${d.month}';
      if (key != lastKey) {
        rows.add(d);
        lastKey = key;
      }
      rows.add(item);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.gutter,
        0,
        AppSpace.gutter,
        AppSpace.xxl,
      ),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is DateTime) return SectionTitle(formatMonthYear(row));
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.sm),
          child: _OutingCard(item: row as HistoryItem),
        );
      },
    );
  }
}

class _OutingCard extends StatelessWidget {
  const _OutingCard({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final o = item.outing;
    final s = item.summary;
    return SurfaceCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OutingSummaryPage(outingId: o.id)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(o.type.icon, color: AppColors.amber),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle,
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDate(o.startedAt)} · ${formatTime(o.startedAt)}',
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  '${tr.drinkCount(s.entryCount)}'
                  ' · ${s.volumeLabel}',
                  style: AppText.caption.copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                s.pricedCount == 0
                    ? tr.historyNoValues
                    : formatCents(s.informedCents),
                style: AppText.subtitle,
              ),
              if (s.unpricedCount > 0)
                Text(
                  tr.homeUnpriced(s.unpricedCount),
                  style: AppText.caption.copyWith(fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
