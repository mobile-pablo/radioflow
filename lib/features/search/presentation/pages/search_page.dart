import 'dart:async';

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../../../shared/stations_holder.dart';
import '../../../../shared/widgets/skeleton_list.dart';
import '../../../../shared/widgets/station_tile.dart';
import '../../../favorites/widgets/favorite_button.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../../recents/recents_cubit.dart';
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
  late final Future<List<Station>> _recommended;
  bool _hasQuery = false;

  @override
  void initState() {
    super.initState();
    final cached = getIt<StationsHolder>().stations;
    _recommended = cached.isNotEmpty
        ? Future.value(cached.take(30).toList())
        : getIt<StationRepository>().getStations(limit: 20);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _hasQuery = value.trim().isNotEmpty);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final query = value.trim();
      if (query.length < 2) return;
      context.read<StationsBloc>().add(StationsSearchChanged(query));
    });
  }

  void _clearQuery() {
    _controller.clear();
    setState(() => _hasQuery = false);
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
                suffixIcon: _hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _clearQuery,
                      )
                    : null,
              ),
            ),
          ),
          Expanded(child: _hasQuery ? _results(l10n) : _discover(l10n)),
        ],
      ),
    );
  }

  Widget _results(AppLocalizations l10n) {
    return BlocBuilder<StationsBloc, StationsState>(
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
        return _StationListView(stations: state.stations);
      },
    );
  }

  Widget _discover(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 160),
      children: [
        BlocBuilder<RecentsCubit, RecentsState>(
          builder: (context, state) {
            if (state.recents.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: l10n.recentlyPlayed),
                _StationListView(stations: state.recents, shrinkWrap: true),
                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
        ),
        _SectionLabel(label: l10n.recommended),
        FutureBuilder<List<Station>>(
          future: _recommended,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SkeletonList(count: 6);
            }
            final stations = snapshot.data ?? const [];
            if (stations.isEmpty) return const SizedBox.shrink();
            return _StationListView(stations: stations, shrinkWrap: true);
          },
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _StationListView extends StatelessWidget {
  const _StationListView({required this.stations, this.shrinkWrap = false});

  final List<Station> stations;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (a, b) => a.station != b.station,
      builder: (context, player) {
        final activeUuid = player.station?.uuid;
        return ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          padding: shrinkWrap
              ? EdgeInsets.zero
              : const EdgeInsets.only(bottom: 160),
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            return StationTile(
              station: station,
              active: station.uuid == activeUuid,
              trailing: FavoriteButton(station: station, size: 22),
              onTap: () => context.read<PlayerBloc>().add(
                PlayStationRequested(station, queue: stations),
              ),
            );
          },
        );
      },
    );
  }
}
