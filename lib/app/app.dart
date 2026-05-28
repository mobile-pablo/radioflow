import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../features/favorites/bloc/favorites_cubit.dart';
import '../features/player/bloc/player_bloc.dart';
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
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: appRouter,
      ),
    );
  }
}
