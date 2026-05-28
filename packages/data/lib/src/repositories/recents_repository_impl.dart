import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../persistence/station_json.dart';

class RecentsRepositoryImpl implements RecentsRepository {
  RecentsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'recents.v1';
  static const int _max = 12;

  @override
  Future<List<Station>> getRecents() async => _read();

  @override
  Future<void> add(Station station) async {
    final current = _read()..removeWhere((s) => s.uuid == station.uuid);
    final next = [station, ...current].take(_max).toList();
    await _write(next);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }

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
    await _prefs.setString(
      _key,
      jsonEncode(stations.map(stationToJson).toList()),
    );
  }
}
