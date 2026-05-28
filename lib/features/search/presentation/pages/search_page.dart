import 'dart:async';

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _kHistory = 'search.history';

  final TextEditingController _controller = TextEditingController();
  final SharedPreferences _prefs = getIt<SharedPreferences>();
  Timer? _debounce;
  late final Future<List<Station>> _recommended;
  List<String> _history = const [];
  bool _hasQuery = false;

  @override
  void initState() {
    super.initState();
    _recommended = getIt<StationRepository>().getStations(limit: 20);
    _history = _prefs.getStringList(_kHistory) ?? const [];
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
      _saveHistory(query);
    });
  }

  void _saveHistory(String query) {
    final next = [
      query,
      ..._history.where((e) => e.toLowerCase() != query.toLowerCase()),
    ].take(8).toList();
    _prefs.setStringList(_kHistory, next);
    setState(() => _history = next);
  }

  void _runHistory(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    setState(() => _hasQuery = true);
    context.read<StationsBloc>().add(StationsSearchChanged(query));
    _saveHistory(query);
  }

  void _clearHistory() {
    _prefs.remove(_kHistory);
    setState(() => _history = const []);
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
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: 160),
      children: [
        if (_history.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recentSearches.toUpperCase(),
                    style: textTheme.labelSmall,
                  ),
                ),
                TextButton(
                  onPressed: _clearHistory,
                  child: Text(l10n.clearAll),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final term in _history)
                  _HistoryChip(label: term, onTap: () => _runHistory(term)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Text(
            l10n.recommended.toUpperCase(),
            style: textTheme.labelSmall,
          ),
        ),
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
          padding: shrinkWrap ? EdgeInsets.zero : const EdgeInsets.only(bottom: 160),
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

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 15,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
