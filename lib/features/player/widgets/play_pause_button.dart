import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/player_bloc.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, this.size = 44, this.filled = false});

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, state) {
        final iconColor = filled ? AppColors.ink : AppColors.textPrimary;
        final Widget child;
        if (state.isBuffering) {
          child = SizedBox.square(
            dimension: size * 0.42,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: filled ? AppColors.ink : AppColors.accent,
            ),
          );
        } else {
          child = Icon(
            state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: size * 0.56,
            color: iconColor,
          );
        }

        return Semantics(
          button: true,
          label: state.isPlaying ? 'Pause' : 'Play',
          child: GestureDetector(
            onTap: () =>
                context.read<PlayerBloc>().add(const PlayPauseToggled()),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.accent : Colors.transparent,
                border: filled ? null : Border.all(color: AppColors.lineStrong),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.45),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(child: child),
            ),
          ),
        );
      },
    );
  }
}
