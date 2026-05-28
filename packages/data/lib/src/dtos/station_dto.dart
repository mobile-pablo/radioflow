import 'package:json_annotation/json_annotation.dart';

part 'station_dto.g.dart';

@JsonSerializable(createToJson: false)
class StationDto {
  const StationDto({
    this.stationUuid = '',
    this.name = '',
    this.url,
    this.urlResolved,
    this.homepage,
    this.favicon,
    this.country = '',
    this.countryCode = '',
    this.state,
    this.tags,
    this.language,
    this.codec,
    this.bitrate,
    this.hls,
    this.votes = 0,
    this.clickCount = 0,
    this.lastCheckOk,
    this.geoLat,
    this.geoLong,
  });

  factory StationDto.fromJson(Map<String, dynamic> json) =>
      _$StationDtoFromJson(json);

  @JsonKey(name: 'stationuuid', defaultValue: '')
  final String stationUuid;
  @JsonKey(defaultValue: '')
  final String name;
  final String? url;
  @JsonKey(name: 'url_resolved')
  final String? urlResolved;
  final String? homepage;
  final String? favicon;
  @JsonKey(defaultValue: '')
  final String country;
  @JsonKey(name: 'countrycode', defaultValue: '')
  final String countryCode;
  final String? state;
  final String? tags;
  final String? language;
  final String? codec;
  final int? bitrate;
  final int? hls;
  @JsonKey(defaultValue: 0)
  final int votes;
  @JsonKey(name: 'clickcount', defaultValue: 0)
  final int clickCount;
  @JsonKey(name: 'lastcheckok')
  final int? lastCheckOk;
  @JsonKey(name: 'geo_lat')
  final double? geoLat;
  @JsonKey(name: 'geo_long')
  final double? geoLong;
}
