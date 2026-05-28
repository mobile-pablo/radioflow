import 'dart:convert';
import 'dart:io';

import 'package:domain/domain.dart';

class CityNameService {
  final Map<String, String> _cache = {};
  final String _token = const String.fromEnvironment('MAPBOX_TOKEN');

  Future<String?> cityFor(Station station) async {
    final geo = station.geo;
    if (geo == null || _token.isEmpty) return null;
    final cached = _cache[station.uuid];
    if (cached != null) return cached;
    try {
      final uri = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '${geo.longitude},${geo.latitude}.json'
        '?types=place,locality&limit=1&access_token=$_token',
      );
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();
      if (response.statusCode != 200) return null;
      final json = jsonDecode(body) as Map<String, dynamic>;
      final features = json['features'] as List?;
      if (features == null || features.isEmpty) return null;
      final name = (features.first as Map)['text'] as String?;
      if (name != null && name.isNotEmpty) _cache[station.uuid] = name;
      return name;
    } on Object {
      return null;
    }
  }
}
