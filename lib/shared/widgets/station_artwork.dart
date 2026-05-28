import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

class StationArtwork extends StatelessWidget {
  const StationArtwork({
    super.key,
    required this.station,
    this.size = 48,
    this.radius = 12,
  });

  final Station station;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final favicon = station.faviconUrl;
    final hasFavicon = favicon != null && favicon.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: hasFavicon
            ? CachedNetworkImage(
                imageUrl: favicon,
                fit: BoxFit.cover,
                placeholder: (_, _) => _Fallback(station: station, size: size),
                errorWidget: (_, _, _) =>
                    _Fallback(station: station, size: size),
              )
            : _Fallback(station: station, size: size),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.station, required this.size});

  final Station station;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceAlt,
      child: Center(
        child: Text(
          station.initials,
          style: TextStyle(
            color: AppColors.cream,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
