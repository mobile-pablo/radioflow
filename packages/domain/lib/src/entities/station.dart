import 'package:freezed_annotation/freezed_annotation.dart';

import 'geo_point.dart';

part 'station.freezed.dart';

@freezed
abstract class Station with _$Station {
  const Station._();

  const factory Station({
    required String uuid,
    required String name,
    required String streamUrl,
    String? homepage,
    String? faviconUrl,
    @Default('') String country,
    @Default('') String countryCode,
    String? stateRegion,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> languages,
    String? codec,
    int? bitrate,
    @Default(false) bool isHls,
    @Default(0) int votes,
    @Default(0) int clickCount,
    @Default(true) bool lastCheckOk,
    GeoPoint? geo,
  }) = _Station;

  bool get hasGeo => geo != null;

  String get primaryTag => tags.isEmpty ? '' : tags.first;

  String get initials {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return '?';
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.length == 1) {
      final word = words.first;
      return (word.length <= 3 ? word : word.substring(0, 3)).toUpperCase();
    }
    return words.take(3).map((w) => w[0]).join().toUpperCase();
  }
}
