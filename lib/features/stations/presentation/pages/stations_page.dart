import 'dart:async';

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../shared/widgets/station_tile.dart';
import '../../../player/bloc/player_bloc.dart';
import '../../bloc/stations_bloc.dart';

class StationsPage extends StatelessWidget {
  const StationsPage({super.key});

  static const String path = '/stations';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StationsBloc>(
      create: (_) =>
          StationsBloc(getIt<StationRepository>())
            ..add(const StationsRequested()),
      child: const _StationsView(),
    );
  }
}

class _StationsView extends StatefulWidget {
  const _StationsView();

  @override
  State<_StationsView> createState() => _StationsViewState();
}

class _StationsViewState extends State<_StationsView> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<StationsBloc>().add(StationsSearchChanged(value.trim()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stations'),
        actions: [
          BlocBuilder<StationsBloc, StationsState>(
            buildWhen: (a, b) => a.sort != b.sort,
            builder: (context, state) => PopupMenuButton<StationSort>(
              icon: const Icon(Icons.sort_rounded),
              initialValue: state.sort,
              onSelected: (sort) =>
                  context.read<StationsBloc>().add(StationsSortChanged(sort)),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: StationSort.popularity,
                  child: Text('Most popular'),
                ),
                PopupMenuItem(
                  value: StationSort.votes,
                  child: Text('Top voted'),
                ),
                PopupMenuItem(value: StationSort.name, child: Text('A–Z')),
              ],
            ),
          ),
        ],
      ),
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
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search stations, genres',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const Expanded(child: _StationsList()),
        ],
      ),
    );
  }
}

class _StationsList extends StatelessWidget {
  const _StationsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StationsBloc, StationsState>(
      builder: (context, state) {
        switch (state.status) {
          case StationsStatus.initial:
          case StationsStatus.loading:
            return const _LoadingList();
          case StationsStatus.failure:
            return _ErrorView(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () =>
                  context.read<StationsBloc>().add(const StationsRequested()),
            );
          case StationsStatus.success:
            if (state.stations.isEmpty) {
              return const _EmptyView();
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<StationsBloc>().add(const StationsRefreshed()),
              child: BlocBuilder<PlayerBloc, PlayerState>(
                buildWhen: (a, b) => a.station != b.station,
                builder: (context, playerState) {
                  final activeUuid = playerState.station?.uuid;
                  return ListView.builder(
                    itemCount: state.stations.length,
                    itemBuilder: (context, index) {
                      final station = state.stations[index];
                      return StationTile(
                        station: station,
                        active: station.uuid == activeUuid,
                        onTap: () => context.read<PlayerBloc>().add(
                          PlayStationRequested(station),
                        ),
                      );
                    },
                  );
                },
              ),
            );
        }
      },
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 9,
      itemBuilder: (_, _) => const _SkeletonTile(),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          bar(48, 48),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(160, 14),
              const SizedBox(height: AppSpacing.sm),
              bar(96, 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No stations found.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
