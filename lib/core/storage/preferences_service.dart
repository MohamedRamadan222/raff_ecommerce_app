import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences sharedPrefs;

  PreferencesService({required this.sharedPrefs});

  static const String _themeKey = 'theme_mode';
  static const String _langKey = 'language_code';

  // save theme
  Future<void> saveThemeMode(String themeMode) async {
    await sharedPrefs.setString(_themeKey, themeMode);
  }

  // load theme
  Future<String> loadThemeMode() async {
    return sharedPrefs.getString(_themeKey) ?? 'system';
  }

  Future<void> saveLanguageCode(String code) async {
    await sharedPrefs.setString(_langKey, code);
  }

  // load language
  Future<String> loadLanguageCode() async {
    final savedLang = sharedPrefs.getString(_langKey);

    if (savedLang != null) {
      return savedLang;
    }
    // this is the first time getting the lang
    final systemLang = PlatformDispatcher.instance.locale.languageCode;
    return (systemLang == 'ar') ? 'ar' : 'en';
  }
}
