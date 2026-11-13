import 'package:bloc/bloc.dart';
import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:raff_app/features/onboarding/presentation/cubit/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingCubit({required this._repository}) : super(OnboardingInitial());

  Future<void> goToLogin() async {
    await _repository.saveHasSeenOnboarding();
    emit(NavigateToLogin());
  }

  Future<void> continueAsGuest() async {
    await _repository.saveHasSeenOnboarding();
    await _repository.saveIsGuest();
    emit(NavigateToHome());
  }
}
