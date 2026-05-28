import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../bloc/map_cubit.dart';
import '../../../../shared/widgets/share_sheet.dart';
import '../widgets/map3d_view.dart';
import '../widgets/station_list_sheet.dart';

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
  Station? _focusStation;
  final ValueNotifier<bool> _locked = ValueNotifier(false);
  final ValueNotifier<Station?> _tuned = ValueNotifier(null);

  @override
  void dispose() {
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
    if (station.geo != null) setState(() => _focusStation = station);
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

  Future<void> _onLocate() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final stations = context.read<MapCubit>().state.stations;
    void notify(String message) =>
        messenger.showSnackBar(SnackBar(content: Text(message)));

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      notify(l10n.locationDenied);
      return;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      notify(l10n.locationUnavailable);
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      final cosLat = math.cos(position.latitude * math.pi / 180);
      Station? nearest;
      double best = double.infinity;
      for (final station in stations) {
        final geo = station.geo;
        if (geo == null) continue;
        final dLat = geo.latitude - position.latitude;
        final dLng = (geo.longitude - position.longitude) * cosLat;
        final dist = dLat * dLat + dLng * dLng;
        if (dist < best) {
          best = dist;
          nearest = station;
        }
      }
      if (!mounted) return;
      if (nearest != null) {
        _focusOn(nearest);
      } else {
        notify(l10n.locationUnavailable);
      }
    } on Object {
      notify(l10n.locationUnavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: _locked,
                builder: (context, locked, _) => Map3dView(
                  stations: state.stations,
                  onPlay: _play,
                  onCenterStation: _onCenterStation,
                  locked: locked,
                  focus: _focusStation,
                ),
              ),
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
                  onLocate: _onLocate,
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
          ],
        );
      },
    );
  }
}

class _RightActions extends StatelessWidget {
  const _RightActions({
    required this.locked,
    required this.onShare,
    required this.onLocate,
    required this.onLock,
  });

  final bool locked;
  final VoidCallback onShare;
  final VoidCallback onLocate;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            right: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GlassButton(icon: Icons.ios_share_rounded, onTap: onShare),
              const SizedBox(height: AppSpacing.md),
              _GlassButton(icon: Icons.my_location_rounded, onTap: onLocate),
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
                border: Border.all(
                  color: color.withValues(alpha: 0.7),
                  width: 2,
                ),
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
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  tuned!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.accent),
                ),
              ),
          ],
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
      child: BlocBuilder<PlayerBloc, PlayerState>(
        buildWhen: (a, b) => a.station != b.station,
        builder: (context, player) {
          final station = player.station;
          if (station == null) return const SizedBox.shrink();
          final place = (station.stateRegion?.isNotEmpty ?? false)
              ? station.stateRegion!
              : station.country;
          final flag = station.countryCode.isEmpty
              ? ''
              : '${Country.flagEmoji(station.countryCode)} ';
          final all = context.read<MapCubit>().state.stations;
          final count = (station.stateRegion?.isNotEmpty ?? false)
              ? all.where((s) => s.stateRegion == station.stateRegion).length
              : all.where((s) => s.country == station.country).length;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                StationListSheet.show(context, station: station, stations: all),
            child: Container(
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
                    child: Text(
                      count > 0 ? '$count' : station.initials,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
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
                          Text(
                            '$flag${station.country}',
                            style: textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Text(_localTime(station), style: textTheme.bodyMedium),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
