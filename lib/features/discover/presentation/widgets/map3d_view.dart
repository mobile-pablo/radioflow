import 'dart:convert';
import 'dart:math' as math;

import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class Map3dView extends StatefulWidget {
  const Map3dView({
    super.key,
    required this.stations,
    required this.onPlay,
    required this.onCenterStation,
    this.locked = false,
    this.focus,
  });

  final List<Station> stations;
  final void Function(Station station) onPlay;
  final void Function(Station? station) onCenterStation;
  final bool locked;
  final Station? focus;

  @override
  State<Map3dView> createState() => _Map3dViewState();
}

class _Map3dViewState extends State<Map3dView> {
  static const String _sourceId = 'rf-stations';
  static const String _clusterLayer = 'rf-clusters';
  static const String _pointLayer = 'rf-points';

  MapboxMap? _map;
  bool _sourceReady = false;
  bool _armed = false;
  double _zoom = 1.5;
  final Map<String, Station> _byUuid = {};

  late final MapWidget _mapWidget = MapWidget(
    key: const ValueKey('discoverGlobe'),
    styleUri: MapboxStyles.SATELLITE,
    viewport: CameraViewportState(
      center: Point(coordinates: Position(0, 20)),
      zoom: 1.5,
    ),
    onMapCreated: _onMapCreated,
    onCameraChangeListener: (data) => _zoom = data.cameraState.zoom,
    onMapIdleListener: (_) => _maybeTune(),
    // ignore: deprecated_member_use
    onScrollListener: (_) => _armed = true,
    // ignore: deprecated_member_use
    onTapListener: _onTap,
  );

  Future<void> _maybeTune() async {
    final map = _map;
    if (!_armed || widget.locked || map == null) return;
    try {
      final size = await map.getSize();
      final w = size.width;
      final h = size.height;
      final radiusPx = w * 0.1;
      final centerCoord = await map.coordinateForPixel(
        ScreenCoordinate(x: w / 2, y: h / 2),
      );
      final edgeCoord = await map.coordinateForPixel(
        ScreenCoordinate(x: w / 2 + radiusPx, y: h / 2),
      );
      final clat = centerCoord.coordinates.lat.toDouble();
      final clng = centerCoord.coordinates.lng.toDouble();
      final cosLat = math.cos(clat * math.pi / 180);
      final dLatE = edgeCoord.coordinates.lat.toDouble() - clat;
      final dLngE = (edgeCoord.coordinates.lng.toDouble() - clng) * cosLat;
      final radiusSq = dLatE * dLatE + dLngE * dLngE;
      Station? nearest;
      double best = double.infinity;
      for (final station in widget.stations) {
        final geo = station.geo;
        if (geo == null) continue;
        final dLat = geo.latitude - clat;
        final dLng = (geo.longitude - clng) * cosLat;
        final dist = dLat * dLat + dLng * dLng;
        if (dist < best) {
          best = dist;
          nearest = station;
        }
      }
      widget.onCenterStation(
        nearest != null && best <= radiusSq ? nearest : null,
      );
    } on Object {
      return;
    }
  }

