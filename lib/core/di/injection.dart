import 'package:get_it/get_it.dart';
import 'package:raff_app/core/network/dio_clint.dart';
import 'package:raff_app/features/auth/data/datasources/login_remote_data_source.dart';
import 'package:raff_app/features/auth/data/datasources/register_remote_data_source.dart';
import 'package:raff_app/features/auth/data/repositories/login_repository_impl.dart';
import 'package:raff_app/features/auth/data/repositories/register_repository_impl.dart';
import 'package:raff_app/features/auth/domain/repositories/login_repository.dart';
import 'package:raff_app/features/auth/domain/repositories/register_repository.dart';
import 'package:raff_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:raff_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:raff_app/features/auth/presentation/cubit/login_cubit.dart';
import 'package:raff_app/features/auth/presentation/cubit/register_cubit.dart';
import 'package:raff_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:raff_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:raff_app/features/splash/data/splash_repository_impl.dart';
import 'package:raff_app/features/splash/domain/splash_repository.dart';
import 'package:raff_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../storage/preferences_service.dart';

final sl = GetIt.instance;

Future<void> setUpGetIt() async {
  // onboarding & splash
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  sl.registerLazySingleton<PreferencesService>(
    () => PreferencesService(sharedPrefs: sl()),
  );
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(sharedPrefs: sl()),
  );
  sl.registerFactory<SplashCubit>(() => SplashCubit(splashRepository: sl()));
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sharedPrefs: sl()),
  );

  sl.registerFactory<OnboardingCubit>(() => OnboardingCubit(repository: sl()));
  // Auth => Local
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // Auth => Login
  sl.registerLazySingleton<DioClint>(() => DioClint());
  sl.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl()));

  // Auth => Register
  sl.registerLazySingleton<RegisterRemoteDataSource>(
    () => RegisterRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RegisterRepository>(
    () => RegisterRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl()));
}
