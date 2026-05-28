part of 'settings_cubit.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    this.locale,
    this.pureBlack = false,
    this.highQuality = false,
    this.keepOffline = true,
  });

  final Locale? locale;
  final bool pureBlack;
  final bool highQuality;
  final bool keepOffline;

  String get languageSelection => locale?.languageCode ?? 'system';

  SettingsState copyWith({
    Locale? locale,
    bool clearLocale = false,
    bool? pureBlack,
    bool? highQuality,
    bool? keepOffline,
  }) {
    return SettingsState(
      locale: clearLocale ? null : (locale ?? this.locale),
      pureBlack: pureBlack ?? this.pureBlack,
      highQuality: highQuality ?? this.highQuality,
      keepOffline: keepOffline ?? this.keepOffline,
    );
  }

  @override
  List<Object?> get props => [locale, pureBlack, highQuality, keepOffline];
}
