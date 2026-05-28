abstract interface class SettingsRepository {
  Future<String?> getLocaleCode();

  Future<void> setLocaleCode(String localeCode);

  Future<bool> getFlag(String key, {required bool fallback});

  Future<void> setFlag(String key, {required bool value});
}
