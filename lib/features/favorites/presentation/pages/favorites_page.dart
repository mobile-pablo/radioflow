import 'package:core/core.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const String path = '/favorites';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RfLogo(size: 72, glow: false),
          const SizedBox(height: AppSpacing.lg),
          Text('Favorites', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
