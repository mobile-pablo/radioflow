import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../bloc/map_cubit.dart';

const List<String> _genres = [
  'Pop',
  'Rock',
  'Jazz',
  'Classical',
  'Electronic',
  'House',
  'Hip-Hop',
  'Indie',
  'Talk',
  'News',
  'World',
  'Latino',
  'Dance',
  'Metal',
];

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<MapCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => BlocProvider<MapCubit>.value(
        value: cubit,
        child: const FilterSheet(),
      ),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Set<String> _genresSelected;
  late String? _region;
  late int _minBitrate;

  static const List<int> _bitrates = [0, 96, 128, 192, 320];

  @override
  void initState() {
    super.initState();
    final state = context.read<MapCubit>().state;
    _genresSelected = {...state.genres};
    _region = state.region;
    _minBitrate = state.minBitrate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final regions = <(String?, String)>[
      (null, l10n.regionWorldwide),
      ('europe', l10n.regionEurope),
      ('north_america', l10n.regionNorthAmerica),
      ('south_america', l10n.regionSouthAmerica),
      ('asia', l10n.regionAsia),
      ('africa', l10n.regionAfrica),
    ];
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      _genresSelected = {};
                      _region = null;
                      _minBitrate = 0;
                    }),
                    child: Text(l10n.reset),
                  ),
                  Expanded(
                    child: Text(
                      l10n.filters,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  Text(
                    l10n.filterGenre.toUpperCase(),
                    style: textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final genre in _genres)
                        _Chip(
                          label: genre,
                          selected: _genresSelected.contains(genre),
                          onTap: () => setState(() {
                            if (!_genresSelected.add(genre)) {
                              _genresSelected.remove(genre);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.filterRegion.toUpperCase(),
                    style: textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final (key, label) in regions)
                        _Chip(
                          label: label,
                          selected: _region == key,
                          onTap: () => setState(() => _region = key),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.filterBitrate.toUpperCase(),
                    style: textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        for (final bitrate in _bitrates)
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _minBitrate = bitrate),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: _minBitrate == bitrate
                                      ? AppColors.accent.withValues(alpha: 0.12)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _minBitrate == bitrate
                                        ? AppColors.accent.withValues(
                                            alpha: 0.3,
                                          )
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  bitrate == 0
                                      ? l10n.bitrateAny
                                      : '${bitrate}k+',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _minBitrate == bitrate
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<MapCubit>().applyFilters(
                      genres: _genresSelected,
                      region: _region,
                      minBitrate: _minBitrate,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.apply),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.35)
                : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
