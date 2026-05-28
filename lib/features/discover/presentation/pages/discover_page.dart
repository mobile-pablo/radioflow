import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/di.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../bloc/map_cubit.dart';
import '../../bloc/station_cluster.dart';
import '../widgets/cluster_sheet.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  static const String path = '/discover';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapCubit>(
      create: (_) => MapCubit(getIt<StationRepository>())..load(),
      child: const _DiscoverView(),
    );
  }
}

class _DiscoverView extends StatelessWidget {
  const _DiscoverView();

  void _onClusterTap(BuildContext context, StationCluster cluster) {
    if (cluster.isSingle) {
      context.read<PlayerBloc>().add(PlayStationRequested(cluster.primary));
    } else {
      ClusterSheet.show(context, cluster);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(20, 0),
                initialZoom: 2.5,
                minZoom: 1.5,
                maxZoom: 12,
                backgroundColor: AppColors.ink,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onPositionChanged: (camera, _) =>
                    context.read<MapCubit>().onZoomChanged(camera.zoom),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.mobile.pablo.radioflow',
                ),
                MarkerLayer(
                  markers: [
                    for (final cluster in state.clusters)
                      Marker(
                        point: cluster.center,
                        width: 46,
                        height: 46,
                        child: _ClusterMarker(
                          cluster: cluster,
                          onTap: () => _onClusterTap(context, cluster),
                        ),
                      ),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap'),
                    TextSourceAttribution('CARTO'),
                  ],
                ),
              ],
            ),
            if (state.status == MapStatus.loading)
              const ColoredBox(
                color: AppColors.ink,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state.status == MapStatus.failure)
              _MapError(onRetry: () => context.read<MapCubit>().load()),
          ],
        );
      },
    );
  }
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({required this.cluster, required this.onTap});

  final StationCluster cluster;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSingle = cluster.isSingle;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: isSingle ? 16 : 30,
          height: isSingle ? 16 : 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSingle
                ? AppColors.accent
                : AppColors.accent.withValues(alpha: 0.22),
            border: Border.all(color: AppColors.accent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: isSingle
              ? null
              : Text(
                  '${cluster.count}',
                  style: const TextStyle(
                    color: AppColors.accentSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _MapError extends StatelessWidget {
  const _MapError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public_off_rounded, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
