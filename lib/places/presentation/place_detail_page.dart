import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/domain/price_history.dart';
import '../../outings/presentation/outing_summary_page.dart';
import '../../core/navigation/outing_flow.dart';
import '../../outings/data/outing_repository.dart';
import '../domain/geo_point.dart';
import '../domain/place.dart';
import 'open_in_maps.dart';
import 'place_editor_page.dart';
import 'place_map.dart';
import 'places_cubit.dart';
import '../../l10n/l10n.dart';

/// One saved place: its visits, what was registered there, and the user's own
/// price history for it.
class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlaceDetailCubit>(param1: placeId),
      child: const _PlaceDetailView(),
    );
  }
}

class _PlaceDetailView extends StatelessWidget {
  const _PlaceDetailView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlaceDetailCubit>();
    return BlocBuilder<PlaceDetailCubit, PlaceDetailState>(
      builder: (context, state) {
        if (state.loading) return const Scaffold(body: LoadingView());
        final place = state.place;
        if (place == null) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(message: tr.placeNotFound),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(tr.placeScreenTitle),
            actions: [
              IconButton(
                tooltip: place.favorite ? tr.catalogUnfavorite : tr.catalogFavorite,
                onPressed: cubit.toggleFavorite,
                icon: Icon(
                  place.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: place.favorite ? AppColors.amber : AppColors.textMuted,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: tr.commonOptions,
                onSelected: (v) async {
                  if (v == 'edit') {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PlaceEditorPage(editing: place)));
                  } else if (v == 'archive') {
                    await cubit.setArchived(!place.isArchived);
                    if (context.mounted) {
                      showToast(context,
                          place.isArchived
                              ? tr.placeReactivated
                              : tr.placeArchivedToast);
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(tr.commonEdit)),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(
                        place.isArchived ? tr.placeReactivate : tr.placeArchive),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
            children: [
              SurfaceCard(
                highlight: true,
                padding: const EdgeInsets.all(AppSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(place.type.icon, color: AppColors.amber, size: 20),
                      const SizedBox(width: AppSpace.sm),
                      Text(place.type.label, style: AppText.caption),
                      if (place.isArchived) ...[
                        const SizedBox(width: AppSpace.sm),
                        InfoPill(tr.placeArchivedPill),
                      ],
                    ]),
                    const SizedBox(height: AppSpace.sm),
                    Text(place.displayName, style: AppText.headline),
                    if (place.providerSubtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.xs),
                        child: Text(place.providerSubtitle!,
                            style: AppText.caption),
                      ),
                    // Geoapify keeps the data free to store as long as the
                    // data-source credit stays visible where it is reused.
                    if (place.provider != null)
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpace.xs),
                        child: MapAttribution(compact: true),
                      ),
                    const SizedBox(height: AppSpace.lg),
                    Row(children: [
                      Expanded(
                        child: StatTile(
                            label: tr.placeStatOutings,
                            value: '${state.visits.length}'),
                      ),
                      Expanded(
                        child: StatTile(
                            label: tr.placeStatDrinks,
                            value: '${state.drinkCount}'),
                      ),
                      Expanded(
                        child: StatTile(
                          label: tr.placeStatSpent,
                          value: formatCents(state.informedCents),
                        ),
                      ),
                    ]),
                    if (state.visits.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        tr.placeLastVisit(
                            formatDate(state.visits.first.outing.startedAt)),
                        style: AppText.caption,
                      ),
                    ],
                    const SizedBox(height: AppSpace.md),
                    Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
                      if (!place.isArchived)
                        FilledButton.icon(
                          onPressed: () => _startHere(context, place),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(tr.placeStartHere),
                        ),
                      if (_hasMapTarget(place))
                        OutlinedButton.icon(
                          onPressed: () => _openMaps(context, place),
                          icon: const Icon(Icons.map_outlined),
                          label: Text(tr.placeOpenMap),
                        ),
                    ]),
                    if (state.unpricedCount > 0) ...[
                      const SizedBox(height: AppSpace.md),
                      InfoPill(
                        tr.summaryUnpricedPill(state.unpricedCount),
                        icon: Icons.sell_outlined,
                        warning: true,
                      ),
                    ],
                  ],
                ),
              ),
              _PlaceDetails(place: place),
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.sm),
                child: Text(tr.placeSpendNote, style: AppText.caption),
              ),
              SectionTitle(tr.placePriceHistory),
              if (state.priceStats.isEmpty)
                Text(tr.placePriceHistoryNone, style: AppText.caption)
              else ...[
                for (final g in state.priceStats) _PriceTile(stats: g),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Text(tr.placePriceHistoryNote, style: AppText.caption),
                ),
              ],
              SectionTitle(tr.placeVisits('${state.visits.length}')),
              if (state.visits.isEmpty)
                Text(tr.placeNoVisits, style: AppText.caption)
              else
                for (final v in state.visits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.sm),
                    child: SurfaceCard(
                      onTap: v.outing.isActive
                          ? null
                          : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  OutingSummaryPage(outingId: v.outing.id))),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${formatDate(v.outing.startedAt)} · '
                                '${formatTime(v.outing.startedAt)}'
                                '${v.outing.isActive ? ' · ${tr.placeVisitInProgress}' : ''}',
                                style: AppText.subtitle,
                              ),
                              Text(
                                '${tr.drinkCount(v.summary.entryCount)}'
                                ' · ${v.summary.pricedCount == 0 ? tr.placeNoValues : formatCents(v.summary.informedCents)}',
                                style: AppText.caption,
                              ),
                            ],
                          ),
                        ),
                        if (!v.outing.isActive)
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted),
                      ]),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({required this.stats});

  final PriceGroupStats stats;

  @override
  Widget build(BuildContext context) {
    final range = stats.minCents == stats.maxCents
        ? formatCents(stats.minCents)
        : tr.rangeTo(formatCents(stats.minCents), formatCents(stats.maxCents));
    final period = stats.firstAt.year == stats.lastAt.year &&
            stats.firstAt.month == stats.lastAt.month &&
            stats.firstAt.day == stats.lastAt.day
        ? formatDate(stats.lastAt)
        : tr.rangeTo(formatDate(stats.firstAt), formatDate(stats.lastAt));
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stats.label, style: AppText.subtitle),
            const SizedBox(height: AppSpace.xs),
            Text(
              stats.shared
                  ? tr.placePriceLastShared(
                      formatCents(stats.lastCents), formatDate(stats.lastAt))
                  : tr.placePriceLast(
                      formatCents(stats.lastCents), formatDate(stats.lastAt)),
              style: AppText.body,
            ),
            Text(
              tr.placePriceRangeLine(range, stats.count, period),
              style: AppText.caption,
            ),
          ],
        ),
      ),
    );
  }
}

