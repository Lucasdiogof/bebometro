import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injector.dart';
import 'core/sync/sync_cubit.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'account/application/auth_controller.dart';
import 'account/presentation/access_gate.dart';
import 'l10n/l10n.dart';
import 'l10n/locale_controller.dart';
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
  /// Last account's sync cubit and its id (see the builder below).
  SyncCubit? _sync;
  String? _syncUid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Restores the session from disk (no network needed) and starts
    // listening to auth events, e-mail links included.
    getIt<AuthController>().start();
    getIt<LocaleController>().addListener(_onLocale);
  }

  @override
  void dispose() {
    getIt<LocaleController>().removeListener(_onLocale);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// New language: [tr] is already switched; rebuild every element in place
  /// (state, forms, the running outing and a game in progress are kept) and
  /// refresh the lock-screen texts of the running outing.
  void _onLocale() {
    setState(() {});
    rebuildAllChildren(context);
    if (AccountScope.isOpen) {
      getIt<TrackingCoordinator>().refreshTexts();
      getIt<AuthController>().syncLanguage();
    }
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
        onGenerateTitle: (_) => tr.appName,
        navigatorKey: AppNavigator.key,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        // Device preference (Settings > Idioma); pt-BR is the final fallback.
        locale: getIt<LocaleController>().locale,
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en'),
          Locale('es'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
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
                builder: (context, uid, _) {
                  if (uid != null) {
                    _syncUid = uid;
                    _sync = getIt<SyncCubit>();
                  }
                  final sync = _sync;
                  // Signing out must NOT take the provider away while a route
                  // that was just closed is still animating out and listening
                  // to it (it would throw ProviderNotFound and trip the
                  // "_dependents.isEmpty" assertion). The last cubit (already
                  // closed) stays in place until the next account signs in;
                  // the same key keeps the tree from being rebuilt.
                  return sync == null
                      ? child!
                      : BlocProvider.value(
                          key: ValueKey(_syncUid),
                          value: sync,
                          child: child!,
                        );
                },
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
