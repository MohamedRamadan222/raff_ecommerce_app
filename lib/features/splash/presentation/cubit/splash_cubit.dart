import 'package:bloc/bloc.dart';
import 'package:raff_app/features/splash/domain/splash_repository.dart';
import 'package:raff_app/features/splash/presentation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final SplashRepository splashRepository;

  SplashCubit({required this.splashRepository}) : super(SplashInitial());

  Future<void> determineDestination() async {
    final hasSeenOnboarding = await splashRepository.checkHasSeenOnboarding();
    if (!hasSeenOnboarding) {
      emit(NavigateToOnboarding());
      return;
    }

    final isLoggedIn = await splashRepository.checkIsLoggedIn();
    final isGuest = await splashRepository.checkIsGuest();

    if (isLoggedIn || isGuest) {
      emit(NavigateToHome());
    } else {
      emit(NavigateToLogin());
    }
  }
}
