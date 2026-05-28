import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../favorites/bloc/favorites_cubit.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../../player/presentation/pages/equalizer_page.dart';
import '../../../player/presentation/pages/sleep_timer_page.dart';
import '../../../recents/recents_cubit.dart';
import '../../bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String path = '/settings';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          const _AccountCard(),
          _SettingsGroup(
            title: l10n.playback,
            children: [
              BlocBuilder<SettingsCubit, SettingsState>(
                buildWhen: (a, b) => a.highQuality != b.highQuality,
                builder: (context, state) => _SettingsToggle(
                  label: l10n.highQuality,
                  description: l10n.highQualityDesc,
                  value: state.highQuality,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().setHighQuality(value: v),
                ),
              ),
              _SettingsRow(
                label: l10n.equalizer,
                description: l10n.equalizerTagline,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EqualizerPage(),
                  ),
                ),
              ),
              const _SleepTimerRow(),
            ],
          ),
          _SettingsGroup(
            title: l10n.appearance,
            children: [
              BlocBuilder<SettingsCubit, SettingsState>(
                buildWhen: (a, b) => a.pureBlack != b.pureBlack,
                builder: (context, state) => _SettingsSegment(
                  label: l10n.theme,
                  selected: state.pureBlack ? 'pureBlack' : 'dark',
                  options: [
                    ('dark', l10n.themeDark),
                    ('pureBlack', l10n.themePureBlack),
                  ],
                  onSelected: (id) => context
                      .read<SettingsCubit>()
                      .setPureBlack(value: id == 'pureBlack'),
                ),
              ),
              const _LanguageRow(),
            ],
          ),
          _SettingsGroup(
            title: l10n.dataStorage,
            children: [
              BlocBuilder<SettingsCubit, SettingsState>(
                buildWhen: (a, b) => a.keepOffline != b.keepOffline,
                builder: (context, state) => _SettingsToggle(
                  label: l10n.keepOffline,
                  description: l10n.keepOfflineDesc,
                  value: state.keepOffline,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().setKeepOffline(value: v),
                ),
              ),
              _SettingsRow(
                label: l10n.clearRecents,
                trailing: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onTap: () => context.read<RecentsCubit>().clear(),
              ),
            ],
          ),
          _SettingsGroup(
            title: l10n.about,
            children: [
              _SettingsRow(
                label: l10n.dataSource,
                trailingText: 'Radio Browser',
              ),
              _SettingsRow(label: l10n.mapTiles, trailingText: 'OSM · CARTO'),
              _SettingsRow(label: l10n.version, trailingText: '1.0.0 (1)'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                const RfLogo(size: 28, glow: false),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'RadioFlow · ${l10n.settingsTagline}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, fav) {
        final countries = fav.favorites
            .map((s) => s.countryCode)
            .where((c) => c.isNotEmpty)
            .toSet()
            .length;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const RfLogo(size: 48),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsTagline.toUpperCase(),
                      style: textTheme.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text('RadioFlow', style: textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.stationCount(fav.favorites.length)} · $countries',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SleepTimerRow extends StatelessWidget {
  const _SleepTimerRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (a, b) => a.sleepMinutes != b.sleepMinutes,
      builder: (context, state) {
        final value = state.sleepMinutes == null
            ? l10n.sleepOff
            : l10n.sleepMinutes(state.sleepMinutes!);
        return _SettingsRow(
          label: l10n.sleepTimer,
          trailingText: value,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SleepTimerPage()),
          ),
        );
      },
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (a, b) => a.languageSelection != b.languageSelection,
      builder: (context, state) {
        final label = switch (state.languageSelection) {
          'en' => 'English',
          'es' => 'Español',
          _ => l10n.languageSystem,
        };
        return _SettingsRow(
          label: l10n.language,
          trailingText: label,
          onTap: () => _showPicker(context),
        );
      },
    );
  }

  void _showPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SettingsCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.languageSystem),
              onTap: () {
                cubit.setLanguage(null);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                cubit.setLanguage('en');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Español'),
              onTap: () {
                cubit.setLanguage('es');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpacing.sm),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: AppColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.description,
    this.trailing,
    this.trailingText,
    this.onTap,
  });

  final String label;
  final String? description;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.titleMedium),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(description!, style: textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (trailing != null)
              trailing!
            else if (trailingText != null)
              Text(trailingText!, style: textTheme.bodySmall)
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textFaint,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      label: label,
      description: description,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _SettingsSegment extends StatelessWidget {
  const _SettingsSegment({
    required this.label,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String selected;
  final List<(String, String)> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                for (final (id, optionLabel) in options)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSelected(id),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: selected == id
                              ? AppColors.accent.withValues(alpha: 0.12)
                              : Colors.transparent,
                          border: Border.all(
                            color: selected == id
                                ? AppColors.accent.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          optionLabel,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: selected == id
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
