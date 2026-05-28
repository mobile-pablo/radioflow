import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/player/bloc/player_bloc.dart';
import 'di.dart';
import 'router.dart';

class RadioFlowApp extends StatelessWidget {
  const RadioFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayerBloc>.value(
      value: getIt<PlayerBloc>(),
      child: MaterialApp.router(
        title: 'RadioFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
