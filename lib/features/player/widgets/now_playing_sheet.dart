import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/widgets/station_artwork.dart';
import '../../favorites/widgets/favorite_button.dart';
import '../bloc/player_bloc.dart';
import '../presentation/pages/sleep_timer_page.dart';
import 'play_pause_button.dart';

class NowPlayingSheet extends StatelessWidget {
  const NowPlayingSheet({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          BlocProvider.value(value: bloc, child: const NowPlayingSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusSheet),
            ),
          ),
          child: BlocBuilder<PlayerBloc, PlayerState>(
            builder: (context, state) {
              final station = state.station;
              if (station == null) return const SizedBox.shrink();
              return _Content(
                controller: scrollController,
                state: state,
                station: station,
              );
            },
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.controller,
    required this.state,
    required this.station,
  });

  final ScrollController controller;
  final PlayerState state;
  final Station station;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final location = [
      station.stateRegion,
      station.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
    final hasHomepage =
        station.homepage != null && station.homepage!.isNotEmpty;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      children: [
        Center(
          child: Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.lineStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StationArtwork(station: station, size: 64, radius: 14),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.country.isEmpty
                        ? l10n.onAir.toUpperCase()
                        : '${l10n.onAir.toUpperCase()} · ${station.country.toUpperCase()}',
                    style: textTheme.labelSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    station.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(location, style: textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            FavoriteButton(station: station, size: 24),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _TrackCard(track: state.track, playing: state.isPlaying),
        const SizedBox(height: AppSpacing.xl),
        const Center(child: PlayPauseButton(size: 76, filled: true)),
        const SizedBox(height: AppSpacing.lg),
        _VolumeRow(volume: state.volume),
        if (state.status == PlaybackStatus.error)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              l10n.stationUnavailable,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(height: 1),
        _SleepRow(minutes: state.sleepMinutes),
        if (hasHomepage)
          _ActionRow(
            icon: Icons.open_in_new_rounded,
            label: l10n.openHomepage,
            onTap: () => _openHomepage(station.homepage!),
          ),
      ],
    );
  }

  Future<void> _openHomepage(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.track, required this.playing});

  final String? track;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 28,
            child: RfEqualizer(playing: playing, barCount: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              track ?? (playing ? 'Live' : ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Text(label, style: textTheme.titleMedium)),
            if (value != null) Text(value!, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SleepRow extends StatelessWidget {
  const _SleepRow({required this.minutes});

  final int? minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = minutes == null ? l10n.sleepOff : l10n.sleepMinutes(minutes!);
    return _ActionRow(
      icon: Icons.bedtime_outlined,
      label: l10n.sleepTimer,
      value: value,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SleepTimerPage()),
      ),
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
      ],
    );
  }
}
