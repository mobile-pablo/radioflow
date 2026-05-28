abstract interface class SettingsRepository {
  Future<String?> getLocaleCode();

  Future<void> setLocaleCode(String localeCode);
}
