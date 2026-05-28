import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../bloc/map_cubit.dart';
import '../../bloc/station_cluster.dart';
import '../widgets/cluster_sheet.dart';
import '../widgets/rotating_globe.dart';

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

class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  bool _showGlobe = false;

  void _onClusterTap(StationCluster cluster) {
    if (cluster.isSingle) {
      context.read<PlayerBloc>().add(PlayStationRequested(cluster.primary));
    } else {
      ClusterSheet.show(context, cluster);
    }
  }

  void _onRandom() {
    final station = context.read<MapCubit>().randomStation();
    if (station != null) {
      context.read<PlayerBloc>().add(PlayStationRequested(station));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(
              child: _showGlobe
                  ? RotatingGlobe(
                      clusters: state.globeClusters,
                      onTapCluster: _onClusterTap,
                    )
                  : _buildMap(context, state),
            ),
            if (state.status == MapStatus.loading)
              const ColoredBox(
                color: AppColors.ink,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state.status == MapStatus.failure)
              _MapError(onRetry: () => context.read<MapCubit>().load()),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RoundButton(
                        icon: Icons.settings_outlined,
                        tooltip: l10n.settings,
                        onTap: () => context.push(SettingsPage.path),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _RoundButton(
                        icon: _showGlobe
                            ? Icons.map_rounded
                            : Icons.public_rounded,
                        tooltip: _showGlobe ? l10n.mapView : l10n.globeView,
                        onTap: () => setState(() => _showGlobe = !_showGlobe),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _RoundButton(
                        icon: Icons.casino_rounded,
                        tooltip: l10n.surprise,
                        onTap: _onRandom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMap(BuildContext context, MapState state) {
    return FlutterMap(
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
                child: _MapDot(
                  cluster: cluster,
                  onTap: () => _onClusterTap(cluster),
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
    );
  }
}

class _MapDot extends StatelessWidget {
  const _MapDot({required this.cluster, required this.onTap});

  final StationCluster cluster;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = cluster.markerDiameter;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cluster.isSingle
                ? AppColors.accent
                : AppColors.accent.withValues(alpha: 0.3),
            border: Border.all(color: AppColors.accent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.85),
      shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
      child: IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onTap),
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
