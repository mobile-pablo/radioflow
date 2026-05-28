part of 'settings_cubit.dart';

final class SettingsState extends Equatable {
  const SettingsState({this.locale});

  final Locale? locale;

  String get languageSelection => locale?.languageCode ?? 'system';

  @override
  List<Object?> get props => [locale];
}
