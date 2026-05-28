import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/station_tile.dart';
import '../../../discover/presentation/pages/discover_page.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../bloc/favorites_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const String path = '/favorites';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.status != FavoritesStatus.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.favorites.isEmpty) {
            return const _EmptyFavorites();
          }
          return BlocBuilder<PlayerBloc, PlayerState>(
            buildWhen: (a, b) => a.station != b.station,
            builder: (context, playerState) {
              final activeUuid = playerState.station?.uuid;
              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final station = state.favorites[index];
                  return Dismissible(
                    key: ValueKey(station.uuid),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteBackground(),
                    onDismissed: (_) =>
                        context.read<FavoritesCubit>().remove(station.uuid),
                    child: StationTile(
                      station: station,
                      active: station.uuid == activeUuid,
                      onTap: () => context.read<PlayerBloc>().add(
                        PlayStationRequested(station),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.danger.withValues(alpha: 0.18),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: AppSpacing.xl),
          child: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RfLogo(size: 64, glow: false),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No favorites yet',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the heart on any station to keep it here.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.go(DiscoverPage.path),
              child: const Text('Discover stations'),
            ),
          ],
        ),
      ),
    );
  }
}
