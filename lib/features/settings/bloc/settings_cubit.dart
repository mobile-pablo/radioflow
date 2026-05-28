import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  static const String _systemValue = 'system';
  static const String _pureBlackKey = 'theme.pureBlack';
  static const String _highQualityKey = 'playback.highQuality';
  static const String _keepOfflineKey = 'data.keepOffline';

  Future<void> load() async {
    final code = await _repository.getLocaleCode();
    final pureBlack = await _repository.getFlag(_pureBlackKey, fallback: false);
    final highQuality = await _repository.getFlag(
      _highQualityKey,
      fallback: false,
    );
    final keepOffline = await _repository.getFlag(
      _keepOfflineKey,
      fallback: true,
    );
    emit(
      SettingsState(
        locale: _toLocale(code),
        pureBlack: pureBlack,
        highQuality: highQuality,
        keepOffline: keepOffline,
      ),
    );
  }

  Future<void> setLanguage(String? languageCode) async {
    await _repository.setLocaleCode(languageCode ?? _systemValue);
    emit(
      languageCode == null
          ? state.copyWith(clearLocale: true)
          : state.copyWith(locale: Locale(languageCode)),
    );
  }

  Future<void> setPureBlack({required bool value}) async {
    await _repository.setFlag(_pureBlackKey, value: value);
    emit(state.copyWith(pureBlack: value));
  }

  Future<void> setHighQuality({required bool value}) async {
    await _repository.setFlag(_highQualityKey, value: value);
    emit(state.copyWith(highQuality: value));
  }

  Future<void> setKeepOffline({required bool value}) async {
    await _repository.setFlag(_keepOfflineKey, value: value);
    emit(state.copyWith(keepOffline: value));
  }

  Locale? _toLocale(String? code) {
    if (code == null || code.isEmpty || code == _systemValue) return null;
    return Locale(code);
  }
}
