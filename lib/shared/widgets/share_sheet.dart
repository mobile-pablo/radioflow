import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radioflow/l10n/app_localizations.dart';

class ShareSheet extends StatelessWidget {
  const ShareSheet({super.key, this.station});

  final Station? station;

  static Future<void> show(BuildContext context, Station? station) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareSheet(station: station),
    );
  }

  void _copy(BuildContext context, String text) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: text));
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final stationLink = station == null
        ? null
        : '${station!.name} · ${station!.homepage ?? station!.streamUrl}';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  if (stationLink != null)
                    _Option(
                      icon: Icons.radio_rounded,
                      label: l10n.shareStation,
                      onTap: () => _copy(context, stationLink),
                    ),
                  if (stationLink != null) const Divider(height: 1),
                  _Option(
                    icon: Icons.public_rounded,
                    label: l10n.shareApp,
                    onTap: () => _copy(
                      context,
                      'RadioFlow · ${l10n.settingsTagline}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  l10n.close,
                  style: textTheme.titleMedium?.copyWith(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
