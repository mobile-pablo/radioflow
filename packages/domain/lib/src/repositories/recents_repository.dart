import '../entities/station.dart';

abstract interface class RecentsRepository {
  Future<List<Station>> getRecents();

  Future<void> add(Station station);

  Future<void> clear();
}
