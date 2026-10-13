import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import 'place_detail_page.dart';
import 'place_editor_page.dart';
import 'places_cubit.dart';
import '../../l10n/l10n.dart';

/// The user's saved places (private). Archived ones are kept out of the way.
class PlacesPage extends StatelessWidget {
  const PlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlacesCubit>(),
      child: const _PlacesView(),
    );
  }
}

class _PlacesView extends StatelessWidget {
  const _PlacesView();

  Widget _tile(BuildContext context, PlaceRow row, PlacesCubit cubit) {
    final p = row.place;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: SurfaceCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PlaceDetailPage(placeId: p.id)),
        ),
        padding: const EdgeInsets.fromLTRB(
            AppSpace.md, AppSpace.sm, AppSpace.xs, AppSpace.sm),
        child: Row(children: [
          Icon(p.type.icon, color: AppColors.amber),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subtitle),
                if (p.providerSubtitle != null)
                  Text(p.providerSubtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption),
                Text(
                  [
                    if (p.cityState != null) p.cityState!,
                    tr.placesVisits(row.visits),
                  ].join(' · '),
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: p.favorite ? tr.catalogUnfavorite : tr.catalogFavorite,
            onPressed: () => cubit.toggleFavorite(p),
            icon: Icon(
              p.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: p.favorite ? AppColors.amber : AppColors.textMuted,
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr.settingsSavedPlaces)),
      body: BlocBuilder<PlacesCubit, PlacesState>(
        builder: (context, state) {
          final cubit = context.read<PlacesCubit>();
          return Column(
            children: [
              Expanded(
                child: state.active.isEmpty && state.archived.isEmpty
                    ? EmptyView(
                        icon: Icons.place_outlined,
                        title: tr.placesEmptyTitle,
                        message: tr.placesEmptyBody,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0,
                            AppSpace.gutter, AppSpace.xl),
                        children: [
                          for (final r in state.active) _tile(context, r, cubit),
                          if (state.archived.isNotEmpty) ...[
                            SectionTitle(tr.placesArchivedSection),
                            for (final r in state.archived)
                              _tile(context, r, cubit),
                          ],
                        ],
                      ),
              ),
              BottomActionBar(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlaceEditorPage()),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(tr.placesNew),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
