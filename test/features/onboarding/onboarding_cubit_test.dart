import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:raff_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:raff_app/features/onboarding/presentation/cubit/onboarding_state.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository repository;

  setUp(() {
    repository = MockOnboardingRepository();
    when(() => repository.saveHasSeenOnboarding()).thenAnswer((_) async {});
    when(() => repository.saveIsGuest()).thenAnswer((_) async {});
  });

  blocTest<OnboardingCubit, OnboardingState>(
    'goToLogin saves that onboarding was seen and goes to login',
    build: () => OnboardingCubit(repository: repository),
    act: (cubit) => cubit.goToLogin(),
    expect: () => [isA<NavigateToLogin>()],
    verify: (_) {
      verify(() => repository.saveHasSeenOnboarding()).called(1);
      verifyNever(() => repository.saveIsGuest());
    },
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'continueAsGuest saves guest mode and goes to home',
    build: () => OnboardingCubit(repository: repository),
    act: (cubit) => cubit.continueAsGuest(),
    expect: () => [isA<NavigateToHome>()],
    verify: (_) {
      verify(() => repository.saveHasSeenOnboarding()).called(1);
      verify(() => repository.saveIsGuest()).called(1);
    },
  );
}
