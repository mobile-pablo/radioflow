import 'dart:async';
import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../bloc/map_cubit.dart';
import '../../bloc/station_cluster.dart';
import '../widgets/cluster_sheet.dart';
import '../../../../shared/widgets/share_sheet.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/map3d_view.dart';
import '../widgets/station_search_delegate.dart';

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

class _DiscoverViewState extends State<_DiscoverView>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _flyController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _showGlobe = true;
  Station? _focusStation;
  Timer? _tuneDebounce;
  final ValueNotifier<bool> _locked = ValueNotifier(false);
  final ValueNotifier<Station?> _tuned = ValueNotifier(null);

  @override
  void dispose() {
    _tuneDebounce?.cancel();
    _flyController.dispose();
    _locked.dispose();
    _tuned.dispose();
    super.dispose();
  }

  void _play(Station station) => context.read<PlayerBloc>().add(
    PlayStationRequested(
      station,
      queue: context.read<MapCubit>().state.stations,
    ),
  );

  void _focusOn(Station station) {
    _play(station);
    final geo = station.geo;
    if (geo == null) return;
    if (_showGlobe) {
      setState(() => _focusStation = station);
    } else {
      _flyTo(LatLng(geo.latitude, geo.longitude));
    }
  }

  void _onClusterTap(StationCluster cluster) {
    if (cluster.isSingle) {
      _play(cluster.primary);
    } else {
      ClusterSheet.show(context, cluster);
    }
  }

  void _onRandom() {
    final station = context.read<MapCubit>().randomStation();
    if (station != null) _focusOn(station);
  }

  void _scheduleAutoTune(LatLng center, double zoom) {
    if (_locked.value) return;
    _tuneDebounce?.cancel();
    _tuneDebounce = Timer(
      const Duration(milliseconds: 550),
      () => _autoTune(center, zoom),
    );
  }

  void _openShare() {
    final station = context.read<PlayerBloc>().state.station;
    ShareSheet.show(context, station);
  }

  void _onCenterStation(Station? station) {
    if (_locked.value) return;
    if (station == null) {
      _tuned.value = null;
      return;
    }
    _tuned.value = station;
    final playing = context.read<PlayerBloc>().state.station;
    if (playing?.uuid != station.uuid) _play(station);
  }

  void _autoTune(LatLng center, double zoom) {
    if (!mounted) return;
    final stations = context.read<MapCubit>().state.stations;
    final threshold = 22 / math.pow(2, zoom);
    Station? nearest;
    double best = double.infinity;
    for (final station in stations) {
      final geo = station.geo;
      if (geo == null) continue;
      final dLat = geo.latitude - center.latitude;
      final dLng = (geo.longitude - center.longitude) *
          math.cos(center.latitude * math.pi / 180);
      final dist = dLat * dLat + dLng * dLng;
      if (dist < best) {
        best = dist;
        nearest = station;
      }
    }
    _onCenterStation(
      nearest != null && best <= threshold * threshold ? nearest : null,
    );
  }

  Future<void> _openSearch() async {
    final station = await showSearch<Station?>(
      context: context,
      delegate: StationSearchDelegate(
        getIt<StationRepository>(),
        hint: AppLocalizations.of(context).searchHint,
      ),
    );
    if (station == null || !mounted) return;
    _focusOn(station);
  }

  void _flyTo(LatLng destination, {double destinationZoom = 6}) {
    if (!destination.latitude.isFinite || !destination.longitude.isFinite) {
      return;
    }
    final camera = _mapController.camera;
    final startCenter = camera.center;
    final startZoom = camera.zoom;
    final curve = CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeInOutCubic,
    );
    void tick() {
      final t = curve.value;
      final lat =
          startCenter.latitude +
          (destination.latitude - startCenter.latitude) * t;
      final lng =
          startCenter.longitude +
          (destination.longitude - startCenter.longitude) * t;
      if (!lat.isFinite || !lng.isFinite) return;
      _mapController.move(
        LatLng(lat.clamp(-85.0, 85.0), lng),
        startZoom + (destinationZoom - startZoom) * t,
      );
    }

    curve.addListener(tick);
    _flyController
      ..reset()
      ..forward().whenComplete(() => curve.removeListener(tick));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(
              child: _showGlobe
                  ? ValueListenableBuilder<bool>(
                      valueListenable: _locked,
                      builder: (context, locked, _) => Map3dView(
                        stations: state.stations,
                        onPlay: _play,
                        onCenterStation: _onCenterStation,
                        locked: locked,
                        focus: _focusStation,
                      ),
                    )
                  : _buildMap(context, state),
            ),
            if (state.status == MapStatus.ready) ...[
              ValueListenableBuilder<bool>(
                valueListenable: _locked,
                builder: (context, locked, _) =>
                    ValueListenableBuilder<Station?>(
                      valueListenable: _tuned,
                      builder: (context, tuned, _) =>
                          _Crosshair(tuned: tuned, locked: locked),
                    ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _locked,
                builder: (context, locked, _) => _RightActions(
                  locked: locked,
                  onShare: _openShare,
                  onLock: () => _locked.value = !locked,
                ),
              ),
              const _CityBanner(),
            ],
            if (state.status == MapStatus.loading)
              const ColoredBox(
                color: AppColors.ink,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state.status == MapStatus.failure)
              _MapError(onRetry: () => context.read<MapCubit>().load()),
            _TopOverlay(
              showGlobe: _showGlobe,
              hasFilters: state.hasFilters,
              onToggleGlobe: () => setState(() => _showGlobe = !_showGlobe),
              onFilters: () => FilterSheet.show(context),
              onSearch: _openSearch,
              onRandom: _onRandom,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMap(BuildContext context, MapState state) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(20, 0),
        initialZoom: 2.5,
        minZoom: 1.5,
        maxZoom: 12,
        backgroundColor: AppColors.ink,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onPositionChanged: (camera, hasGesture) {
          context.read<MapCubit>().onZoomChanged(camera.zoom);
          if (hasGesture) _scheduleAutoTune(camera.center, camera.zoom);
        },
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

class _TopOverlay extends StatelessWidget {
  const _TopOverlay({
    required this.showGlobe,
    required this.hasFilters,
    required this.onToggleGlobe,
    required this.onFilters,
    required this.onSearch,
    required this.onRandom,
  });

  final bool showGlobe;
  final bool hasFilters;
  final VoidCallback onToggleGlobe;
  final VoidCallback onFilters;
  final VoidCallback onSearch;
  final VoidCallback onRandom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BlocBuilder<PlayerBloc, PlayerState>(
                    buildWhen: (a, b) => a.station != b.station,
                    builder: (context, player) {
                      final country = player.station?.country;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.nowExploring.toUpperCase(),
                            style: textTheme.labelSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            country == null || country.isEmpty
                                ? l10n.theWorld
                                : country,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineSmall,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _GlassButton(
                  icon: Icons.tune_rounded,
                  active: hasFilters,
                  onTap: onFilters,
                ),
                const SizedBox(width: AppSpacing.sm),
                _GlassButton(
                  icon: showGlobe ? Icons.map_rounded : Icons.public_rounded,
                  onTap: onToggleGlobe,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SearchPill(
              hint: l10n.searchHint,
              onTap: onSearch,
              onRandom: onRandom,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({
    required this.hint,
    required this.onTap,
    required this.onRandom,
  });

  final String hint;
  final VoidCallback onTap;
  final VoidCallback onRandom;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textFaint),
              ),
            ),
            GestureDetector(
              onTap: onRandom,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  Icons.casino_rounded,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.85),
      shape: CircleBorder(
        side: BorderSide(color: active ? AppColors.accent : AppColors.line),
      ),
      child: IconButton(
        icon: Icon(icon, color: active ? AppColors.accent : null),
        onPressed: onTap,
      ),
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

class _CityBanner extends StatelessWidget {
  const _CityBanner();

  String _localTime(Station station) {
    final lon = station.geo?.longitude;
    if (lon == null) return '';
    final offset = (lon / 15).round();
    final local = DateTime.now().toUtc().add(Duration(hours: offset));
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: BlocBuilder<PlayerBloc, PlayerState>(
          buildWhen: (a, b) => a.station != b.station,
          builder: (context, player) {
            final station = player.station;
            if (station == null) return const SizedBox.shrink();
            final place = (station.stateRegion?.isNotEmpty ?? false)
                ? station.stateRegion!
                : station.name;
            final flag = station.countryCode.isEmpty
                ? null
                : Country.flagEmoji(station.countryCode);
            return Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x8C000000)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                    ),
                    child: flag != null
                        ? Text(flag, style: const TextStyle(fontSize: 20))
                        : Text(
                            station.initials,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall,
                        ),
                        if (station.country.isNotEmpty)
                          Text(station.country, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(_localTime(station), style: textTheme.bodyMedium),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RightActions extends StatelessWidget {
  const _RightActions({
    required this.locked,
    required this.onShare,
    required this.onLock,
  });

  final bool locked;
  final VoidCallback onShare;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GlassButton(icon: Icons.ios_share_rounded, onTap: onShare),
              const SizedBox(height: AppSpacing.md),
              _GlassButton(
                icon: locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                active: locked,
                onTap: onLock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Crosshair extends StatelessWidget {
  const _Crosshair({required this.tuned, required this.locked});

  final Station? tuned;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final active = tuned != null;
    final color = locked
        ? AppColors.accentBlue
        : (active ? AppColors.accent : AppColors.textMuted);
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: active ? 0.1 : 0.04),
                border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (active)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  tuned!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
