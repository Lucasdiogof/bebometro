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
import '../../outings/data/outing_repository.dart';
import '../../table/data/table_prefs_cubit.dart';
import '../../outings/presentation/outing_cubit.dart';
import '../../outings/presentation/start_outing_cubit.dart';
import '../../settings/presentation/settings_cubit.dart';
import '../config/env.dart';
import '../data/local_store.dart';
import '../sync/sync_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final store = await LocalStore.open();
  final bundledCatalog = await CatalogLoader.load();
  final bundledCards = await GameRepository.loadBundled();

  var cloudEnabled = true;
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabasePublishableKey,
    );
  } catch (_) {
    cloudEnabled = false;
  }

  getIt
    ..registerSingleton<LocalStore>(store)
    ..registerSingleton<SyncCubit>(SyncCubit(store, cloudEnabled: cloudEnabled))
    ..registerSingleton<OutingRepository>(
      OutingRepository(store),
    )
    ..registerSingleton<DrinkRepository>(
      DrinkRepository(store, bundledCatalog),
    )
    ..registerSingleton<TablePrefsCubit>(TablePrefsCubit(store))
    ..registerSingleton<GameRepository>(GameRepository(store, bundledCards))
    ..registerFactory<GameCubit>(() => GameCubit(getIt<GameRepository>()))
    ..registerFactory<HomeCubit>(
      () => HomeCubit(getIt<OutingRepository>(), getIt<DrinkRepository>()),
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
    ..registerFactory<StartOutingCubit>(
      () => StartOutingCubit(getIt<OutingRepository>()),
    )
    ..registerFactory<CatalogCubit>(() => CatalogCubit(getIt<DrinkRepository>()))
    ..registerFactoryParam<OutingCubit, String, void>(
      (outingId, _) => OutingCubit(
        outingId,
        getIt<OutingRepository>(),
        getIt<DrinkRepository>(),
      ),
    )
    ..registerFactoryParam<DrinkFormCubit, ({String outingId, CatalogItem item}),
        void>(
      (args, _) => DrinkFormCubit.forItem(
        getIt<DrinkRepository>(),
        getIt<OutingRepository>().byId(args.outingId)!,
        args.item,
      ),
      instanceName: 'new',
    )
    ..registerFactoryParam<DrinkFormCubit, DrinkEntry, void>(
      (entry, _) => DrinkFormCubit.forEntry(
        getIt<DrinkRepository>(),
        getIt<OutingRepository>().byId(entry.outingId)!,
        entry,
      ),
      instanceName: 'edit',
    );

  getIt<SyncCubit>().start();
}
