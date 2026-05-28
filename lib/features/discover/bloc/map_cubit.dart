import 'dart:math' as math;

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import 'station_cluster.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit(this._repository) : super(const MapState());

  final StationRepository _repository;

  static const double _initialZoom = 2.5;

  Future<void> load() async {
    emit(state.copyWith(status: MapStatus.loading));
    try {
      final stations = await _repository.getStationsWithGeo();
      emit(
        state.copyWith(
          status: MapStatus.ready,
          stations: stations,
          clusters: _cluster(stations, _initialZoom),
        ),
      );
    } on Failure {
      emit(state.copyWith(status: MapStatus.failure));
    }
  }

  void onZoomChanged(double zoom) {
    if ((zoom - state.zoom).abs() < 0.4) return;
    emit(state.copyWith(zoom: zoom, clusters: _cluster(state.stations, zoom)));
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