bool _hasMapTarget(Place p) =>
    p.point != null || (p.address?.trim().isNotEmpty ?? false);

Future<void> _openMaps(BuildContext context, Place p) async {
  final ok = await openInMaps(
    point: p.point,
    address: p.address,
    city: p.city,
    state: p.state,
    label: p.providerName,
  );
  if (!ok && context.mounted) {
    showToast(context, tr.openMapsFailed);
  }
}

Future<void> _startHere(BuildContext context, Place p) async {
  if (getIt<OutingRepository>().active != null) {
    showToast(context, tr.placeAlreadyActive);
    return;
  }
  await OutingFlow.start(context, place: p);
}

/// Address, name from the map data, where the location came from, and the
/// map itself when there is a point. Names of fields are plain words.
class _PlaceDetails extends StatefulWidget {
  const _PlaceDetails({required this.place});

  final Place place;

  @override
  State<_PlaceDetails> createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<_PlaceDetails> {
  bool _tilesFailed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final rows = <(String, String)>[
      if (p.providerName != null) (tr.placeFieldMapName, p.providerName!),
      if (p.address != null) (tr.placeFieldAddress, p.address!),
      if (p.cityState != null) (tr.placeFieldCity, p.cityState!),
      (tr.placeFieldOrigin, switch (p.source) {
        LocationSource.search => tr.placeSourceSearch,
        LocationSource.currentLocation => tr.placeSourceLocation,
        LocationSource.adjusted => tr.placeSourceAdjusted,
        null => tr.placeSourceManual,
      }),
    ];
    final point = p.point;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(tr.placeDetailsTitle),
        if (point != null && PlaceMap.available && !_tilesFailed) ...[
          SizedBox(
            height: 200,
            child: PlaceMap(
              point: point,
              interactive: false,
              onTilesFailed: () {
                if (mounted) setState(() => _tilesFailed = true);
              },
            ),
          ),
          const SizedBox(height: AppSpace.md),
        ],
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppText.caption),
                      Text(value, style: AppText.body),
                    ],
                  ),
                ),
              if (point == null && p.address == null)
                Text(tr.placeNoPointNoAddress, style: AppText.caption),
            ],
          ),
        ),
      ],
    );
  }
}
