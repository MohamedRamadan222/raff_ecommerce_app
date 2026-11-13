import 'package:get_it/get_it.dart';
import 'package:raff_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:raff_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:raff_app/features/splash/data/splash_repository_impl.dart';
import 'package:raff_app/features/splash/domain/splash_repository.dart';
import 'package:raff_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/preferences_service.dart';

final sl = GetIt.instance;

Future<void> setUpGetIt() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  sl.registerLazySingleton<PreferencesService>(
    () => PreferencesService(sharedPrefs: sl()),
  );
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(sharedPrefs: sl()),
  );

  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sharedPrefs: sl()),
  );

  sl.registerFactory<SplashCubit>(() => SplashCubit(splashRepository: sl()));

  sl.registerFactory<OnboardingCubit>(() => OnboardingCubit(repository: sl()));
}
