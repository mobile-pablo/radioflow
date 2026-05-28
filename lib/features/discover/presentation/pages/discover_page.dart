import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_earth_globe/sphere_style.dart';
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

class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  bool _showGlobe = false;
  bool _globePopulated = false;

  late final FlutterEarthGlobeController _globe = FlutterEarthGlobeController(
    isRotating: true,
    rotationSpeed: 0.05,
    showAtmosphere: true,
    atmosphereColor: AppColors.accent,
    atmosphereThickness: 0.04,
    atmosphereOpacity: 0.25,
    sphereStyle: const SphereStyle(
      shadowColor: AppColors.accent,
      shadowBlurSigma: 24,
      gradientOverlay: RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [AppColors.surfaceHi, AppColors.ink],
        stops: [0, 1],
      ),
    ),
  );

  void _populateGlobe(List<Station> stations) {
    if (_globePopulated) return;
    _globePopulated = true;
    final playerBloc = context.read<PlayerBloc>();
    for (final station in stations.take(250)) {
      final geo = station.geo;
      if (geo == null) continue;
      _globe.addPoint(
        Point(
          id: station.uuid,
          coordinates: GlobeCoordinates(geo.latitude, geo.longitude),
          style: const PointStyle(color: AppColors.accent, size: 4),
          onTap: () => playerBloc.add(PlayStationRequested(station)),
        ),
      );
    }
  }

  void _onClusterTap(StationCluster cluster) {
    if (cluster.isSingle) {
      context.read<PlayerBloc>().add(PlayStationRequested(cluster.primary));
    } else {
      ClusterSheet.show(context, cluster);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listener: (context, state) {
        if (state.status == MapStatus.ready) _populateGlobe(state.stations);
      },
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(
              child: _showGlobe ? _buildGlobe() : _buildMap(context, state),
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
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _ViewToggle(
                    showGlobe: _showGlobe,
                    onToggle: () => setState(() => _showGlobe = !_showGlobe),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlobe() {
    return ColoredBox(
      color: AppColors.ink,
      child: Center(child: FlutterEarthGlobe(controller: _globe, radius: 150)),
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
                child: _ClusterMarker(
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

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.showGlobe, required this.onToggle});

  final bool showGlobe;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.85),
      shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
      child: IconButton(
        onPressed: onToggle,
        icon: Icon(showGlobe ? Icons.map_rounded : Icons.public_rounded),
        tooltip: showGlobe ? 'Map view' : 'Globe view',
      ),
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
