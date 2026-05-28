import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_point.freezed.dart';

@freezed
abstract class GeoPoint with _$GeoPoint {
  const factory GeoPoint({
    required double latitude,
    required double longitude,
  }) = _GeoPoint;
}
