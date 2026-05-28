import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/station_tile.dart';
import '../../../favorites/widgets/favorite_button.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../bloc/station_cluster.dart';

class ClusterSheet extends StatelessWidget {
  const ClusterSheet({super.key, required this.cluster});

  final StationCluster cluster;

  static Future<void> show(BuildContext context, StationCluster cluster) {
    final playerBloc = context.read<PlayerBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => BlocProvider<PlayerBloc>.value(
        value: playerBloc,
        child: ClusterSheet(cluster: cluster),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
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
              child: _SheetHeader(cluster: cluster),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cluster.stations.length,
                itemBuilder: (context, index) {
                  final station = cluster.stations[index];
                  return StationTile(
                    station: station,
                    trailing: FavoriteButton(station: station, size: 22),
                    onTap: () {
                      context.read<PlayerBloc>().add(
                        PlayStationRequested(station),
                      );
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.cluster});

  final StationCluster cluster;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final languageCode = Localizations.localeOf(context).languageCode;
    final station = cluster.primary;
    final flag = Country.flagEmoji(station.countryCode);
    final country = Country.localizedName(
      alpha2: station.countryCode,
      fallback: station.country,
      languageCode: languageCode,
    );
    final region = station.stateRegion;
    final hasRegion = region != null && region.isNotEmpty;
    return Row(
      children: [
        if (flag.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Text(flag, style: const TextStyle(fontSize: 26)),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasRegion ? region : country,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge,
              ),
              if (hasRegion)
                Text(
                  country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
