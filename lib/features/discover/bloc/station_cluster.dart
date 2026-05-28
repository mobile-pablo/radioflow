import 'package:domain/domain.dart';
import 'package:latlong2/latlong.dart';

class StationCluster {
  const StationCluster({required this.center, required this.stations});

  final LatLng center;
  final List<Station> stations;

  bool get isSingle => stations.length == 1;

  int get count => stations.length;

  Station get primary => stations.first;

  String get label {
    if (isSingle) return primary.name;
    final region = stations
        .map((s) => s.stateRegion)
        .firstWhere((s) => s != null && s.isNotEmpty, orElse: () => null);
    if (region != null && region.isNotEmpty) return region;
    final country = stations
        .map((s) => s.country)
        .firstWhere((c) => c.isNotEmpty, orElse: () => '');
    return country.isEmpty ? '$count stations' : country;
  }
}
