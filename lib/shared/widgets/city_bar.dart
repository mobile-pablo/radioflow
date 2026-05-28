import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/di.dart';
import '../../features/discover/presentation/widgets/station_list_sheet.dart';
import '../../features/player/bloc/player_bloc.dart';
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
        final place = hasRegion ? station.stateRegion! : station.name;
        final flag = station.countryCode.isEmpty
            ? ''
            : '${Country.flagEmoji(station.countryCode)} ';
        final count = hasRegion
            ? all.where((s) => s.stateRegion == station.stateRegion).length
            : all.where((s) => s.country == station.country).length;
        void open() =>
            StationListSheet.show(context, station: station, stations: all);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: open,
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < 0) open();
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
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
                          Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleLarge,
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
