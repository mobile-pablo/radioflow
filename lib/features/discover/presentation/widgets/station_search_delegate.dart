import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/station_tile.dart';

class StationSearchDelegate extends SearchDelegate<Station?> {
  StationSearchDelegate(this._repository, {required String hint})
    : super(searchFieldLabel: hint);

  final StationRepository _repository;

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().length < 2) return const SizedBox.shrink();
    return _results(context);
  }

  @override
  Widget buildResults(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    return FutureBuilder<List<Station>>(
      future: _repository.getStations(query: query.trim(), limit: 40),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final stations = snapshot.data ?? const [];
        if (stations.isEmpty) {
          return const SizedBox.shrink();
        }
        return ListView.builder(
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            return StationTile(
              station: station,
              onTap: () => close(context, station),
            );
          },
        );
      },
    );
  }
}
