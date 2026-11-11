import 'package:get_it/get_it.dart';
import 'package:raff_app/core/storage/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../network/dio_clint.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  sl.registerLazySingleton(() => PreferencesService());
  sl.registerLazySingleton(() => DioClint());
  // Data Sources
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl()),
  );

  // Cubits
  sl.registerFactory(() => OnboardingCubit(sl()));
  sl.registerFactory(
    () => SplashCubit(
      onboardingRepository: sl(),
      checkUserLoggedIn: () async =>
          false, // تُربط بـ AuthRepository في المرحلة التالية
    ),
  );
}
