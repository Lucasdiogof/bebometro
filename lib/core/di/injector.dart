import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../drinks/data/catalog_loader.dart';
import '../../games/data/game_repository.dart';
import '../../games/presentation/game_cubit.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/catalog_item.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/catalog_cubit.dart';
import '../../drinks/presentation/drink_form_cubit.dart';
import '../../drinks/presentation/my_drinks_cubit.dart';
import '../../history/presentation/history_cubit.dart';
import '../../home/presentation/home_cubit.dart';
import '../../outing_drinks/data/outing_drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
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
import '../data/local_store.dart';
import '../sync/sync_cubit.dart';

final getIt = GetIt.instance;

/// Records to look the user's own prices up in: same saved place (by id), or
/// just the same outing when it has no saved place.
List<DrinkEntry> _priceCandidates(Outing outing) {
  final ids = <String>{outing.id};
  final placeId = outing.placeId;
  if (placeId != null) {
    ids.addAll(getIt<OutingRepository>().forPlace(placeId).map((o) => o.id));
  }
  return [
    for (final e in getIt<DrinkRepository>().allEntries())
      if (ids.contains(e.outingId)) e,
  ];
}

Future<void> configureDependencies() async {
  final store = await LocalStore.open();
  final bundledCatalog = await CatalogLoader.load();
  final bundledCards = await GameRepository.loadBundled();

  var cloudEnabled = true;
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
    );
  } catch (_) {
    cloudEnabled = false;
  }

  final photoFiles = PhotoFiles();
  final outingDrinks = OutingDrinkRepository(store, photoFiles);

  getIt
    ..registerSingleton<LocalStore>(store)
    ..registerSingleton<OutingDrinkRepository>(outingDrinks)
    ..registerSingleton<ScanDraftStore>(ScanDraftStore(store))
    ..registerSingleton<ImageCaptureService>(ImageCaptureService())
    ..registerSingleton<TextRecognizer>(TextRecognizer())
    ..registerSingleton<SyncCubit>(SyncCubit(
      store,
      cloudEnabled: cloudEnabled,
      uploads: PhotoUploader(store, outingDrinks),
    ))
    ..registerSingleton<OutingRepository>(
      OutingRepository(store),
    )
    ..registerSingleton<DrinkRepository>(
      DrinkRepository(store, bundledCatalog),
    )
    ..registerLazySingleton<TrackingPlatform>(() => TrackingPlatform())
    ..registerLazySingleton<TrackingPrefs>(() => TrackingPrefs(store))
    ..registerLazySingleton<TrackingCoordinator>(
      () => TrackingCoordinator(
        getIt<TrackingPlatform>(),
        getIt<TrackingPrefs>(),
        getIt<OutingRepository>(),
        getIt<DrinkRepository>(),
      ),
    )
    ..registerLazySingleton<TrackingLinks>(
      () => TrackingLinks(
        getIt<TrackingPlatform>(),
        getIt<OutingRepository>(),
        getIt<TrackingCoordinator>(),
      ),
    )
    ..registerLazySingleton<TabRepository>(
      () => TabRepository(store, getIt<DrinkRepository>()),
    )
    ..registerSingleton<AppPrefs>(AppPrefs(store))
    ..registerSingleton<TablePrefsCubit>(TablePrefsCubit(store))
    ..registerSingleton<GameRepository>(GameRepository(store, bundledCards))
    ..registerFactory<GameCubit>(() => GameCubit(getIt<GameRepository>()))
    ..registerFactory<StatsCubit>(
      () => StatsCubit(
        getIt<OutingRepository>(),
        getIt<DrinkRepository>(),
        getIt<PlaceRepository>(),
      ),
    )
    ..registerFactory<ActiveOutingCubit>(
      () => ActiveOutingCubit(getIt<OutingRepository>(), getIt<DrinkRepository>()),
    )
    ..registerFactory<HomeCubit>(
      () => HomeCubit(
        getIt<OutingRepository>(),
        getIt<DrinkRepository>(),
        getIt<AppPrefs>(),
      ),
    )
    ..registerFactory<HistoryCubit>(
      () => HistoryCubit(getIt<OutingRepository>(), getIt<DrinkRepository>()),
    )
    ..registerFactory<SettingsCubit>(
      () => SettingsCubit(getIt<OutingRepository>(), getIt<DrinkRepository>()),
    )
    ..registerFactory<MyDrinksCubit>(
      () => MyDrinksCubit(getIt<DrinkRepository>(), getIt<OutingRepository>()),
    )
    ..registerSingleton<PlaceRepository>(PlaceRepository(store))
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
      () => StartOutingCubit(getIt<OutingRepository>(), getIt<PlaceRepository>()),
    )
    ..registerFactory<CatalogCubit>(() => CatalogCubit(getIt<DrinkRepository>()))
    ..registerFactoryParam<PriceFixCubit, String, void>(
      (outingId, _) => PriceFixCubit(outingId, getIt<DrinkRepository>()),
    )
    ..registerFactoryParam<OutingCubit, String, void>(
      (outingId, _) => OutingCubit(
        outingId,
        getIt<OutingRepository>(),
        getIt<DrinkRepository>(),
        getIt<AppPrefs>(),
      ),
    )
    ..registerFactoryParam<DrinkFormCubit, ({String outingId, CatalogItem item}),
        void>(
      (args, _) {
        final outing = getIt<OutingRepository>().byId(args.outingId)!;
        return DrinkFormCubit.forItem(
          getIt<DrinkRepository>(),
          outing,
          args.item,
          _priceCandidates(outing),
        );
      },
      instanceName: 'new',
    )
    ..registerFactoryParam<DrinkFormCubit, DrinkEntry, void>(
      (entry, _) {
        final outing = getIt<OutingRepository>().byId(entry.outingId)!;
        return DrinkFormCubit.forEntry(
          getIt<DrinkRepository>(),
          outing,
          entry,
          _priceCandidates(outing),
        );
      },
      instanceName: 'edit',
    );

  getIt<SyncCubit>().start();
}
