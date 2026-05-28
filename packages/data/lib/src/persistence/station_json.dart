import 'package:domain/domain.dart';

Map<String, dynamic> stationToJson(Station station) => {
  'uuid': station.uuid,
  'name': station.name,
  'streamUrl': station.streamUrl,
  'homepage': station.homepage,
  'faviconUrl': station.faviconUrl,
  'country': station.country,
  'countryCode': station.countryCode,
  'stateRegion': station.stateRegion,
  'tags': station.tags,
  'languages': station.languages,
  'codec': station.codec,
  'bitrate': station.bitrate,
  'isHls': station.isHls,
  'votes': station.votes,
  'clickCount': station.clickCount,
  'lastCheckOk': station.lastCheckOk,
  'lat': station.geo?.latitude,
  'lng': station.geo?.longitude,
};

Station stationFromJson(Map<String, dynamic> json) {
  final lat = json['lat'] as num?;
  final lng = json['lng'] as num?;
  return Station(
    uuid: json['uuid'] as String? ?? '',
    name: json['name'] as String? ?? '',
    streamUrl: json['streamUrl'] as String? ?? '',
    homepage: json['homepage'] as String?,
    faviconUrl: json['faviconUrl'] as String?,
    country: json['country'] as String? ?? '',
    countryCode: json['countryCode'] as String? ?? '',
    stateRegion: json['stateRegion'] as String?,
    tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
    languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? const [],
    codec: json['codec'] as String?,
    bitrate: json['bitrate'] as int?,
    isHls: json['isHls'] as bool? ?? false,
    votes: json['votes'] as int? ?? 0,
    clickCount: json['clickCount'] as int? ?? 0,
    lastCheckOk: json['lastCheckOk'] as bool? ?? true,
    geo: (lat != null && lng != null)
        ? GeoPoint(latitude: lat.toDouble(), longitude: lng.toDouble())
        : null,
  );
}
