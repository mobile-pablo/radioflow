import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../features/connectivity/offline_banner.dart';
import '../../features/player/widgets/mini_player.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.public_outlined),
                selectedIcon: const Icon(Icons.public),
                label: l10n.navDiscover,
              ),
              NavigationDestination(
                icon: const Icon(Icons.radio_outlined),
                selectedIcon: const Icon(Icons.radio),
                label: l10n.navStations,
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_outline),
                selectedIcon: const Icon(Icons.favorite),
                label: l10n.navFavorites,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
