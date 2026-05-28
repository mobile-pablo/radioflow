import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/connectivity/offline_banner.dart';
import '../../features/player/bloc/player_bloc.dart';
import '../../features/player/widgets/mini_player.dart';
import '../../features/recents/recents_cubit.dart';
import 'floating_nav_bar.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (a, b) =>
          b.station != null && a.station?.uuid != b.station?.uuid,
      listener: (context, state) {
        final station = state.station;
        if (station != null) context.read<RecentsCubit>().push(station);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                const OfflineBanner(),
                Expanded(child: navigationShell),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MiniPlayer(),
                      const SizedBox(height: AppSpacing.sm),
                      FloatingNavBar(navigationShell: navigationShell),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
