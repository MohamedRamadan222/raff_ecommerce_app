import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/features/splash/domain/splash_repository.dart';
import 'package:raff_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:raff_app/features/splash/presentation/cubit/splash_state.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  late MockSplashRepository repository;

  setUp(() => repository = MockSplashRepository());

  void stub({
    bool seenOnboarding = true,
    bool loggedIn = false,
    bool guest = false,
  }) {
    when(() => repository.checkHasSeenOnboarding())
        .thenAnswer((_) async => seenOnboarding);
    when(() => repository.checkIsLoggedIn()).thenAnswer((_) async => loggedIn);
    when(() => repository.checkIsGuest()).thenAnswer((_) async => guest);
  }

  blocTest<SplashCubit, SplashState>(
    'goes to onboarding on the first launch',
    build: () {
      stub(seenOnboarding: false);
      return SplashCubit(splashRepository: repository);
    },
    act: (cubit) => cubit.determineDestination(),
    expect: () => [isA<NavigateToOnboarding>()],
  );

  blocTest<SplashCubit, SplashState>(
    'goes to home for a logged in user',
    build: () {
      stub(loggedIn: true);
      return SplashCubit(splashRepository: repository);
    },
    act: (cubit) => cubit.determineDestination(),
    expect: () => [isA<NavigateToHome>()],
  );

  blocTest<SplashCubit, SplashState>(
    'goes to home for a guest',
    build: () {
      stub(guest: true);
      return SplashCubit(splashRepository: repository);
    },
    act: (cubit) => cubit.determineDestination(),
    expect: () => [isA<NavigateToHome>()],
  );

  blocTest<SplashCubit, SplashState>(
    'goes to login when onboarding is done but nobody is signed in',
    build: () {
      stub();
      return SplashCubit(splashRepository: repository);
    },
    act: (cubit) => cubit.determineDestination(),
    expect: () => [isA<NavigateToLogin>()],
  );
}
