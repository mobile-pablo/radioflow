import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../features/connectivity/connectivity_cubit.dart';
import '../features/favorites/bloc/favorites_cubit.dart';
import '../features/player/bloc/player_bloc.dart';
import '../features/recents/recents_cubit.dart';
import '../features/settings/bloc/settings_cubit.dart';
import 'di.dart';
import 'router.dart';

class RadioFlowApp extends StatelessWidget {
  const RadioFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerBloc>.value(value: getIt<PlayerBloc>()),
        BlocProvider<FavoritesCubit>.value(value: getIt<FavoritesCubit>()),
        BlocProvider<ConnectivityCubit>.value(
          value: getIt<ConnectivityCubit>(),
        ),
        BlocProvider<RecentsCubit>.value(value: getIt<RecentsCubit>()),
        BlocProvider<SettingsCubit>.value(value: getIt<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
