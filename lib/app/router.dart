import 'package:go_router/go_router.dart';

import '../features/discover/presentation/pages/discover_page.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/stations/presentation/pages/stations_page.dart';
import 'widgets/home_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: DiscoverPage.path,
  routes: [
    GoRoute(
      path: SettingsPage.path,
      builder: (context, state) => const SettingsPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: DiscoverPage.path,
              builder: (context, state) => const DiscoverPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: StationsPage.path,
              builder: (context, state) => const StationsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: FavoritesPage.path,
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
