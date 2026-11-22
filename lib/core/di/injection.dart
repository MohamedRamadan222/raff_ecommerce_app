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
import '../../features/catalog/data/datasources/catalog_remote_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/usecases/get_categories_use_case.dart';
import '../../features/catalog/domain/usecases/get_product_details_use_case.dart';
import '../../features/catalog/domain/usecases/get_products_by_category_use_case.dart';
import '../../features/catalog/domain/usecases/get_products_use_case.dart';
import '../../features/catalog/domain/usecases/search_products_use_case.dart';
import '../../features/catalog/presentation/cubit/home_cubit.dart';
import '../../features/catalog/presentation/cubit/product_details_cubit.dart';
import '../../features/catalog/presentation/cubit/products_cubit.dart';
import '../../features/catalog/presentation/cubit/search_cubit.dart';
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

  // ==================== Catalog Feature ====================

  // Data Sources
  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl()),
  );

  //  Use Cases
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailsUseCase(sl()));

  // 4. Cubits
  sl.registerFactory(
    () => HomeCubit(getProductsUseCase: sl(), getCategoriesUseCase: sl()),
  );

  sl.registerFactory(
    () => ProductsCubit(
      getProductsUseCase: sl(),
      getProductsByCategoryUseCase: sl(),
    ),
  );

  sl.registerFactory(() => SearchCubit(sl()));

  sl.registerFactory(() => ProductDetailsCubit(sl()));
}
