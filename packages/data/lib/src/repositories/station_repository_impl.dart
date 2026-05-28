import 'package:dio/dio.dart';
import 'package:domain/domain.dart';

import '../dtos/station_dto.dart';
import '../mappers/station_mapper.dart';
import '../network/dio_failure_mapper.dart';
import '../network/radio_browser_api.dart';

class StationRepositoryImpl implements StationRepository {
  StationRepositoryImpl(this._api, [this._mapper = const StationMapper()]);

  final RadioBrowserApi _api;
  final StationMapper _mapper;

  @override
  Future<List<Station>> getStations({
    String query = '',
    StationSort sort = StationSort.popularity,
    int limit = 1000,
    int minBitrate = 0,
  }) {
    return _guard(() async {
      final dtos = await _api.searchStations(
        name: query.isEmpty ? null : query,
        order: _order(sort),
        reverse: sort != StationSort.name,
        limit: limit,
        hideBroken: true,
      );
      final stations = _toStations(dtos);
      if (minBitrate <= 0) return stations;
      return stations
          .where((s) => (s.bitrate ?? 0) >= minBitrate)
          .toList();
    });
  }

  @override
  Future<List<Station>> getStationsWithGeo({int limit = 3000}) {
    return _guard(() async {
      final dtos = await _api.searchStations(
        order: 'clickcount',
        reverse: true,
        limit: limit,
        hideBroken: true,
        hasGeoInfo: true,
      );
      return _toStations(dtos).where((station) => station.hasGeo).toList();
    });
  }

  @override
  Future<void> registerClick(String stationUuid) async {
    try {
      await _api.registerClick(stationUuid);
    } on DioException {
      return;
    }
  }

  List<Station> _toStations(List<StationDto> dtos) => dtos
      .where((dto) => dto.stationUuid.isNotEmpty)
      .map((dto) => _mapper.convert<StationDto, Station>(dto))
      .where((station) => station.streamUrl.isNotEmpty && station.lastCheckOk)
      .toList();

  String _order(StationSort sort) => switch (sort) {
    StationSort.popularity => 'clickcount',
    StationSort.votes => 'votes',
    StationSort.name => 'name',
  };

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
