import 'package:data/src/dtos/station_dto.dart';
import 'package:data/src/mappers/station_mapper.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StationMapper', () {
    test('maps a Radio Browser DTO to a domain Station', () {
      const dto = StationDto(
        stationUuid: 'abc',
        name: 'Jazz FM',
        url: 'http://fallback',
        urlResolved: 'http://resolved',
        favicon: 'http://favicon',
        country: 'United Kingdom',
        countryCode: 'GB',
        state: 'London',
        tags: 'jazz, blues',
        language: 'english',
        codec: 'MP3',
        bitrate: 128,
        hls: 1,
        votes: 10,
        clickCount: 20,
        lastCheckOk: 1,
        geoLat: 51.5,
        geoLong: -0.1,
      );

      final station = const StationMapper().convert<StationDto, Station>(dto);

      expect(station.uuid, 'abc');
      expect(station.streamUrl, 'http://resolved');
      expect(station.faviconUrl, 'http://favicon');
      expect(station.stateRegion, 'London');
      expect(station.tags, ['jazz', 'blues']);
      expect(station.languages, ['english']);
      expect(station.isHls, isTrue);
      expect(station.lastCheckOk, isTrue);
      expect(station.bitrate, 128);
      expect(station.geo, const GeoPoint(latitude: 51.5, longitude: -0.1));
    });

    test('falls back to url when url_resolved is missing', () {
      const dto = StationDto(stationUuid: 'x', name: 'X', url: 'http://only');
      final station = const StationMapper().convert<StationDto, Station>(dto);
      expect(station.streamUrl, 'http://only');
      expect(station.geo, isNull);
      expect(station.isHls, isFalse);
    });
  });
}
