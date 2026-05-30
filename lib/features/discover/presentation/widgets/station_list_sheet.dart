import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../app/di.dart';
import '../../../favorites/widgets/favorite_button.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../../shared/city_name_service.dart';

class StationListSheet extends StatelessWidget {
  const StationListSheet({
    super.key,
    required this.station,
    required this.stations,
  });

  final Station station;
  final List<Station> stations;

  static Future<void> show(
    BuildContext context, {
    required Station station,
    required List<Station> stations,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StationListSheet(station: station, stations: stations),
    );
  }

  bool _samePlace(Station s) => (station.stateRegion?.isNotEmpty ?? false)
      ? s.stateRegion == station.stateRegion
      : s.country == station.country;

  String _place() => (station.stateRegion?.isNotEmpty ?? false)
      ? station.stateRegion!
      : station.country;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final inPlace = stations.where(_samePlace).take(50).toList();
    final geo = station.geo;
    final nearby = <Station>[];
    if (geo != null) {
      final others =
          stations.where((s) => s.geo != null && !_samePlace(s)).toList()
            ..sort(
              (a, b) =>
                  _dist(a.geo!, geo).compareTo(_dist(b.geo!, geo)),
            );
      nearby.addAll(others.take(12));
    }
    final place = _place();
    final flag = station.countryCode.isEmpty
        ? ''
        : '${Country.flagEmoji(station.countryCode)} ';

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, controller) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusSheet),
            ),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lineStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${inPlace.length}',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String?>(
                            future: getIt<CityNameService>().cityFor(station),
                            builder: (context, snapshot) {
                              final city =
                                  (snapshot.data?.isNotEmpty ?? false)
                                  ? snapshot.data!
                                  : place;
                              return Text(
                                city,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.headlineSmall,
                              );
                            },
                          ),
                          Text(
                            '$flag${station.country}',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (inPlace.isNotEmpty) ...[
                _SectionHeader(title: l10n.stationsIn(place)),
                for (final s in inPlace)
                  _StationRow(station: s, queue: inPlace),
              ],
              if (nearby.isNotEmpty) ...[
                _SectionHeader(title: l10n.nearbyStations),
                for (final s in nearby) _StationRow(station: s, queue: nearby),
              ],
              SizedBox(
                height: AppSpacing.xl + MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        );
      },
    );
  }
}

double _dist(GeoPoint a, GeoPoint b) {
  final dLat = a.latitude - b.latitude;
  final dLng = (a.longitude - b.longitude) *
      math.cos(b.latitude * math.pi / 180);
  return dLat * dLat + dLng * dLng;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({required this.station, required this.queue});

  final Station station;
  final List<Station> queue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final city = (station.stateRegion?.isNotEmpty ?? false)
        ? station.stateRegion!
        : station.country;
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (a, b) => a.station != b.station,
      builder: (context, player) {
        final active = player.station?.uuid == station.uuid;
        return InkWell(
          onTap: () {
            context.read<PlayerBloc>().add(
              PlayStationRequested(station, queue: queue),
            );
            Navigator.of(context).pop();
          },
          child: Container(
            color: active
                ? AppColors.accent.withValues(alpha: 0.1)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: active ? AppColors.accent : null,
                        ),
                      ),
                      if (city.isNotEmpty)
                        Text(city, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                FavoriteButton(station: station, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }
}
