import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../bloc/player_bloc.dart';

class PlaybackErrorBanner extends StatefulWidget {
  const PlaybackErrorBanner({super.key});

  @override
  State<PlaybackErrorBanner> createState() => _PlaybackErrorBannerState();
}

class _PlaybackErrorBannerState extends State<PlaybackErrorBanner> {
  bool _show = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _trigger() {
    setState(() => _show = true);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == PlaybackStatus.error,
      listener: (context, state) => _trigger(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _show
            ? Container(
                key: const ValueKey('err'),
                width: double.infinity,
                color: const Color(0xFF4A1416),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).stationUnavailable,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}
