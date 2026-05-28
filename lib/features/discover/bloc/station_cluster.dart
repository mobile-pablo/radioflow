import 'dart:math' as math;

import 'package:domain/domain.dart';
import 'package:latlong2/latlong.dart';

class StationCluster {
  const StationCluster({required this.center, required this.stations});

  final LatLng center;
  final List<Station> stations;

  bool get isSingle => stations.length == 1;

  int get count => stations.length;

  Station get primary => stations.first;

  double get markerDiameter => (12 + 6 * math.log(count + 1)).clamp(12.0, 38.0);
}
