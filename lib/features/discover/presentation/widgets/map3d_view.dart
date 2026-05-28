import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../bloc/station_cluster.dart';

class Map3dView extends StatefulWidget {
  const Map3dView({
    super.key,
    required this.clusters,
    required this.onTapCluster,
  });

  final List<StationCluster> clusters;
  final void Function(StationCluster cluster) onTapCluster;

  @override
  State<Map3dView> createState() => _Map3dViewState();
}

class _Map3dViewState extends State<Map3dView> {
  CircleAnnotationManager? _manager;
  final Map<String, StationCluster> _byAnnotation = {};

  @override
  void didUpdateWidget(Map3dView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.clusters, widget.clusters)) _syncAnnotations();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    await map.style.setProjection(
      StyleProjection(name: StyleProjectionName.globe),
    );
    final manager = await map.annotations.createCircleAnnotationManager();
    manager.tapEvents(
      onTap: (annotation) {
        final cluster = _byAnnotation[annotation.id];
        if (cluster != null) widget.onTapCluster(cluster);
      },
    );
    _manager = manager;
    await _syncAnnotations();
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
          circleColor: AppColors.accent.toARGB32(),
          circleRadius: cluster.isSingle ? 5 : cluster.markerDiameter * 0.5,
          circleStrokeColor: AppColors.ink.toARGB32(),
          circleStrokeWidth: 1,
        ),
    ];
    final created = await manager.createMulti(options);
    for (var i = 0; i < created.length; i++) {
      final annotation = created[i];
      if (annotation != null) {
        _byAnnotation[annotation.id] = widget.clusters[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('discoverGlobe'),
      styleUri: MapboxStyles.SATELLITE_STREETS,
      viewport: CameraViewportState(
        center: Point(coordinates: Position(0, 20)),
        zoom: 1.5,
      ),
      onMapCreated: _onMapCreated,
    );
  }
}
