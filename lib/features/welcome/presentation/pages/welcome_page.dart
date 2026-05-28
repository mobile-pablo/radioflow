import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:radioflow/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/di.dart';
import '../../../discover/presentation/pages/discover_page.dart';

const String kWelcomeSeenKey = 'welcome.seen';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const String path = '/welcome';

  Future<void> _start(BuildContext context) async {
    await getIt<SharedPreferences>().setBool(kWelcomeSeenKey, true);
    if (context.mounted) context.go(DiscoverPage.path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.9),
            radius: 1.1,
            colors: [Color(0xFF0C1A16), AppColors.ink],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const RfLogo(size: 36),
                    const SizedBox(width: AppSpacing.md),
                    Text('RadioFlow', style: textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                RichText(
                  text: TextSpan(
                    style: textTheme.displaySmall,
                    children: [
                      TextSpan(text: l10n.welcomeTitlePre),
                      TextSpan(
                        text: l10n.welcomeTitleHighlight,
                        style: const TextStyle(color: AppColors.accent),
                      ),
                      TextSpan(text: l10n.welcomeTitlePost),
                    ],
                  ),
                ),
                const Spacer(),
                _Feature(
                  icon: Icons.public_rounded,
                  title: l10n.welcomeTuneTitle,
                  body: l10n.welcomeTuneBody,
                ),
                const SizedBox(height: AppSpacing.xl),
                _Feature(
                  icon: Icons.radio_rounded,
                  title: l10n.welcomeFreeTitle,
                  body: l10n.welcomeFreeBody,
                ),
                const SizedBox(height: AppSpacing.xl),
                _Feature(
                  icon: Icons.favorite_rounded,
                  title: l10n.welcomeFavTitle,
                  body: l10n.welcomeFavBody,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _start(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(l10n.getStarted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.accent.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: AppColors.accent, size: 24),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(body, style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
