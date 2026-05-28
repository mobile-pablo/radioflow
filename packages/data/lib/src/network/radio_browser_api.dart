import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/station_dto.dart';

part 'radio_browser_api.g.dart';

@RestApi()
abstract class RadioBrowserApi {
  factory RadioBrowserApi(Dio dio, {String? baseUrl}) = _RadioBrowserApi;

  @GET('/json/stations/search')
  Future<List<StationDto>> searchStations({
    @Query('name') String? name,
    @Query('tag') String? tag,
    @Query('countrycode') String? countryCode,
    @Query('order') String? order,
    @Query('reverse') bool? reverse,
    @Query('limit') int? limit,
    @Query('hidebroken') bool? hideBroken,
    @Query('has_geo_info') bool? hasGeoInfo,
  });

  @GET('/json/stations/topclick/{limit}')
  Future<List<StationDto>> topClick(@Path('limit') int limit);

  @GET('/json/stations/bycountrycodeexact/{code}')
  Future<List<StationDto>> byCountryCode(@Path('code') String code);

  @GET('/json/stations/bytagexact/{tag}')
  Future<List<StationDto>> byTag(@Path('tag') String tag);

  @GET('/json/url/{uuid}')
  Future<void> registerClick(@Path('uuid') String uuid);
}
