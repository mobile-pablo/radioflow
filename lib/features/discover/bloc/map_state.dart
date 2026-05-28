part of 'map_cubit.dart';

enum MapStatus { initial, loading, ready, failure }

final class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.stations = const [],
    this.clusters = const [],
    this.globeClusters = const [],
    this.zoom = MapCubit._initialZoom,
    this.genres = const {},
    this.region,
    this.minBitrate = 0,
  });

  final MapStatus status;
  final List<Station> stations;
  final List<StationCluster> clusters;
  final List<StationCluster> globeClusters;
  final double zoom;
  final Set<String> genres;
  final String? region;
  final int minBitrate;

  bool get hasFilters => genres.isNotEmpty || region != null || minBitrate > 0;

  MapState copyWith({
    MapStatus? status,
    List<Station>? stations,
    List<StationCluster>? clusters,
    List<StationCluster>? globeClusters,
    double? zoom,
    Set<String>? genres,
    String? region,
    bool clearRegion = false,
    int? minBitrate,
  }) {
    return MapState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      clusters: clusters ?? this.clusters,
      globeClusters: globeClusters ?? this.globeClusters,
      zoom: zoom ?? this.zoom,
      genres: genres ?? this.genres,
      region: clearRegion ? null : (region ?? this.region),
      minBitrate: minBitrate ?? this.minBitrate,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stations,
    clusters,
    globeClusters,
    zoom,
    genres,
    region,
    minBitrate,
  ];
}
