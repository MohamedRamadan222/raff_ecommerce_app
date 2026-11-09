import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:raff_app/core/storage/preferences_service.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesService _prefs;

  SettingsCubit(this._prefs, SettingsState initialState) : super(initialState);

  Future<void> changeLanguage(String code) async {
    emit(state.copyWith(locale: Locale(code)));
    await _prefs.saveLanguageCode(code);
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    emit(state.copyWith(themeMode: themeMode));
    await _prefs.saveThemeMode(themeMode.name);
  }
}
