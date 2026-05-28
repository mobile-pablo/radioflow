import '../entities/station.dart';

abstract interface class FavoritesRepository {
  Future<List<Station>> getFavorites();

  Future<void> add(Station station);

  Future<void> remove(String stationUuid);

  Future<bool> isFavorite(String stationUuid);
}
