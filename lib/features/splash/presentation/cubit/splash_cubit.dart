import 'package:bloc/bloc.dart';
import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:raff_app/features/splash/presentation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final OnboardingRepository _onboardingRepository;
  final Future<bool> Function() _checkUserLoggedIn;

  SplashCubit({
    required this._onboardingRepository,
    required this._checkUserLoggedIn,
  }) : super(SplashInitial());

  Future<void> decideNextRoute() async {
    final loggedInFuture = _checkUserLoggedIn();
    await Future.delayed(const Duration(milliseconds: 1500));
    final isLoggedIn = await loggedInFuture;
    final isOnboardingSeen = _onboardingRepository.isOnboardingSeen();
    if (isClosed) return;

    if (!isOnboardingSeen) {
      emit(SplashNavigate(SplashDestination.onboarding));
    } else if (!isLoggedIn) {
      emit(SplashNavigate(SplashDestination.login));
    } else {
      emit(SplashNavigate(SplashDestination.home));
    }
  }
}
