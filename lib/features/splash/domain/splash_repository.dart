abstract class SplashRepository {
  Future<bool> checkHasSeenOnboarding();

  Future<bool> checkIsLoggedIn();

  Future<bool> checkIsGuest();
}
