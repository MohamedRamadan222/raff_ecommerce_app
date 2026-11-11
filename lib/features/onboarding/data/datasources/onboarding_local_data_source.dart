import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<void> cacheOnboardingSeen();

  bool getOnboardingSeen();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences _prefs;
  static const String _kOnboardingSeenKey = 'has_seen_onboarding';

  OnboardingLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheOnboardingSeen() async {
    await _prefs.setBool(_kOnboardingSeenKey, true);
  }

  @override
  bool getOnboardingSeen() {
    return _prefs.getBool(_kOnboardingSeenKey) ?? false;
  }
}
