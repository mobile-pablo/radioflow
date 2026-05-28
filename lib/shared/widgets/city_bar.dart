import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/di.dart';
import '../../features/discover/presentation/widgets/station_list_sheet.dart';
import '../../features/player/bloc/player_bloc.dart';
import '../city_name_service.dart';
import '../stations_holder.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.lineStrong,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class SwipeUpToOpen extends StatefulWidget {
  const SwipeUpToOpen({super.key, required this.onOpen, required this.child});

  final VoidCallback onOpen;
  final Widget child;

  @override
  State<SwipeUpToOpen> createState() => _SwipeUpToOpenState();
}

class _SwipeUpToOpenState extends State<SwipeUpToOpen> {
  double _dy = 0;
  bool _fired = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onOpen,
      onVerticalDragStart: (_) {
        _dy = 0;
        _fired = false;
      },
      onVerticalDragUpdate: (details) {
        _dy += details.primaryDelta ?? 0;
        if (!_fired && _dy < -24) {
          _fired = true;
          widget.onOpen();
        }
      },
      onVerticalDragEnd: (details) {
        if (!_fired && (details.primaryVelocity ?? 0) < 0) widget.onOpen();
      },
      child: widget.child,
    );
  }
}

class CityBar extends StatelessWidget {
  const CityBar({super.key});

  String _localTime(Station station) {
    final lon = station.geo?.longitude;
    if (lon == null) return '';
    final offset = (lon / 15).round();
    final local = DateTime.now().toUtc().add(Duration(hours: offset));
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (a, b) => a.station != b.station,
      builder: (context, player) {
        final station = player.station;
        if (station == null) return const SizedBox.shrink();
        final all = getIt<StationsHolder>().stations;
        final hasRegion = station.stateRegion?.isNotEmpty ?? false;
        final fallback = hasRegion ? station.stateRegion! : station.country;
        final count = all
            .where(
              (s) => hasRegion
                  ? s.stateRegion == station.stateRegion
                  : s.country == station.country,
            )
            .take(50)
            .length;
        final flag = station.countryCode.isEmpty
            ? ''
            : '${Country.flagEmoji(station.countryCode)} ';
        return SwipeUpToOpen(
          onOpen: () =>
              StationListSheet.show(context, station: station, stations: all),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceHi,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DragHandle(),
                const SizedBox(height: AppSpacing.sm),
                Row(
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
                        count > 0 ? '$count' : station.initials,
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
                                  : fallback;
                              return Text(
                                city,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleLarge,
                              );
                            },
                          ),
                          if (station.country.isNotEmpty)
                            Text(
                              '$flag${station.country}',
                              style: textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    Text(_localTime(station), style: textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
