import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:domain/domain.dart';

import '../dtos/station_dto.dart';
import 'station_mapper.auto_mappr.dart';

@AutoMappr([
  MapType<StationDto, Station>(
    fields: [
      Field('uuid', from: 'stationUuid'),
      Field('faviconUrl', from: 'favicon'),
      Field('stateRegion', from: 'state'),
      Field('streamUrl', custom: streamUrlFromDto),
      Field('tags', custom: tagsFromDto),
      Field('languages', custom: languagesFromDto),
      Field('isHls', custom: isHlsFromDto),
      Field('lastCheckOk', custom: lastCheckOkFromDto),
      Field('geo', custom: geoFromDto),
    ],
  ),
])
class StationMapper extends $StationMapper {
  const StationMapper();
}

String streamUrlFromDto(StationDto dto) {
  final resolved = dto.urlResolved;
  if (resolved != null && resolved.isNotEmpty) return resolved;
  return dto.url ?? '';
}

List<String> tagsFromDto(StationDto dto) => _splitCsv(dto.tags);

List<String> languagesFromDto(StationDto dto) => _splitCsv(dto.language);

bool isHlsFromDto(StationDto dto) => dto.hls == 1;

bool lastCheckOkFromDto(StationDto dto) => dto.lastCheckOk != 0;

GeoPoint? geoFromDto(StationDto dto) {
  final lat = dto.geoLat;
  final lng = dto.geoLong;
  if (lat == null || lng == null) return null;
  if (lat == 0 && lng == 0) return null;
  return GeoPoint(latitude: lat, longitude: lng);
}

List<String> _splitCsv(String? value) {
  if (value == null || value.isEmpty) return const [];
  return value
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
