import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'router.dart';

class RadioFlowApp extends StatelessWidget {
  const RadioFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RadioFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
