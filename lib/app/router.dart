import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/browse/presentation/pages/browse_page.dart';
import '../features/discover/presentation/pages/discover_page.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/welcome/presentation/pages/welcome_page.dart';
import 'di.dart';
import 'widgets/home_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: DiscoverPage.path,
  redirect: (context, state) {
    final seen =
        getIt<SharedPreferences>().getBool(kWelcomeSeenKey) ?? false;
    final atWelcome = state.matchedLocation == WelcomePage.path;
    if (!seen && !atWelcome) return WelcomePage.path;
    if (seen && atWelcome) return DiscoverPage.path;
    return null;
  },
  routes: [
    GoRoute(
      path: WelcomePage.path,
      builder: (context, state) => const WelcomePage(),
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
              path: FavoritesPage.path,
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: BrowsePage.path,
              builder: (context, state) => const BrowsePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: SearchPage.path,
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: SettingsPage.path,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
