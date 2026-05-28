import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../bloc/player_bloc.dart';

class SleepTimerPage extends StatelessWidget {
  const SleepTimerPage({super.key});

  static const List<int> _options = [0, 5, 10, 15, 30, 45, 60, 120];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider.value(
      value: getIt<PlayerBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.sleepTagline.toUpperCase(), style: textTheme.labelSmall),
              Text(l10n.sleepTimer, style: textTheme.titleLarge),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<PlayerBloc, PlayerState>(
            buildWhen: (a, b) => a.sleepMinutes != b.sleepMinutes,
            builder: (context, state) {
              final active = state.sleepMinutes;
              return ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                if (active != null) _Hero(minutes: active),
                if (active != null) const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.sleepChooseDuration.toUpperCase(),
                  style: textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(color: AppColors.line),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < _options.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _OptionRow(
                          minutes: _options[i],
                          selected: (active ?? 0) == _options[i],
                          onTap: () => context.read<PlayerBloc>().add(
                            SleepTimerSet(_options[i] == 0 ? null : _options[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.accent.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.bedtime_rounded, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              l10n.sleepRemaining(minutes),
              style: textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final label = minutes == 0 ? l10n.sleepOff : l10n.sleepMinutes(minutes);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? AppColors.accent : AppColors.textFaint,
            ),
            const SizedBox(width: AppSpacing.lg),
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                color: selected ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
