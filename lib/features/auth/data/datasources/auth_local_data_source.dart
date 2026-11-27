import 'dart:convert';

import 'package:raff_app/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);

  UserModel? getCacheUser();

  bool get isLoggedIn;

  bool get isGuest;

  Future clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPrefs;

  static const String _cachedUserKey = 'CACHED_USER_DATA';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _isGuestKey = 'isGuest';

  AuthLocalDataSourceImpl(this._sharedPrefs);

  @override
  Future<void> cacheUser(UserModel user) async {
    await _sharedPrefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
    await _sharedPrefs.setBool(_isLoggedInKey, true);
    await _sharedPrefs.setBool(_isGuestKey, false);
  }

  @override
  Future<dynamic> clearUser() async {
    await _sharedPrefs.remove(_cachedUserKey);
    await _sharedPrefs.setBool(_isLoggedInKey, false);
    await _sharedPrefs.setBool(_isGuestKey, false);
  }

  @override
  UserModel? getCacheUser() {
    final jsonString = _sharedPrefs.getString(_cachedUserKey);
    if (jsonString == null) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;
      return UserModel.fromJson(decoded);
    } catch (_) {
      // Corrupt/stale cache must not block app startup.
      _sharedPrefs.remove(_cachedUserKey);
      return null;
    }
  }

  @override
  bool get isLoggedIn => _sharedPrefs.getBool(_isLoggedInKey) ?? false;

  @override
  bool get isGuest => _sharedPrefs.getBool(_isGuestKey) ?? false;
}
