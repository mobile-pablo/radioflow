import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/station_artwork.dart';
import '../bloc/player_bloc.dart';
import 'play_pause_button.dart';

class NowPlayingSheet extends StatelessWidget {
  const NowPlayingSheet({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) =>
          BlocProvider.value(value: bloc, child: const NowPlayingSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final station = state.station;
        if (station == null) return const SizedBox.shrink();
        final location = [
          station.stateRegion,
          station.country,
        ].where((e) => e != null && e.isNotEmpty).join(' · ');
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NOW PLAYING', style: textTheme.labelSmall),
                const SizedBox(height: AppSpacing.lg),
                _ArtCard(station: station, playing: state.isPlaying),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  station.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall,
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(location, style: textTheme.bodySmall),
                ],
                const SizedBox(height: AppSpacing.lg),
                _Tags(station: station),
                const SizedBox(height: AppSpacing.xl),
                _VolumeRow(volume: state.volume),
                const SizedBox(height: AppSpacing.xl),
                const PlayPauseButton(size: 76, filled: true),
                if (state.status == PlaybackStatus.error) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    state.errorMessage ?? 'Station unavailable.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArtCard extends StatelessWidget {
  const _ArtCard({required this.station, required this.playing});

  final Station station;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: playing ? 0.18 : 0),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          StationArtwork(
            station: station,
            size: 220,
            radius: AppSpacing.radiusCard,
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            height: 28,
            child: IgnorePointer(
              child: RfEqualizer(playing: playing, barCount: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (station.primaryTag.isNotEmpty) station.primaryTag,
      if ((station.bitrate ?? 0) > 0) '${station.bitrate} kbps',
      if (station.codec != null && station.codec!.isNotEmpty)
        station.codec!.toUpperCase(),
    ];
    if (labels.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: labels.map((label) => _Pill(label: label)).toList(),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({required this.volume});

  final double volume;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.volume_down_rounded),
          onPressed: () =>
              context.read<PlayerBloc>().add(const VolumeNudged(up: false)),
        ),
        Expanded(
          child: Slider(
            value: volume,
            onChanged: (value) =>
                context.read<PlayerBloc>().add(VolumeChanged(value)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up_rounded),
          onPressed: () =>
              context.read<PlayerBloc>().add(const VolumeNudged(up: true)),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${(volume * 100).round()}',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
