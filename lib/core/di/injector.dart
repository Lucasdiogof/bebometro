import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../account/application/auth_callback.dart';
import '../../account/application/auth_controller.dart';
import '../../drinks/data/catalog_loader.dart';
import '../../games/data/game_repository.dart';
import '../../games/domain/game_models.dart';
import '../../games/presentation/game_cubit.dart';
import '../../l10n/locale_controller.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/catalog_item.dart';
import '../../drinks/presentation/catalog_cubit.dart';
import '../../drinks/presentation/my_drinks_cubit.dart';
import '../../history/presentation/history_cubit.dart';
import '../../home/presentation/home_cubit.dart';
import '../../outing_drinks/data/outing_drink_repository.dart';
import '../../outings/data/outing_deletion.dart';
import '../../outings/data/outing_repository.dart';
import '../../places/data/device_location.dart';
import '../../places/data/geo_search.dart';
import '../../places/data/place_repository.dart';
import '../../places/presentation/places_cubit.dart';
import '../../scan/data/image_capture.dart';
import '../../scan/data/photo_files.dart';
import '../../scan/data/photo_uploader.dart';
import '../../scan/data/scan_draft_store.dart';
import '../../scan/data/text_recognizer.dart';
import '../../table/data/table_prefs_cubit.dart';
import '../../outings/presentation/outing_cubit.dart';
import '../../outings/presentation/price_fix_cubit.dart';
import '../../outings/presentation/start_outing_cubit.dart';
import '../../settings/presentation/settings_cubit.dart';
import '../../shell/active_outing_cubit.dart';
import '../../stats/presentation/stats_cubit.dart';
import '../../tab/data/tab_repository.dart';
import '../../tracking/application/tracking_coordinator.dart';
import '../../tracking/application/tracking_links.dart';
import '../../tracking/data/tracking_platform.dart';
import '../../tracking/data/tracking_prefs.dart';
import '../config/env.dart';
import '../data/app_prefs.dart';
import '../data/device_store.dart';
import '../data/local_store.dart';
import '../sync/sync_conflicts.dart';
import '../sync/sync_cubit.dart';

final getIt = GetIt.instance;

late List<CatalogItem> _bundledCatalog;
late List<GameCard> _bundledCards;
var _cloudEnabled = false;

/// Device level: everything that does not belong to an account (preferences
/// of the device, bundled assets, camera/OCR, map search, the native
/// lock-screen channel) plus the session controller. Account data is only
/// reachable after [AccountScope.open].
Future<void> configureDependencies() async {
  final device = await DeviceStore.open();
  _bundledCatalog = await CatalogLoader.load();
  _bundledCards = await GameRepository.loadBundled();

  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
      // PKCE: e-mail links are exchanged for a session by the device that
      // asked for them; the SDK listens for the links (app_links) itself.
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: true,
        // Only the auth callback is an auth link; bebometro://outing/... taps
        // from the lock screen are handled by the app itself.
        detectSessionInUriPredicate: (uri) => kIsWeb
            ? hasAuthCallbackParams(uri)
            : uri.host == Uri.parse(Env.authRedirectUrl).host,
      ),
    );
    _cloudEnabled = true;
  } catch (_) {
    _cloudEnabled = false;
  }

  getIt
    ..registerSingleton<DeviceStore>(device)
    // Language: a device preference, read before anything is shown.
    ..registerSingleton<LocaleController>(LocaleController(device))
    ..registerSingleton<AuthController>(
      AuthController(device, cloudEnabled: _cloudEnabled),
    )
    ..registerSingleton<PhotoFiles>(PhotoFiles())
    ..registerSingleton<ImageCaptureService>(ImageCaptureService())
    ..registerSingleton<TextRecognizer>(TextRecognizer())
    ..registerLazySingleton<TrackingPlatform>(() => TrackingPlatform())
    ..registerLazySingleton<TrackingPrefs>(() => TrackingPrefs(device))
    ..registerSingleton<TablePrefsCubit>(TablePrefsCubit(device))
    // Search and location are only called on demand (never at app start).
    ..registerLazySingleton<GeoSearch>(GeoSearch.new)
    ..registerLazySingleton<DeviceLocation>(DeviceLocation.new);
}

/// The data space of one signed-in account, as a get_it scope. Opening it
/// loads only that account's records; closing it stops the sync (late answers
/// are ignored because the store refuses writes once closed), ends the
/// lock-screen surface and drops a pending lock-screen tap.
class AccountScope {
  const AccountScope._();

  static const name = 'account';
  static String? _userId;

  /// Open account (null = none). Widgets above the navigator listen to it to
  /// provide the account's cubits to every route.
  static final current = ValueNotifier<String?>(null);

  static String? get userId => _userId;

  static bool get isOpen => getIt.hasScope(name);

  static Future<void> open(String userId) async {
    if (_userId == userId && isOpen) return;
    await close();
    final closing = _closing;
    if (closing != null) await closing;

    final store = await LocalStore.openAccount(userId);
    _userId = userId;
    getIt.pushNewScope(
      scopeName: name,
      init: (g) => _register(g, store, userId),
    );
    getIt<SyncCubit>().start();
    current.value = userId;
  }

