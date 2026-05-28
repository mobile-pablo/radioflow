import 'dart:async';

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../../../shared/widgets/skeleton_list.dart';
import '../../../../shared/widgets/station_tile.dart';
import '../../../favorites/widgets/favorite_button.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../../stations/bloc/stations_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static const String path = '/search';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StationsBloc>(
      create: (_) => StationsBloc(getIt<StationRepository>()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final query = value.trim();
      if (query.isEmpty) return;
      context.read<StationsBloc>().add(StationsSearchChanged(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSearch)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<StationsBloc, StationsState>(
              builder: (context, state) {
                if (state.status == StationsStatus.loading) {
                  return const SkeletonList();
                }
                if (state.stations.isEmpty) {
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
                      itemCount: state.stations.length,
                      itemBuilder: (context, index) {
                        final station = state.stations[index];
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
            ),
          ),
        ],
      ),
    );
  }
}
