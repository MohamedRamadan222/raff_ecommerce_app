enum SplashDestination { onboarding, login, home }

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashNavigate extends SplashState {
  final SplashDestination destination;

  SplashNavigate(this.destination);
}
