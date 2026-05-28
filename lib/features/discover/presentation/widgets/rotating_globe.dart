import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../bloc/station_cluster.dart';

const double _deg2rad = math.pi / 180;

Offset? _project(
  double latDeg,
  double lngDeg,
  double lat0,
  double lon0,
  double radius,
  Offset center,
) {
  final phi = latDeg * _deg2rad;
  final lam = lngDeg * _deg2rad;
  final cosc =
      math.sin(lat0) * math.sin(phi) +
      math.cos(lat0) * math.cos(phi) * math.cos(lam - lon0);
  if (cosc < 0) return null;
  final x = radius * math.cos(phi) * math.sin(lam - lon0);
  final y =
      radius *
      (math.cos(lat0) * math.sin(phi) -
          math.sin(lat0) * math.cos(phi) * math.cos(lam - lon0));
  return Offset(center.dx + x, center.dy - y);
}

class RotatingGlobe extends StatefulWidget {
  const RotatingGlobe({
    super.key,
    required this.clusters,
    required this.onTapCluster,
  });

  final List<StationCluster> clusters;
  final void Function(StationCluster cluster) onTapCluster;

  @override
  State<RotatingGlobe> createState() => _RotatingGlobeState();
}

class _RotatingGlobeState extends State<RotatingGlobe>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _lonDeg = 0;
  double _latDeg = 18;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1000000;
    _last = elapsed;
    if (_dragging || dt <= 0) return;
    setState(() => _lonDeg = (_lonDeg + 6 * dt) % 360);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _lonDeg = (_lonDeg - details.delta.dx * 0.4) % 360;
      _latDeg = (_latDeg + details.delta.dy * 0.4).clamp(-80, 80);
    });
  }

  void _handleTap(Offset position, Offset center, double radius) {
    final lat0 = _latDeg * _deg2rad;
    final lon0 = _lonDeg * _deg2rad;
    StationCluster? nearest;
    double nearestDistance = double.infinity;
    for (final cluster in widget.clusters) {
      final projected = _project(
        cluster.center.latitude,
        cluster.center.longitude,
        lat0,
        lon0,
        radius,
        center,
      );
      if (projected == null) continue;
      final distance = (projected - position).distance;
      final hitRadius = math.max(20.0, cluster.markerDiameter * 0.6);
      if (distance < hitRadius && distance < nearestDistance) {
        nearestDistance = distance;
        nearest = cluster;
      }
    }
    if (nearest != null) widget.onTapCluster(nearest);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = size.center(Offset.zero);
        final radius = math.min(size.width, size.height) / 2 - 16;
        return GestureDetector(
          onPanStart: (_) => _dragging = true,
          onPanUpdate: _onPanUpdate,
          onPanEnd: (_) => _dragging = false,
          onTapUp: (details) =>
              _handleTap(details.localPosition, center, radius),
          child: CustomPaint(
            size: size,
            painter: _GlobePainter(
              clusters: widget.clusters,
              lonDeg: _lonDeg,
              latDeg: _latDeg,
            ),
          ),
        );
      },
    );
  }
}

class _GlobePainter extends CustomPainter {
  _GlobePainter({
    required this.clusters,
    required this.lonDeg,
    required this.latDeg,
  });

  final List<StationCluster> clusters;
  final double lonDeg;
  final double latDeg;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 16;
    final lat0 = latDeg * _deg2rad;
    final lon0 = lonDeg * _deg2rad;

    canvas.drawCircle(
      center,
      radius + 10,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.35),
            AppColors.accent.withValues(alpha: 0),
          ],
          stops: const [0.86, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius + 10)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [AppColors.surfaceHi, AppColors.ink],
          stops: [0, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    _drawGraticule(canvas, center, radius, lat0, lon0);

    final dotPaint = Paint()..color = AppColors.accent;
    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (final cluster in clusters) {
      final point = _project(
        cluster.center.latitude,
        cluster.center.longitude,
        lat0,
        lon0,
        radius,
        center,
      );
      if (point == null) continue;
      final dotRadius = cluster.markerDiameter * 0.32;
      canvas.drawCircle(point, dotRadius + 2, glowPaint);
      canvas.drawCircle(point, dotRadius, dotPaint);
    }
  }

  void _drawGraticule(
    Canvas canvas,
    Offset center,
    double radius,
    double lat0,
    double lon0,
  ) {
    final paint = Paint()
      ..color = AppColors.lineStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (var lng = -180; lng < 180; lng += 30) {
      final path = Path();
      var started = false;
      for (var lat = -80; lat <= 80; lat += 4) {
        final p = _project(
          lat.toDouble(),
          lng.toDouble(),
          lat0,
          lon0,
          radius,
          center,
        );
        if (p == null) {
          started = false;
          continue;
        }
        if (!started) {
          path.moveTo(p.dx, p.dy);
          started = true;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    for (var lat = -60; lat <= 60; lat += 30) {
      final path = Path();
      var started = false;
      for (var lng = -180; lng <= 180; lng += 4) {
        final p = _project(
          lat.toDouble(),
          lng.toDouble(),
          lat0,
          lon0,
          radius,
          center,
        );
        if (p == null) {
          started = false;
          continue;
        }
        if (!started) {
          path.moveTo(p.dx, p.dy);
          started = true;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_GlobePainter old) =>
      old.lonDeg != lonDeg || old.latDeg != latDeg || old.clusters != clusters;
}
