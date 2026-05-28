import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../shared/widgets/station_artwork.dart';
import '../../favorites/widgets/favorite_button.dart';
import '../bloc/player_bloc.dart';
import 'now_playing_sheet.dart';
import 'play_pause_button.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (a, b) =>
          a.station != b.station ||
          a.status != b.status ||
          a.isActive != b.isActive,
      builder: (context, state) {
        final station = state.station;
        if (station == null || !state.isActive) {
          return const SizedBox.shrink();
        }
        final flag = Country.flagEmoji(station.countryCode);
        final subtitle = [
          if (flag.isNotEmpty) flag,
          if (station.country.isNotEmpty) station.country,
          if (station.primaryTag.isNotEmpty) station.primaryTag,
        ].join(' · ');
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lineStrong),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => NowPlayingSheet.show(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                child: Row(
                  children: [
                    StationArtwork(station: station, size: 40, radius: 12),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _PlayingDot(playing: state.isPlaying),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  station.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            state.isBuffering
                                ? AppLocalizations.of(context).buffering
                                : (state.track ?? subtitle),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    FavoriteButton(station: station, size: 20),
                    const PlayPauseButton(size: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayingDot extends StatelessWidget {
  const _PlayingDot({required this.playing});

  final bool playing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: playing ? AppColors.accent : AppColors.textFaint,
        boxShadow: playing
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.8),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}