  @override
  void didUpdateWidget(Map3dView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.stations, widget.stations)) _publishStations();
    if (widget.focus != null && oldWidget.focus != widget.focus) {
      _flyToStation(widget.focus!);
    }
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await map.logo.updateSettings(LogoSettings(enabled: false));
    await map.attribution.updateSettings(AttributionSettings(enabled: false));
    await map.compass.updateSettings(
      CompassSettings(position: OrnamentPosition.TOP_LEFT),
    );
    await map.style.setProjection(
      StyleProjection(name: StyleProjectionName.globe),
    );
    await _publishStations();
    if (widget.focus != null) _flyToStation(widget.focus!);
  }

  String _featureCollection() {
    _byUuid.clear();
    final features = <Map<String, Object?>>[];
    final geoStations = widget.stations.where((s) => s.geo != null).take(2000);
    for (final station in geoStations) {
      final geo = station.geo!;
      _byUuid[station.uuid] = station;
      features.add({
        'type': 'Feature',
        'properties': {'uuid': station.uuid},
        'geometry': {
          'type': 'Point',
          'coordinates': [geo.longitude, geo.latitude],
        },
      });
    }
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  Future<void> _publishStations() async {
    final map = _map;
    if (map == null || widget.stations.isEmpty) return;
    final data = _featureCollection();
    if (_sourceReady) {
      await map.style.setStyleSourceProperty(_sourceId, 'data', data);
      return;
    }
    try {
      await map.style.addSource(
        GeoJsonSource(
          id: _sourceId,
          data: data,
          cluster: true,
          clusterRadius: 60,
          clusterMaxZoom: 14,
        ),
      );
      await map.style.addLayer(
        CircleLayer(
          id: _clusterLayer,
          sourceId: _sourceId,
          circleColor: 0xFF38E1B0,
          circleRadius: 16,
          circleStrokeColor: 0xFF001A12,
          circleStrokeWidth: 1.5,
        ),
      );
      await map.style.setStyleLayerProperty(
        _clusterLayer,
        'filter',
        jsonEncode(['has', 'point_count']),
      );
      await map.style.setStyleLayerProperty(
        _clusterLayer,
        'circle-radius',
        jsonEncode([
          'step',
          ['get', 'point_count'],
          12,
          10,
          16,
          50,
          22,
          200,
          30,
        ]),
      );
      await map.style.addLayer(
        CircleLayer(
          id: _pointLayer,
          sourceId: _sourceId,
          circleColor: 0xFF38E1B0,
          circleRadius: 5,
          circleStrokeColor: 0xFF001A12,
          circleStrokeWidth: 1,
        ),
      );
      await map.style.setStyleLayerProperty(
        _pointLayer,
        'filter',
        jsonEncode([
          '!',
          ['has', 'point_count'],
        ]),
      );
      _sourceReady = true;
    } on Object {
      return;
    }
  }

  Future<void> _onTap(MapContentGestureContext context) async {
    final map = _map;
    if (map == null) return;
    try {
      final features = await map.queryRenderedFeatures(
        RenderedQueryGeometry.fromScreenCoordinate(context.touchPosition),
        RenderedQueryOptions(
          layerIds: [_clusterLayer, _pointLayer],
          filter: null,
        ),
      );
      for (final result in features) {
        if (result == null) continue;
        final feature = result.queriedFeature.feature;
        final properties = feature['properties'];
        if (properties is! Map) continue;
        if (properties['point_count'] != null) {
          await _playClusterLeaf(map, feature);
          final geometry = feature['geometry'];
          if (geometry is Map && geometry['coordinates'] is List) {
            final coords = geometry['coordinates'] as List;
            _flyTo(
              (coords[0] as num).toDouble(),
              (coords[1] as num).toDouble(),
              _zoom + 2,
            );
          }
          return;
        }
        final station = _byUuid[properties['uuid']];
        if (station != null) {
          widget.onPlay(station);
          final geo = station.geo!;
          _flyTo(geo.longitude, geo.latitude, _zoom < 6 ? 7 : _zoom);
        }
        return;
      }
    } on Object {
      return;
    }
  }

  Future<void> _playClusterLeaf(
    MapboxMap map,
    Map<Object?, Object?> feature,
  ) async {
    try {
      final leaves = await map.getGeoJsonClusterLeaves(
        _sourceId,
        feature.cast<String?, Object?>(),
        1,
        0,
      );
      final collection = leaves.featureCollection;
      if (collection == null || collection.isEmpty) return;
      final properties = collection.first?['properties'];
      if (properties is Map) {
        final station = _byUuid[properties['uuid']];
        if (station != null) widget.onPlay(station);
      }
    } on Object {
      return;
    }
  }

  void _flyToStation(Station station) {
    final geo = station.geo;
    if (geo == null) return;
    _flyTo(geo.longitude, geo.latitude, _zoom < 6 ? 7 : _zoom);
  }

  void _flyTo(double lon, double lat, double zoom) {
    _armed = false;
    _map?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lon, lat)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1400),
    );
  }

  @override
  Widget build(BuildContext context) => _mapWidget;
}
