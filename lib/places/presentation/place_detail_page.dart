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
import 'place_editor_page.dart';
import 'places_cubit.dart';

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
            body: const ErrorView(message: 'Esse local não foi encontrado.'),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Local'),
            actions: [
              IconButton(
                tooltip: place.favorite ? 'Remover dos favoritos' : 'Favoritar',
                onPressed: cubit.toggleFavorite,
                icon: Icon(
                  place.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: place.favorite ? AppColors.amber : AppColors.textMuted,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                onSelected: (v) async {
                  if (v == 'edit') {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PlaceEditorPage(editing: place)));
                  } else if (v == 'archive') {
                    await cubit.setArchived(!place.isArchived);
                    if (context.mounted) {
                      showToast(context,
                          place.isArchived ? 'Local reativado' : 'Local arquivado');
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(place.isArchived ? 'Reativar' : 'Arquivar'),
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
                        const InfoPill('Arquivado'),
                      ],
                    ]),
                    const SizedBox(height: AppSpace.sm),
                    Text(place.displayName, style: AppText.headline),
                    if (place.subtitleAddress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.xs),
                        child: Text(place.subtitleAddress!, style: AppText.caption),
                      ),
                    if (place.cityState != null)
                      Text(place.cityState!, style: AppText.caption),
                    const SizedBox(height: AppSpace.lg),
                    Row(children: [
                      Expanded(
                        child: StatTile(
                            label: 'Rolês', value: '${state.visits.length}'),
                      ),
                      Expanded(
                        child: StatTile(
                            label: 'Bebidas', value: '${state.drinkCount}'),
                      ),
                      Expanded(
                        child: StatTile(
                          label: 'Gasto informado',
                          value: formatCents(state.informedCents),
                        ),
                      ),
                    ]),
                    if (state.unpricedCount > 0) ...[
                      const SizedBox(height: AppSpace.md),
                      InfoPill(
                        '${state.unpricedCount} '
                        '${state.unpricedCount == 1 ? 'bebida' : 'bebidas'} '
                        'sem preço: o total pode estar maior',
                        icon: Icons.sell_outlined,
                        warning: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SectionTitle('Seu histórico de preços'),
              if (state.priceStats.isEmpty)
                const Text(
                  'Ainda não há preços informados por você aqui. Quando houver, '
                  'o último preço e a faixa observada aparecem neste lugar.',
                  style: AppText.caption,
                )
              else ...[
                for (final g in state.priceStats) _PriceTile(stats: g),
                const Padding(
                  padding: EdgeInsets.only(top: AppSpace.sm),
                  child: Text(
                    'Seu histórico: só o que você mesmo informou neste local, '
                    'por bebida e tamanho. Não é média de mercado, da cidade '
                    'nem do estado.',
                    style: AppText.caption,
                  ),
                ),
              ],
              SectionTitle('Rolês neste local (${state.visits.length})'),
              if (state.visits.isEmpty)
                const Text('Nenhum rolê registrado aqui ainda.',
                    style: AppText.caption)
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
                                '${v.outing.isActive ? ' · em andamento' : ''}',
                                style: AppText.subtitle,
                              ),
                              Text(
                                '${v.summary.entryCount} '
                                '${v.summary.entryCount == 1 ? 'bebida' : 'bebidas'}'
                                ' · ${v.summary.pricedCount == 0 ? 'sem valores' : formatCents(v.summary.informedCents)}',
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
        : '${formatCents(stats.minCents)} a ${formatCents(stats.maxCents)}';
    final period = stats.firstAt.year == stats.lastAt.year &&
            stats.firstAt.month == stats.lastAt.month &&
            stats.firstAt.day == stats.lastAt.day
        ? formatDate(stats.lastAt)
        : '${formatDate(stats.firstAt)} a ${formatDate(stats.lastAt)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stats.label, style: AppText.subtitle),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Último: ${formatCents(stats.lastCents)} em ${formatDate(stats.lastAt)}'
              '${stats.shared ? ' (total da garrafa/porção)' : ''}',
              style: AppText.body,
            ),
            Text(
              'Faixa observada: $range · ${stats.count} '
              '${stats.count == 1 ? 'registro' : 'registros'} · $period',
              style: AppText.caption,
            ),
          ],
        ),
      ),
    );
  }
}
