import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/core/storage/preferences_service.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late PreferencesService service;
  late SettingsCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = PreferencesService(sharedPrefs: prefs);
    cubit = SettingsCubit(
      service,
      const SettingsState(locale: Locale('en'), themeMode: ThemeMode.system),
    );
  });

  tearDown(() => cubit.close());

  test('changeLanguage updates the state and saves the code', () async {
    await cubit.changeLanguage('ar');

    expect(cubit.state.locale, const Locale('ar'));
    expect(await service.loadLanguageCode(), 'ar');
  });

  test('changeTheme updates the state and saves the theme name', () async {
    await cubit.changeTheme(ThemeMode.dark);

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(await service.loadThemeMode(), 'dark');
  });

  test('the theme defaults to system when nothing was saved', () async {
    expect(await service.loadThemeMode(), 'system');
  });
}
