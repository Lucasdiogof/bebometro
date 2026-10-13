import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injector.dart';
import 'core/sync/sync_cubit.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'home/presentation/home_page.dart';
import 'table/data/table_prefs_cubit.dart';

class BebometroApp extends StatefulWidget {
  const BebometroApp({super.key});

  @override
  State<BebometroApp> createState() => _BebometroAppState();
}

class _BebometroAppState extends State<BebometroApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Anything still pending (e.g. records the server refused before it was
  /// ready for them) is retried whenever the app comes back to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getIt<SyncCubit>().schedule(immediate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SyncCubit>()),
        BlocProvider.value(value: getIt<TablePrefsCubit>()),
      ],
      child: MaterialApp(
        title: 'Bebômetro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // On wide screens (web/tablet) keep the phone layout centred instead of
        // stretching it across the window.
        builder: (context, child) => ColoredBox(
          color: AppColors.background,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: child,
            ),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
