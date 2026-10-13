import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../outings/domain/outing.dart';
import '../../places/presentation/place_detail_page.dart';
import '../domain/stats_report.dart';
import 'records_page.dart';
import 'stats_cubit.dart';

/// Personal statistics for a period. Everything is derived from the user's own
/// records; unknown values stay unknown and incomplete totals are labelled.
/// There is no score, ranking or consumption limit.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StatsCubit>(),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  void _openEntries(BuildContext context, String title, List<dynamic> entries) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RecordsPage.entries(
        title: title,
        entries: entries.cast(),
      ),
    ));
  }

  Future<void> _pickCustom(BuildContext context) async {
    final cubit = context.read<StatsCubit>();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: cubit.state.range == null
          ? null
          : DateTimeRange(
              start: cubit.state.range!.start,
              end: cubit.state.range!.end.subtract(const Duration(days: 1)),
            ),
    );
    if (picked != null) cubit.setCustom(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatsCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          final report = state.report;
          if (report == null) return const LoadingView();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final p in StatsPreset.values)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpace.sm),
                        child: ChoiceChip(
                          label: Text(p.label),
                          selected: state.preset == p,
                          showCheckmark: false,
                          onSelected: (_) => p == StatsPreset.custom
                              ? _pickCustom(context)
                              : cubit.setPreset(p),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${formatDate(report.range.start)} a '
                '${formatDate(report.range.end.subtract(const Duration(days: 1)))}'
                ' · ${report.range.days} dias',
                style: AppText.caption,
              ),
              if (report.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpace.xl),
                  child: EmptyView(
                    icon: Icons.insights_outlined,
                    title: 'Nada registrado neste período',
                    message: 'Isso só quer dizer que não há registros aqui, '
                        'não que não houve rolê.',
                  ),
                )
              else ...[
                const SectionTitle('Resumo'),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RecordsPage.outings(
                                    title: 'Rolês do período',
                                    outings: report.outings),
                              ),
                            ),
                            child: StatTile(
                                label: 'Rolês', value: '${report.outings.length}'),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _openEntries(
                                context, 'Bebidas do período', report.entries),
                            child: StatTile(
                                label: 'Bebidas registradas',
                                value: '${report.entries.length}'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpace.lg),
                      InkWell(
                        onTap: () => _openEntries(context, 'Registros com preço',
                            [for (final e in report.entries) if (e.hasPrice) e]),
                        child: StatTile(
                          label: 'Gasto informado',
                          value: formatCents(report.informedCents),
                          icon: Icons.payments_outlined,
                        ),
                      ),
                      if (report.unpricedCount > 0) ...[
                        const SizedBox(height: AppSpace.sm),
                        InfoPill(
                          '${report.unpricedCount} '
                          '${report.unpricedCount == 1 ? 'bebida' : 'bebidas'} '
                          'sem preço: o total pode estar maior',
                          icon: Icons.sell_outlined,
                          warning: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SectionTitle('Volume pessoal informado'),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: StatTile(
                            label: 'Bebidas com álcool',
                            value: formatMl(report.alcoholicMl),
                            icon: Icons.local_bar_outlined,
                          ),
                        ),
                        Expanded(
                          child: StatTile(
                            label: 'Água e sem álcool',
                            value: formatMl(report.nonAlcoholicMl),
                            icon: Icons.water_drop_outlined,
                          ),
                        ),
                      ]),
                      if (report.unknownVolumeCount > 0) ...[
                        const SizedBox(height: AppSpace.sm),
                        InfoPill(
                          '${report.unknownVolumeCount} '
                          '${report.unknownVolumeCount == 1 ? 'registro' : 'registros'} '
                          'sem volume: não entram nas somas',
                          icon: Icons.opacity_outlined,
                          warning: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SectionTitle('Álcool calculado'),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatTile(
                        label: 'Álcool puro dos dados conhecidos',
                        value: (report.alcoholIncomplete ? 'pelo menos ' : '') +
                            formatGrams(report.pureAlcoholGrams),
                        icon: Icons.science_outlined,
                      ),
                      if (report.alcoholIncomplete) ...[
                        const SizedBox(height: AppSpace.sm),
                        InfoPill(
                          '${report.incompleteAlcoholCount} '
                          '${report.incompleteAlcoholCount == 1 ? 'registro' : 'registros'} '
                          'com teor ou quantidade desconhecidos',
                          icon: Icons.help_outline_rounded,
                          warning: true,
                        ),
                      ],
                      const SizedBox(height: AppSpace.sm),
                      const Text(
                        'Volume × teor (ou quantidade × teor dos componentes '
                        'dos drinks). Não é concentração no sangue.',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                if (report.alcoholic.isNotEmpty) ...[
                  const SectionTitle('Com álcool, por categoria'),
                  _Bars(
                    items: [
                      for (final c in report.alcoholic)
                        _Bar(
                          label: c.category.label,
                          value: c.count,
                          note: c.unknownVolumeCount > 0
                              ? '${c.unknownVolumeCount} sem volume'
                              : null,
                          onTap: () => _openEntries(
                              context, c.category.label, c.entries),
                        ),
                    ],
                  ),
                ],
                if (report.nonAlcoholic.isNotEmpty) ...[
                  const SectionTitle('Água e sem álcool, à parte'),
                  _Bars(
                    items: [
                      for (final c in report.nonAlcoholic)
                        _Bar(
                          label: c.category.label,
                          value: c.count,
                          color: const Color(0xFF6EC1E4),
                          onTap: () => _openEntries(
                              context, c.category.label, c.entries),
                        ),
                    ],
                  ),
                ],
                const SectionTitle('Locais mais visitados'),
                for (final p in report.places.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.sm),
                    child: SurfaceCard(
                      onTap: p.placeId == null
                          ? null
                          : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  PlaceDetailPage(placeId: p.placeId!))),
                      child: Row(children: [
                        Expanded(
                            child: Text(p.label, style: AppText.subtitle)),
                        Text('${p.visits} ${p.visits == 1 ? 'rolê' : 'rolês'}',
                            style: AppText.caption),
                      ]),
                    ),
                  ),
                const Text(
                  'Locais só são agrupados quando são o mesmo local salvo; '
                  'nomes parecidos não são unidos.',
                  style: AppText.caption,
                ),
                const SectionTitle('Relatos pós-rolê'),
                if (report.moods.isEmpty)
                  const Text('Nenhum relato neste período.',
                      style: AppText.caption)
                else
                  _Bars(
                    items: [
                      for (final m in FeedbackMood.values)
                        if (report.moods[m] != null)
                          _Bar(label: m.label, value: report.moods[m]!),
                    ],
                  ),
                if (report.withoutMood > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.sm),
                    child: Text('${report.withoutMood} sem relato.',
                        style: AppText.caption),
                  ),
                const Padding(
                  padding: EdgeInsets.only(top: AppSpace.xs),
                  child: Text(
                    'Relatos são pessoais: não medem tolerância e não indicam '
                    'um limite seguro.',
                    style: AppText.caption,
                  ),
                ),
                const SectionTitle('Período anterior'),
                _Comparison(state: state),
                const SizedBox(height: AppSpace.xl),
                const Text(
                  'Dia sem registro não significa dia sem beber: os números '
                  'refletem só o que foi registrado.',
                  style: AppText.caption,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Bar {
  const _Bar({
    required this.label,
    required this.value,
    this.note,
    this.color = AppColors.amber,
    this.onTap,
  });

  final String label;
  final int value;
  final String? note;
  final Color color;
  final VoidCallback? onTap;
}

/// Simple horizontal bars: easy to read and with a count on every bar, so the
/// value never depends on colour or on measuring the bar.
class _Bars extends StatelessWidget {
  const _Bars({required this.items});

  final List<_Bar> items;

  @override
  Widget build(BuildContext context) {
    final max = items.fold<int>(1, (m, b) => b.value > m ? b.value : m);
    return Column(
      children: [
        for (final b in items)
          Semantics(
            label: '${b.label}: ${b.value}',
            button: b.onTap != null,
            child: InkWell(
              onTap: b.onTap,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                child: Row(children: [
                  SizedBox(
                    width: 112,
                    child: Text(b.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body),
                  ),
                  Expanded(
                    child: LayoutBuilder(builder: (context, c) {
                      return Stack(children: [
                        Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        Container(
                          height: 14,
                          width: c.maxWidth * b.value / max,
                          decoration: BoxDecoration(
                            color: b.color,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ]);
                    }),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  SizedBox(
                    width: 36,
                    child: Text('${b.value}',
                        textAlign: TextAlign.end, style: AppText.subtitle),
                  ),
                ]),
              ),
            ),
          ),
        if (items.any((b) => b.note != null))
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              [for (final b in items) if (b.note != null) '${b.label}: ${b.note}']
                  .join(' · '),
              style: AppText.caption,
            ),
          ),
      ],
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.state});

  final StatsState state;

  @override
  Widget build(BuildContext context) {
    final report = state.report!;
    final prev = state.previous;
    if (!state.hasComparison || prev == null) {
      return SurfaceCard(
        child: Text(
          'Sem base de comparação: não há rolês registrados nos '
          '${report.range.days} dias anteriores a este período.',
          style: AppText.caption,
        ),
      );
    }
    final incomplete = report.unpricedCount > 0 || prev.unpricedCount > 0;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparado aos ${report.range.days} dias imediatamente antes '
            '(${formatDate(prev.range.start)} a '
            '${formatDate(prev.range.end.subtract(const Duration(days: 1)))}).',
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.md),
          _line('Rolês', '${report.outings.length}', '${prev.outings.length}'),
          _line('Bebidas registradas', '${report.entries.length}',
              '${prev.entries.length}'),
          _line('Gasto informado', formatCents(report.informedCents),
              formatCents(prev.informedCents)),
          if (incomplete)
            const Padding(
              padding: EdgeInsets.only(top: AppSpace.sm),
              child: Text(
                'Há bebidas sem preço em um dos períodos: o gasto real pode '
                'ser maior que o informado.',
                style: AppText.caption,
              ),
            ),
        ],
      ),
    );
  }

  Widget _line(String label, String now, String before) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(label, style: AppText.body)),
          Text('$now  (antes: $before)', style: AppText.subtitle),
        ]),
      );
}
