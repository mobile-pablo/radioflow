import 'dart:math' as math;

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../shared/stations_holder.dart';
import 'station_cluster.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit(this._repository, this._holder) : super(const MapState());

  final StationRepository _repository;
  final StationsHolder _holder;
  final math.Random _random = math.Random();

  static const double _initialZoom = 2.5;
  static const double _globeZoom = 2;

  static const Map<
    String,
    ({double minLat, double maxLat, double minLng, double maxLng})
  >
  _regions = {
    'europe': (minLat: 35, maxLat: 72, minLng: -25, maxLng: 45),
    'north_america': (minLat: 7, maxLat: 72, minLng: -170, maxLng: -50),
    'south_america': (minLat: -56, maxLat: 13, minLng: -82, maxLng: -34),
    'asia': (minLat: 0, maxLat: 75, minLng: 45, maxLng: 180),
    'africa': (minLat: -35, maxLat: 38, minLng: -20, maxLng: 52),
  };

  Future<void> load() async {
    emit(state.copyWith(status: MapStatus.loading));
    try {
      final stations = await _repository.getStationsWithGeo();
      _holder.stations = stations;
      emit(
        state.copyWith(
          status: MapStatus.ready,
          stations: stations,
          clusters: _cluster(stations, _initialZoom),
          globeClusters: _cluster(stations, _globeZoom),
        ),
      );
    } on Failure {
      emit(state.copyWith(status: MapStatus.failure));
    }
  }

  Station? randomStation() {
    final visible = _visible(state);
    if (visible.isEmpty) return null;
    return visible[_random.nextInt(visible.length)];
  }

  void onZoomChanged(double zoom) {
    if ((zoom - state.zoom).abs() < 0.4) return;
    emit(state.copyWith(zoom: zoom, clusters: _cluster(_visible(state), zoom)));
  }

  void applyFilters({
    required Set<String> genres,
    required String? region,
    required int minBitrate,
  }) {
    final next = state.copyWith(
      genres: genres,
      region: region,
      clearRegion: region == null,
      minBitrate: minBitrate,
    );
    final visible = _visible(next);
    emit(
      next.copyWith(
        clusters: _cluster(visible, next.zoom),
        globeClusters: _cluster(visible, _globeZoom),
      ),
    );
  }

  List<Station> _visible(MapState s) {
    if (s.genres.isEmpty && s.region == null && s.minBitrate <= 0) {
      return s.stations;
    }
    return s.stations.where((station) => _matches(station, s)).toList();
  }

  bool _matches(Station station, MapState s) {
    if (s.minBitrate > 0 && (station.bitrate ?? 0) < s.minBitrate) return false;
    if (s.genres.isNotEmpty) {
      final hit = station.tags.any(
        (tag) =>
            s.genres.any((g) => tag.toLowerCase().contains(g.toLowerCase())),
      );
      if (!hit) return false;
    }
    final region = s.region;
    if (region != null) {
      final box = _regions[region];
      final geo = station.geo;
      if (box == null || geo == null) return false;
      if (geo.latitude < box.minLat ||
          geo.latitude > box.maxLat ||
          geo.longitude < box.minLng ||
          geo.longitude > box.maxLng) {
        return false;
      }
    }
    return true;
  }

  List<StationCluster> _cluster(List<Station> stations, double zoom) {
    final cell = 40 / math.pow(2, zoom);
    final buckets = <String, List<Station>>{};
    for (final station in stations) {
      final geo = station.geo;
      if (geo == null) continue;
      final key =
          '${(geo.latitude / cell).floor()}:${(geo.longitude / cell).floor()}';
      buckets.putIfAbsent(key, () => []).add(station);
    }
    return buckets.values.map((group) {
      final lat =
          group.map((s) => s.geo!.latitude).reduce((a, b) => a + b) /
          group.length;
      final lng =
          group.map((s) => s.geo!.longitude).reduce((a, b) => a + b) /
          group.length;
      return StationCluster(center: LatLng(lat, lng), stations: group);
    }).toList();
  }
}
