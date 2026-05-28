import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../features/connectivity/offline_banner.dart';
import '../../features/player/bloc/player_bloc.dart';
import '../../features/player/widgets/mini_player.dart';
import '../../features/recents/recents_cubit.dart';
import '../../shared/widgets/city_bar.dart';
import 'floating_nav_bar.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (a, b) =>
          (b.station != null && a.station?.uuid != b.station?.uuid) ||
          (a.status != b.status && b.status == PlaybackStatus.error),
      listener: (context, state) {
        if (state.status == PlaybackStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).stationUnavailable)),
          );
          return;
        }
        final station = state.station;
        if (station != null) context.read<RecentsCubit>().push(station);
      },
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: navigationShell),
            const CityBar(),
            const MiniPlayer(),
            FloatingNavBar(navigationShell: navigationShell),
          ],
        ),
      ),
    );
  }
}
