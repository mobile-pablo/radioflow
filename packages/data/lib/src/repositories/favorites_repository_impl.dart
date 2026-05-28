import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../persistence/station_json.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'favorites.v1';

  @override
  Future<List<Station>> getFavorites() async => _read();

  @override
  Future<void> add(Station station) async {
    final current = _read();
    if (current.any((s) => s.uuid == station.uuid)) return;
    await _write([station, ...current]);
  }

  @override
  Future<void> remove(String stationUuid) async {
    final current = _read()..removeWhere((s) => s.uuid == stationUuid);
    await _write(current);
  }

  @override
  Future<bool> isFavorite(String stationUuid) async =>
      _read().any((s) => s.uuid == stationUuid);

  List<Station> _read() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => stationFromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> _write(List<Station> stations) async {
    try {
      final encoded = jsonEncode(stations.map(stationToJson).toList());
      await _prefs.setString(_key, encoded);
    } on Exception {
      throw const StorageFailure();
    }
  }
}
