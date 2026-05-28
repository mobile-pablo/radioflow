import 'package:core/core.dart';
import 'package:domain/domain.dart' as domain;
import 'package:flutter/widgets.dart';
import 'package:maplibre/maplibre.dart';

class Map3dView extends StatelessWidget {
  const Map3dView({
    super.key,
    required this.stations,
    required this.onStationTap,
  });

  final List<domain.Station> stations;
  final void Function(domain.Station station) onStationTap;

  static const String _style =
      'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

  List<domain.Station> get _geoStations =>
      stations.where((s) => s.geo != null).toList();

  void _handleClick(double lon, double lat) {
    domain.Station? best;
    var bestDistance = double.infinity;
    for (final station in _geoStations) {
      final geo = station.geo!;
      final dLon = geo.longitude - lon;
      final dLat = geo.latitude - lat;
      final distance = dLon * dLon + dLat * dLat;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = station;
      }
    }
    if (best != null && bestDistance < 1) onStationTap(best);
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      options: const MapOptions(
        initStyle: _style,
        initCenter: Geographic(lon: 0, lat: 20),
        initZoom: 2.5,
        initPitch: 45,
        maxPitch: 65,
        maxZoom: 18,
      ),
      layers: [
        CircleLayer(
          points: [
            for (final station in _geoStations)
              Feature<Point>(
                id: station.uuid,
                geometry: Point(
                  Geographic(
                    lon: station.geo!.longitude,
                    lat: station.geo!.latitude,
                  ),
                ),
              ),
          ],
          radius: 5,
          color: AppColors.accent,
          strokeWidth: 1,
          strokeColor: AppColors.ink,
        ),
      ],
      onEvent: (event) {
        if (event is MapEventClick) {
          _handleClick(event.point.lon, event.point.lat);
        }
      },
    );
  }
}
