import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../outings/presentation/outing_summary_page.dart';
import 'history_cubit.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HistoryCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Histórico')),
        body: SafeArea(
          child: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              if (state.loading) return const LoadingView();
              if (state.items.isEmpty) {
                return const EmptyView(
                  icon: Icons.history_rounded,
                  title: 'Nenhum rolê encerrado',
                  message: 'Quando você encerrar um rolê, ele aparece aqui.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final item = state.items[i];
                  final o = item.outing;
                  final s = item.summary;
                  return SurfaceCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OutingSummaryPage(outingId: o.id),
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(o.type.icon, color: AppColors.amber),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.displayName,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(
                              '${formatDate(o.startedAt)} · ${formatTime(o.startedAt)}',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${s.entryCount} ${s.entryCount == 1 ? 'bebida' : 'bebidas'}'
                              ' · ${formatMl(s.personalMl)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            s.pricedCount == 0
                                ? 'Sem valores'
                                : formatCents(s.informedCents),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          if (s.unpricedCount > 0)
                            Text('${s.unpricedCount} sem preço',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
