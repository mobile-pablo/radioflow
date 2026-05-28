import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/station_artwork.dart';
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
        return Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: () => NowPlayingSheet.show(context),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    StationArtwork(station: station, size: 40, radius: 10),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            station.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            state.isBuffering
                                ? 'Buffering…'
                                : (station.country.isEmpty
                                      ? 'On air'
                                      : station.country),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
