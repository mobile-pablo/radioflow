import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../shared/widgets/station_artwork.dart';
import '../../../../shared/widgets/station_tile.dart';
import '../../../discover/presentation/pages/discover_page.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../../recents/recents_cubit.dart';
import '../../bloc/favorites_cubit.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  static const String path = '/favorites';

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _sortByName = false;

  void _play(Station station) =>
      context.read<PlayerBloc>().add(PlayStationRequested(station));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          final favorites = [...state.favorites];
          if (_sortByName) {
            favorites.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
          }
          final loaded = state.status == FavoritesStatus.loaded;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.favoritesCollection.toUpperCase(),
                              style: textTheme.labelSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.navFavorites,
                              style: textTheme.displaySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        l10n.stationCount(state.favorites.length),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _RecentsStrip()),
              if (loaded && favorites.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.saved.toUpperCase(),
                          style: textTheme.labelSmall,
                        ),
                        _SortPill(
                          byName: _sortByName,
                          onTap: () =>
                              setState(() => _sortByName = !_sortByName),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!loaded)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (favorites.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyFavorites(),
                )
              else
                SliverList.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final station = favorites[index];
                    return Dismissible(
                      key: ValueKey(station.uuid),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) =>
                          context.read<FavoritesCubit>().remove(station.uuid),
                      child: BlocBuilder<PlayerBloc, PlayerState>(
                        buildWhen: (a, b) => a.station != b.station,
                        builder: (context, player) => StationTile(
                          station: station,
                          active: player.station?.uuid == station.uuid,
                          onTap: () => _play(station),
                        ),
                      ),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          );
        },
      ),
    );
  }
}

class _RecentsStrip extends StatelessWidget {
  const _RecentsStrip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<RecentsCubit, RecentsState>(
      builder: (context, state) {
        if (state.recents.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                l10n.recentlyPlayed.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: state.recents.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final station = state.recents[index];
                  return SizedBox(
                    width: 72,
                    child: GestureDetector(
                      onTap: () => context.read<PlayerBloc>().add(
                        PlayStationRequested(station),
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          StationArtwork(station: station, size: 64),
                          const SizedBox(height: 6),
                          Text(
                            station.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SortPill extends StatelessWidget {
  const _SortPill({required this.byName, required this.onTap});

  final bool byName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              byName ? l10n.sortName : l10n.sortRecent,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    AppColors.accent.withValues(alpha: 0),
                  ],
                ),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 44,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.favoritesEmptyTitle,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.favoritesEmptyBody,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.go(DiscoverPage.path),
              child: Text(l10n.discoverStations),
            ),
          ],
        ),
      ),
    );
  }
}