  static Future<void>? _closing;

  /// Safe to call from several places at once (gate, sign-out, deletion).
  static Future<void> close() =>
      _closing ??= _close().whenComplete(() => _closing = null);

  static Future<void> _close() async {
    current.value = null;
    if (!isOpen) {
      _userId = null;
      return;
    }
    try {
      // Native surfaces and taps belong to the account being closed.
      await getIt<TrackingCoordinator>().shutdown();
      await getIt<TrackingPlatform>().consumeLink();
    } catch (_) {}
    await getIt.dropScope(name);
    _userId = null;
  }

  static void _register(GetIt g, LocalStore store, String userId) {
    final files = getIt<PhotoFiles>();
    final outingDrinks = OutingDrinkRepository(store, files);
    final conflicts = SyncConflicts(store);
    g
      ..registerSingleton<LocalStore>(store, dispose: (s) => s.close())
      ..registerSingleton<SyncConflicts>(conflicts, dispose: (c) => c.dispose())
      ..registerSingleton<OutingDrinkRepository>(outingDrinks)
      ..registerSingleton<ScanDraftStore>(ScanDraftStore(store))
      ..registerSingleton<SyncCubit>(
        SyncCubit(
          store,
          cloudEnabled: _cloudEnabled,
          userId: userId,
          conflicts: conflicts,
          uploads: PhotoUploader(store, outingDrinks),
        ),
        dispose: (c) => c.close(),
      )
      ..registerSingleton<OutingRepository>(OutingRepository(store))
      ..registerSingleton<DrinkRepository>(
        DrinkRepository(store, _bundledCatalog),
      )
      ..registerSingleton<OutingDeletion>(
        OutingDeletion(getIt<OutingRepository>(), getIt<DrinkRepository>()),
      )
      ..registerSingleton<TrackingCoordinator>(
        TrackingCoordinator(
          getIt<TrackingPlatform>(),
          getIt<TrackingPrefs>(),
          getIt<OutingRepository>(),
          getIt<DrinkRepository>(),
        ),
        dispose: (c) => c.dispose(),
      )
      ..registerSingleton<TrackingLinks>(
        TrackingLinks(
          getIt<TrackingPlatform>(),
          getIt<OutingRepository>(),
          getIt<TrackingCoordinator>(),
        ),
        dispose: (l) => l.stop(),
      )
      ..registerLazySingleton<TabRepository>(
        () => TabRepository(store, getIt<DrinkRepository>()),
      )
      ..registerSingleton<AppPrefs>(AppPrefs(getIt<DeviceStore>(), store))
      ..registerSingleton<GameRepository>(GameRepository(store, _bundledCards))
      ..registerSingleton<PlaceRepository>(PlaceRepository(store))
      ..registerFactory<GameCubit>(() => GameCubit(getIt<GameRepository>()))
      ..registerFactory<StatsCubit>(
        () => StatsCubit(
          getIt<OutingRepository>(),
          getIt<DrinkRepository>(),
          getIt<PlaceRepository>(),
        ),
      )
      ..registerFactory<ActiveOutingCubit>(
        () => ActiveOutingCubit(
          getIt<OutingRepository>(),
          getIt<DrinkRepository>(),
        ),
      )
      ..registerFactory<HomeCubit>(
        () => HomeCubit(
          getIt<OutingRepository>(),
          getIt<DrinkRepository>(),
          getIt<AppPrefs>(),
        ),
      )
      ..registerFactory<HistoryCubit>(
        () => HistoryCubit(
          getIt<OutingRepository>(),
          getIt<DrinkRepository>(),
          getIt<TabRepository>(),
        ),
      )
      ..registerFactory<SettingsCubit>(
        () =>
            SettingsCubit(getIt<OutingRepository>(), getIt<DrinkRepository>()),
      )
      ..registerFactory<MyDrinksCubit>(
        () =>
            MyDrinksCubit(getIt<DrinkRepository>(), getIt<OutingRepository>()),
      )
      ..registerFactory<PlacesCubit>(
        () => PlacesCubit(getIt<PlaceRepository>(), getIt<OutingRepository>()),
      )
      ..registerFactoryParam<PlaceDetailCubit, String, void>(
        (placeId, _) => PlaceDetailCubit(
          placeId,
          getIt<PlaceRepository>(),
          getIt<OutingRepository>(),
          getIt<DrinkRepository>(),
        ),
      )
      ..registerFactory<StartOutingCubit>(
        () => StartOutingCubit(
          getIt<OutingRepository>(),
          getIt<PlaceRepository>(),
          getIt<TabRepository>(),
        ),
      )
      ..registerFactory<CatalogCubit>(
        () => CatalogCubit(getIt<DrinkRepository>()),
      )
      ..registerFactoryParam<PriceFixCubit, String, void>(
        (outingId, _) => PriceFixCubit(
          outingId,
          getIt<DrinkRepository>(),
          getIt<TabRepository>(),
        ),
      )
      ..registerFactoryParam<OutingCubit, String, void>(
        (outingId, _) => OutingCubit(
          outingId,
          getIt<OutingRepository>(),
          getIt<DrinkRepository>(),
          getIt<AppPrefs>(),
        ),
      );
  }
}
