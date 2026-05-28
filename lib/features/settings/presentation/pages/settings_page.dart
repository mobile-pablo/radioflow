import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

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
        children: [
          _SectionLabel(l10n.language),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              final selection = state.languageSelection;
              return Column(
                children: [
                  _LanguageTile(
                    label: l10n.languageSystem,
                    value: 'system',
                    selected: selection,
                    onTap: () =>
                        context.read<SettingsCubit>().setLanguage(null),
                  ),
                  _LanguageTile(
                    label: 'English',
                    value: 'en',
                    selected: selection,
                    onTap: () =>
                        context.read<SettingsCubit>().setLanguage('en'),
                  ),
                  _LanguageTile(
                    label: 'Español',
                    value: 'es',
                    selected: selection,
                    onTap: () =>
                        context.read<SettingsCubit>().setLanguage('es'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.about),
          ListTile(
            leading: const RfLogo(size: 32),
            title: const Text('RadioFlow'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.radio_outlined),
            title: Text(l10n.aboutData),
          ),
          ListTile(
            leading: const Icon(Icons.public_outlined),
            title: Text(l10n.aboutMap),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.accent)
          : null,
      onTap: onTap,
    );
  }
}
