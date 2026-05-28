import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart' as globe;

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
  late final FlutterEarthGlobeController _controller =
      FlutterEarthGlobeController(
        surface: const AssetImage('assets/textures/earth.jpg'),
        isRotating: true,
        rotationSpeed: 0.05,
        zoom: 0.5,
        minZoom: 0.1,
        maxZoom: 4,
        isBackgroundFollowingSphereRotation: true,
      );

  final Set<String> _pointIds = {};

  @override
  void initState() {
    super.initState();
    _populate();
  }

  @override
  void didUpdateWidget(Map3dView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.clusters, widget.clusters)) _populate();
  }

  void _populate() {
    for (final id in _pointIds) {
      _controller.removePoint(id);
    }
    _pointIds.clear();
    for (final cluster in widget.clusters) {
      final id = cluster.primary.uuid;
      _pointIds.add(id);
      _controller.addPoint(
        globe.Point(
          id: id,
          coordinates: GlobeCoordinates(
            cluster.center.latitude,
            cluster.center.longitude,
          ),
          style: globe.PointStyle(
            color: AppColors.accent,
            size: cluster.isSingle
                ? 4
                : (4 + math.log(cluster.count + 1) * 1.6).clamp(4, 13),
          ),
          onTap: () => widget.onTapCluster(cluster),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final radius =
              math.min(constraints.maxWidth, constraints.maxHeight) * 0.42;
          return FlutterEarthGlobe(controller: _controller, radius: radius);
        },
      ),
    );
  }
}
