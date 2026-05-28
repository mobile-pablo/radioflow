import '../entities/station.dart';
import '../entities/station_sort.dart';

abstract interface class StationRepository {
  Future<List<Station>> getStations({
    String query = '',
    StationSort sort = StationSort.popularity,
    int limit = 1000,
    int minBitrate = 0,
  });

  Future<List<Station>> getStationsWithGeo({int limit = 3000});

  Future<void> registerClick(String stationUuid);
}
