import 'package:bloc/bloc.dart';
import 'package:raff_app/features/onboarding/presentation/cubit/onboarding_state.dart';

import '../../domain/repositories/onboarding_repository.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingCubit(this._repository) : super(const OnboardingState());

  void onPageChanged(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  Future<void> completeOnboarding() async {
    await _repository.setOnboardingSeen();
    emit(state.copyWith(isCompleted: true));
  }
}
