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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cluster.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${cluster.count}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
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
