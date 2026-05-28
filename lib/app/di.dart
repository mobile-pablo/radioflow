import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/favorites/bloc/favorites_cubit.dart';
import '../features/player/audio/audio_controller.dart';
import '../features/player/bloc/player_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<RadioBrowserApi>(
      () => RadioBrowserApi(createRadioBrowserDio()),
    )
    ..registerLazySingleton<StationRepository>(
      () => StationRepositoryImpl(getIt<RadioBrowserApi>()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(getIt<SharedPreferences>()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt<SharedPreferences>()),
    )
    ..registerLazySingleton<AudioController>(AudioController.new)
    ..registerLazySingleton<PlayerBloc>(
      () => PlayerBloc(getIt<AudioController>()),
    )
    ..registerLazySingleton<FavoritesCubit>(
      () => FavoritesCubit(getIt<FavoritesRepository>())..load(),
    );
}
