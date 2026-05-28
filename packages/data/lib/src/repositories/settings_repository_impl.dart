import 'package:domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _localeKey = 'settings.locale';

  @override
  Future<String?> getLocaleCode() async => _prefs.getString(_localeKey);

  @override
  Future<void> setLocaleCode(String localeCode) async {
    await _prefs.setString(_localeKey, localeCode);
  }

  @override
  Future<bool> getFlag(String key, {required bool fallback}) async =>
      _prefs.getBool(key) ?? fallback;

  @override
  Future<void> setFlag(String key, {required bool value}) async {
    await _prefs.setBool(key, value);
  }
}
