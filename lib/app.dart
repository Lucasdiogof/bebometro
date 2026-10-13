import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injector.dart';
import 'core/sync/sync_cubit.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'account/application/auth_controller.dart';
import 'account/presentation/access_gate.dart';
import 'table/data/table_prefs_cubit.dart';
import 'tracking/application/tracking_coordinator.dart';
import 'tracking/application/tracking_links.dart';

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
    // Restores the session from disk (no network needed) and starts
    // listening to auth events, e-mail links included.
    getIt<AuthController>().start();
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
    if (state == AppLifecycleState.resumed && AccountScope.isOpen) {
      getIt<SyncCubit>().schedule(immediate: true);
      // Reconcile the lock-screen surface with the stored state and pick up a
      // tap that arrived while the app was in the background.
      getIt<TrackingCoordinator>().schedule(immediate: true);
      getIt<TrackingLinks>().poll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthController>()),
        BlocProvider.value(value: getIt<TablePrefsCubit>()),
      ],
      child: MaterialApp(
        title: 'Bebômetro',
        navigatorKey: AppNavigator.key,
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
              // Every route of an account sees that account's sync state.
              child: ValueListenableBuilder<String?>(
                valueListenable: AccountScope.current,
                builder: (context, uid, _) => uid == null
                    ? child!
                    : BlocProvider.value(
                        key: ValueKey(uid),
                        value: getIt<SyncCubit>(),
                        child: child!,
                      ),
              ),
            ),
          ),
        ),
        // Sign-in, old records and the product itself: decided in one place.
        home: const AccessGate(),
      ),
    );
  }
}
