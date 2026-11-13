import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final SharedPreferences _sharedPrefs;

  OnboardingRepositoryImpl({required this._sharedPrefs});

  @override
  Future<void> saveHasSeenOnboarding() async {
    await _sharedPrefs.setBool('hasSeenOnboarding', true);
  }

  @override
  Future<void> saveIsGuest() async {
    await _sharedPrefs.setBool('isGuest', true);
  }
}
