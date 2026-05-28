import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:radioflow/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/widgets/share_sheet.dart';
import '../../../shared/widgets/station_artwork.dart';
import '../../discover/presentation/pages/discover_page.dart';
import '../../favorites/widgets/favorite_button.dart';
import '../bloc/player_bloc.dart';
import '../presentation/pages/equalizer_page.dart';
import '../presentation/pages/sleep_timer_page.dart';

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
    final place = (station.stateRegion?.isNotEmpty ?? false)
        ? station.stateRegion!
        : station.country;
    final hasHomepage =
        station.homepage != null && station.homepage!.isNotEmpty;
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.sm,
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
                          place.isEmpty
                              ? l10n.onAir.toUpperCase()
                              : '${l10n.onAir.toUpperCase()} · ${place.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  _HeartButton(station: station),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _TrackCard(
                track: state.track,
                playing: state.isPlaying,
                onShare: () => ShareSheet.show(context, station),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1),
              _ActionRow(
                icon: Icons.ios_share_rounded,
                label: l10n.shareStation,
                onTap: () => ShareSheet.show(context, station),
              ),
              if (hasHomepage)
                _ActionRow(
                  icon: Icons.open_in_new_rounded,
                  label: l10n.visitWebsite,
                  onTap: () => _openHomepage(station.homepage!),
                ),
              _ActionRow(
                icon: Icons.public_rounded,
                label: l10n.showOnGlobe,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(DiscoverPage.path);
                },
              ),
              _ActionRow(
                icon: Icons.bedtime_outlined,
                label: l10n.sleepTimer,
                value: state.sleepMinutes == null
                    ? null
                    : l10n.sleepMinutes(state.sleepMinutes!),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SleepTimerPage(),
                  ),
                ),
              ),
              _ActionRow(
                icon: Icons.tune_rounded,
                label: l10n.equalizer,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EqualizerPage(),
                  ),
                ),
              ),
              if (state.status == PlaybackStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Text(
                    l10n.stationUnavailable,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _Transport(playing: state.isPlaying, buffering: state.isBuffering),
      ],
    );
  }

  Future<void> _openHomepage(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Center(child: FavoriteButton(station: station, size: 22)),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.track,
    required this.playing,
    required this.onShare,
  });

  final String? track;
  final bool playing;
  final VoidCallback onShare;

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
          IconButton(
            onPressed: onShare,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.ios_share_rounded,
              size: 20,
              color: AppColors.textSecondary,
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

class _Transport extends StatelessWidget {
  const _Transport({required this.playing, required this.buffering});

  final bool playing;
  final bool buffering;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: 30,
              onPressed: () => bloc.add(const PlayPrevious()),
              icon: const Icon(
                Icons.skip_previous_rounded,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => bloc.add(const PlayPauseToggled()),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cream,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cream.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: buffering
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: AppColors.ink,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 30,
                          color: AppColors.ink,
                        ),
                ),
              ),
            ),
            IconButton(
              iconSize: 30,
              onPressed: () => bloc.add(const PlayNext()),
              icon: const Icon(
                Icons.skip_next_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
