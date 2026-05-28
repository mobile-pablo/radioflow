import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../../../shared/stations_holder.dart';
import '../../../../shared/widgets/share_sheet.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../bloc/map_cubit.dart';
import '../widgets/map3d_view.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  static const String path = '/discover';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapCubit>(
      create: (_) =>
          MapCubit(getIt<StationRepository>(), getIt<StationsHolder>())..load(),
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
  String? _selfUuid;
  final ValueNotifier<bool> _locked = ValueNotifier(false);

  @override
  void dispose() {
    _locked.dispose();
    super.dispose();
  }

  void _play(Station station) {
    _selfUuid = station.uuid;
    context.read<PlayerBloc>().add(
      PlayStationRequested(
        station,
        queue: context.read<MapCubit>().state.stations,
      ),
    );
  }

  void _onExternalStation(Station station) {
    if (station.geo == null || station.uuid == _selfUuid) return;
    setState(() => _focusStation = station);
  }

  void _focusOn(Station station) {
    _play(station);
    if (station.geo != null) setState(() => _focusStation = station);
  }

  void _openShare() {
    final station = context.read<PlayerBloc>().state.station;
    ShareSheet.show(context, station);
  }

  void _onCenterStation(Station? station) {
    if (_locked.value || station == null) return;
    final playing = context.read<PlayerBloc>().state.station;
    if (playing?.uuid != station.uuid) _play(station);
  }

  void _onRandom() {
    final station = context.read<MapCubit>().randomStation();
    if (station != null) _focusOn(station);
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
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (a, b) => a.station?.uuid != b.station?.uuid,
      listener: (context, state) {
        final station = state.station;
        if (station != null) _onExternalStation(station);
      },
      child: BlocBuilder<MapCubit, MapState>(
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
                BlocBuilder<PlayerBloc, PlayerState>(
                  buildWhen: (a, b) => a.isBuffering != b.isBuffering,
                  builder: (context, player) =>
                      _Crosshair(loading: player.isBuffering),
                ),
              ValueListenableBuilder<bool>(
                valueListenable: _locked,
                builder: (context, locked, _) => _RightActions(
                  locked: locked,
                  onShare: _openShare,
                  onLocate: _onLocate,
                  onLock: () => _locked.value = !locked,
                  onRandom: _onRandom,
                ),
              ),
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
      ),
    );
  }
}

class _RightActions extends StatelessWidget {
  const _RightActions({
    required this.locked,
    required this.onShare,
    required this.onLocate,
    required this.onLock,
    required this.onRandom,
  });

  final bool locked;
  final VoidCallback onShare;
  final VoidCallback onLocate;
  final VoidCallback onLock;
  final VoidCallback onRandom;

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
              const SizedBox(height: AppSpacing.md),
              _GlassButton(icon: Icons.shuffle_rounded, onTap: onRandom),
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

class _Crosshair extends StatefulWidget {
  const _Crosshair({required this.loading});

  final bool loading;

  @override
  State<_Crosshair> createState() => _CrosshairState();
}

class _CrosshairState extends State<_Crosshair>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    if (widget.loading) _spin.repeat();
  }

  @override
  void didUpdateWidget(_Crosshair oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!widget.loading && _spin.isAnimating) {
      _spin
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = CustomPaint(
      size: const Size(74, 74),
      painter: _RingPainter(dashed: widget.loading),
      child: const Center(
        child: SizedBox(
          width: 6,
          height: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cream,
            ),
          ),
        ),
      ),
    );
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: 74,
          height: 74,
          child: widget.loading
              ? RotationTransition(turns: _spin, child: ring)
              : ring,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.dashed});

  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.cream.withValues(alpha: 0.85);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    if (!dashed) {
      canvas.drawCircle(center, radius, paint);
      return;
    }
    final rect = Rect.fromCircle(center: center, radius: radius);
    const dash = 0.32;
    const gap = 0.26;
    for (double a = -math.pi / 2; a < math.pi * 1.5; a += dash + gap) {
      canvas.drawArc(rect, a, dash, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.dashed != dashed;
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
