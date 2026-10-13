import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injector.dart';
import '../core/navigation/outing_flow.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';
import '../core/widgets/common.dart';
import '../drinks/presentation/add_drink_page.dart';
import '../games/presentation/resenha_page.dart';
import '../history/presentation/history_page.dart';
import '../home/presentation/home_page.dart';
import 'active_outing_cubit.dart';

/// The main navigation: Início, Catálogo, Histórico and Resenha. Each tab keeps
/// its state (filters, scroll) while the others are open. Back from another tab
/// returns to Início before leaving the app.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomePage(),
    AddDrinkPage(),
    HistoryPage(),
    ResenhaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActiveOutingCubit>(),
      child: PopScope(
        canPop: _index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _index = 0);
        },
        child: Scaffold(
          body: IndexedStack(index: _index, children: _tabs),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_index != 0) const _ActiveOutingBar(),
              NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Início',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: 'Catálogo',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history_rounded),
                    selectedIcon: Icon(Icons.history_toggle_off_rounded),
                    label: 'Histórico',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.celebration_outlined),
                    selectedIcon: Icon(Icons.celebration_rounded),
                    label: 'Resenha',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Discreet reminder of the running outing, with a quick way back to it.
class _ActiveOutingBar extends StatelessWidget {
  const _ActiveOutingBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveOutingCubit, ActiveOutingState>(
      builder: (context, state) {
        final outing = state.outing;
        if (outing == null) return const SizedBox.shrink();
        return Material(
          color: AppColors.surfaceHigh,
          child: InkWell(
            onTap: () => OutingFlow.open(context, outing.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.gutter, vertical: AppSpace.sm),
              child: Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Row(children: [
                    Flexible(
                      child: Text(
                        'Rolê em andamento · ${outing.displayName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(color: AppColors.text),
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    ElapsedText(since: outing.startedAt, style: AppText.caption),
                  ]),
                ),
                const Text('Voltar ao rolê',
                    style: TextStyle(
                        color: AppColors.amber, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        );
      },
    );
  }
}
