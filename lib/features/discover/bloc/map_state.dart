part of 'map_cubit.dart';

enum MapStatus { initial, loading, ready, failure }

final class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.stations = const [],
    this.clusters = const [],
    this.globeClusters = const [],
    this.zoom = MapCubit._initialZoom,
  });

  final MapStatus status;
  final List<Station> stations;
  final List<StationCluster> clusters;
  final List<StationCluster> globeClusters;
  final double zoom;

  MapState copyWith({
    MapStatus? status,
    List<Station>? stations,
    List<StationCluster>? clusters,
    List<StationCluster>? globeClusters,
    double? zoom,
  }) {
    return MapState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      clusters: clusters ?? this.clusters,
      globeClusters: globeClusters ?? this.globeClusters,
      zoom: zoom ?? this.zoom,
    );
  }

  @override
  List<Object?> get props => [status, stations, clusters, globeClusters, zoom];
}
