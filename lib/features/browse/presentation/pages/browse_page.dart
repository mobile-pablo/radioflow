import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../../../shared/widgets/station_tile.dart';
import '../../../favorites/widgets/favorite_button.dart';
import '../../../player/bloc/player_bloc.dart';

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

const List<(String, String)> _countries = [
  ('US', 'United States'),
  ('GB', 'United Kingdom'),
  ('ES', 'Spain'),
  ('FR', 'France'),
  ('DE', 'Germany'),
  ('BR', 'Brazil'),
  ('MX', 'Mexico'),
  ('AR', 'Argentina'),
  ('IT', 'Italy'),
  ('NL', 'Netherlands'),
  ('PL', 'Poland'),
  ('CA', 'Canada'),
  ('AU', 'Australia'),
  ('JP', 'Japan'),
  ('PT', 'Portugal'),
  ('CO', 'Colombia'),
  ('CL', 'Chile'),
  ('KR', 'South Korea'),
];

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  static const String path = '/browse';

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  bool _countriesView = false;
  String? _tag;
  String? _countryCode;

  Future<List<Station>>? _results;

  void _selectTag(String genre) {
    setState(() {
      _tag = genre;
      _countryCode = null;
      _results = getIt<StationRepository>().getStations(
        tag: genre.toLowerCase(),
        limit: 100,
      );
    });
  }

  void _selectCountry(String code) {
    setState(() {
      _countryCode = code;
      _tag = null;
      _results = getIt<StationRepository>().getStations(
        countryCode: code,
        limit: 100,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navBrowse)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: _Segmented(
              left: l10n.navCategories,
              right: l10n.navCountries,
              rightSelected: _countriesView,
              onSelect: (countries) =>
                  setState(() => _countriesView = countries),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: _countriesView
                  ? [
                      for (final (code, name) in _countries)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: _Chip(
                            label:
                                '${Country.flagEmoji(code)} '
                                '${Country.localizedName(alpha2: code, fallback: name, languageCode: languageCode)}',
                            selected: _countryCode == code,
                            onTap: () => _selectCountry(code),
                          ),
                        ),
                    ]
                  : [
                      for (final genre in _genres)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: _Chip(
                            label: genre,
                            selected: _tag == genre,
                            onTap: () => _selectTag(genre),
                          ),
                        ),
                    ],
            ),
          ),
          Expanded(child: _Results(future: _results)),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.future});

  final Future<List<Station>>? future;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (future == null) {
      return Center(
        child: Text(
          l10n.navBrowse,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return FutureBuilder<List<Station>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final stations = snapshot.data ?? const [];
        if (stations.isEmpty) {
          return Center(
            child: Text(
              l10n.stationsEmpty,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return BlocBuilder<PlayerBloc, PlayerState>(
          buildWhen: (a, b) => a.station != b.station,
          builder: (context, player) {
            final activeUuid = player.station?.uuid;
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 160),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return StationTile(
                  station: station,
                  active: station.uuid == activeUuid,
                  trailing: FavoriteButton(station: station, size: 22),
                  onTap: () => context.read<PlayerBloc>().add(
                    PlayStationRequested(station),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.left,
    required this.right,
    required this.rightSelected,
    required this.onSelect,
  });

  final String left;
  final String right;
  final bool rightSelected;
  final void Function(bool countries) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _segment(context, left, !rightSelected, () => onSelect(false)),
          _segment(context, right, rightSelected, () => onSelect(true)),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: selected ? AppColors.accent : Colors.transparent,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.ink : AppColors.textSecondary,
            ),
          ),
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
