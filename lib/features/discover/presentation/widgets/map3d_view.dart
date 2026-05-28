import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../bloc/station_cluster.dart';

class Map3dView extends StatefulWidget {
  const Map3dView({
    super.key,
    required this.clusters,
    required this.onPlay,
    required this.onZoom,
    this.focus,
  });

  final List<StationCluster> clusters;
  final void Function(Station station) onPlay;
  final void Function(double zoom) onZoom;
  final Station? focus;

  @override
  State<Map3dView> createState() => _Map3dViewState();
}

class _Map3dViewState extends State<Map3dView> {
  MapboxMap? _map;
  CircleAnnotationManager? _manager;
  final Map<String, StationCluster> _byAnnotation = {};
  double _zoom = 1.5;

  @override
  void didUpdateWidget(Map3dView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.clusters, widget.clusters)) _syncAnnotations();
    if (widget.focus != null && oldWidget.focus != widget.focus) {
      _flyToStation(widget.focus!);
    }
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.style.setProjection(
      StyleProjection(name: StyleProjectionName.globe),
    );
    await _addBorders(map);
    final manager = await map.annotations.createCircleAnnotationManager();
    manager.tapEvents(
      onTap: (annotation) {
        final cluster = _byAnnotation[annotation.id];
        if (cluster == null) return;
        widget.onPlay(cluster.primary);
        _flyTo(
          cluster.center.longitude,
          cluster.center.latitude,
          cluster.isSingle ? 8 : _zoom + 2,
        );
      },
    );
    _manager = manager;
    await _syncAnnotations();
    if (widget.focus != null) _flyToStation(widget.focus!);
  }

  Future<void> _addBorders(MapboxMap map) async {
    try {
      await map.style.addSource(
        VectorSource(id: 'rf-admin', url: 'mapbox://mapbox.mapbox-streets-v8'),
      );
      await map.style.addLayer(
        LineLayer(
          id: 'rf-borders',
          sourceId: 'rf-admin',
          sourceLayer: 'admin',
          lineColor: 0x73FFFFFF,
          lineWidth: 0.8,
        ),
      );
      await map.style.setStyleLayerProperty(
        'rf-borders',
        'filter',
        jsonEncode([
          '==',
          ['get', 'admin_level'],
          0,
        ]),
      );
    } on Object {
      return;
    }
  }

  Future<void> _syncAnnotations() async {
    final manager = _manager;
    if (manager == null) return;
    await manager.deleteAll();
    _byAnnotation.clear();
    final options = [
      for (final cluster in widget.clusters)
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              cluster.center.longitude,
              cluster.center.latitude,
            ),
          ),
          circleColor: 0xFF38E1B0,
          circleRadius: cluster.isSingle ? 5 : cluster.markerDiameter * 0.5,
          circleStrokeColor: 0xFF000000,
          circleStrokeWidth: 1,
        ),
    ];
    final created = await manager.createMulti(options);
    for (var i = 0; i < created.length; i++) {
      final annotation = created[i];
      if (annotation != null) _byAnnotation[annotation.id] = widget.clusters[i];
    }
  }

  void _flyToStation(Station station) {
    final geo = station.geo;
    if (geo == null) return;
    _flyTo(geo.longitude, geo.latitude, _zoom < 6 ? 7 : _zoom);
  }

  void _flyTo(double lon, double lat, double zoom) {
    _map?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lon, lat)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('discoverGlobe'),
      styleUri: MapboxStyles.SATELLITE,
      viewport: CameraViewportState(
        center: Point(coordinates: Position(0, 20)),
        zoom: 1.5,
      ),
      onMapCreated: _onMapCreated,
      onCameraChangeListener: (data) {
        _zoom = data.cameraState.zoom;
        widget.onZoom(_zoom);
      },
    );
  }
}
