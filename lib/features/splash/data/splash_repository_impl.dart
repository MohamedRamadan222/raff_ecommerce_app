import 'package:raff_app/features/splash/domain/splash_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashRepositoryImpl implements SplashRepository{
  final SharedPreferences _sharedPrefs;

  SplashRepositoryImpl({required this._sharedPrefs});

  @override
  Future<bool> checkHasSeenOnboarding() async {
    return  _sharedPrefs.getBool('hasSeenOnboarding') ?? false;
  }

  @override
  Future<bool> checkIsLoggedIn() async {
    return  _sharedPrefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Future<bool> checkIsGuest() async {
    return  _sharedPrefs.getBool('isGuest') ?? false;
  }
}