import 'package:core/core.dart';
import 'package:flutter/material.dart';

class StationsPage extends StatelessWidget {
  const StationsPage({super.key});

  static const String path = '/stations';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RfLogo(size: 72, glow: false),
          const SizedBox(height: AppSpacing.lg),
          Text('Stations', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
