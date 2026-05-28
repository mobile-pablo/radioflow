import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:radioflow/l10n/app_localizations.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  static const String path = '/discover';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RfLogo(size: 72),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppLocalizations.of(context).navDiscover,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
