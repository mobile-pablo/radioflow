import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../bloc/player_bloc.dart';
import '../presentation/pages/equalizer_page.dart';
import '../presentation/pages/sleep_timer_page.dart';
import 'now_playing_sheet.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (a, b) =>
          a.station != b.station ||
          a.status != b.status ||
          a.track != b.track ||
          a.isActive != b.isActive,
      builder: (context, state) {
        final station = state.station;
        if (station == null || !state.isActive) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context);
        final flag = Country.flagEmoji(station.countryCode);
        final subtitle = [
          if (flag.isNotEmpty) flag,
          if (station.country.isNotEmpty) station.country,
        ].join(' · ');
        final textTheme = Theme.of(context).textTheme;
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xEB000000),
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => NowPlayingSheet.show(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          station.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                        Text(
                          state.isBuffering
                              ? l10n.buffering
                              : (state.track ?? subtitle),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                _IconBtn(
                  icon: Icons.tune_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EqualizerPage(),
                    ),
                  ),
                ),
                _IconBtn(
                  icon: Icons.schedule_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SleepTimerPage(),
                    ),
                  ),
                ),
                const _StopPlayButton(),
                _IconBtn(
                  icon: Icons.skip_next_rounded,
                  onTap: () =>
                      context.read<PlayerBloc>().add(const PlayNext()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 22, color: AppColors.textPrimary),
    );
  }
}

class _StopPlayButton extends StatelessWidget {
  const _StopPlayButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, state) {
        if (state.isBuffering) {
          return const SizedBox.square(
            dimension: 40,
            child: Center(
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.accent,
                ),
              ),
            ),
          );
        }
        return _IconBtn(
          icon: state.isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          onTap: () => context.read<PlayerBloc>().add(const PlayPauseToggled()),
        );
      },
    );
  }
}
