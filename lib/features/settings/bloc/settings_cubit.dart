import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  static const String _systemValue = 'system';

  Future<void> load() async {
    final code = await _repository.getLocaleCode();
    emit(SettingsState(locale: _toLocale(code)));
  }

  Future<void> setLanguage(String? languageCode) async {
    await _repository.setLocaleCode(languageCode ?? _systemValue);
    emit(
      SettingsState(locale: languageCode == null ? null : Locale(languageCode)),
    );
  }

  Locale? _toLocale(String? code) {
    if (code == null || code.isEmpty || code == _systemValue) return null;
    return Locale(code);
  }
}
