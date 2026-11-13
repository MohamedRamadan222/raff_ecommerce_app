abstract class OnboardingRepository {
  Future<void> saveHasSeenOnboarding();
  Future<void> saveIsGuest();
}