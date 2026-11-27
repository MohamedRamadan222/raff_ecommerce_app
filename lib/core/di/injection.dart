import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raff_app/core/network/dio_clint.dart';
import 'package:raff_app/core/session/session_cleaner.dart';
import 'package:raff_app/core/session/session_cubit.dart';
import 'package:raff_app/core/widgets/app_image_cache.dart';
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
import 'package:raff_app/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:raff_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:raff_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:raff_app/features/splash/data/splash_repository_impl.dart';
import 'package:raff_app/features/splash/domain/splash_repository.dart';
import 'package:raff_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/notifications/data/datasources/notifications_local_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/add_notification_use_case.dart';
import '../../features/notifications/domain/usecases/get_notifications_use_case.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/orders/data/datasources/orders_local_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_orders_use_case.dart';
import '../../features/orders/domain/usecases/place_order_use_case.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/addresses/data/datasources/addresses_local_data_source.dart';
import '../../features/addresses/data/repositories/addresses_repository_impl.dart';
import '../../features/addresses/domain/repositories/addresses_repository.dart';
import '../../features/addresses/domain/usecases/add_address_use_case.dart';
import '../../features/addresses/domain/usecases/delete_address_use_case.dart';
import '../../features/addresses/domain/usecases/get_addresses_use_case.dart';
import '../../features/addresses/domain/usecases/set_default_address_use_case.dart';
import '../../features/addresses/domain/usecases/update_address_use_case.dart';
import '../../features/addresses/presentation/cubit/addresses_cubit.dart';
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart_use_case.dart';
import '../../features/cart/domain/usecases/clear_cart_use_case.dart';
import '../../features/cart/domain/usecases/get_cart_items_use_case.dart';
import '../../features/cart/domain/usecases/remove_from_cart_use_case.dart';
import '../../features/cart/domain/usecases/update_cart_quantity_use_case.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/catalog/data/datasources/catalog_remote_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/usecases/get_categories_use_case.dart';
import '../../features/catalog/domain/usecases/get_product_details_use_case.dart';
import '../../features/catalog/domain/usecases/get_products_by_category_use_case.dart';
import '../../features/catalog/domain/usecases/get_products_use_case.dart';
import '../../features/catalog/domain/usecases/invalidate_catalog_cache_use_case.dart';
import '../../features/catalog/domain/usecases/search_products_use_case.dart';
import '../../features/catalog/presentation/cubit/home_cubit.dart';
import '../../features/catalog/presentation/cubit/product_details_cubit.dart';
import '../../features/catalog/presentation/cubit/products_cubit.dart';
import '../../features/catalog/presentation/cubit/search_cubit.dart';
import '../../features/favorites/data/datasources/favorites_local_data_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/get_favorites_use_case.dart';
import '../../features/favorites/domain/usecases/toggle_favorite_use_case.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
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

  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(repository: sl(), session: sl()),
  );
  // Auth => Local
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SessionCubit>(() => SessionCubit(sl()));

  // Auth => Login
  sl.registerLazySingleton<DioClint>(() => DioClint());
  sl.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl(), session: sl()));

  // Auth => Register
  sl.registerLazySingleton<RegisterRemoteDataSource>(
    () => RegisterRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RegisterRepository>(
    () => RegisterRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl(), session: sl()));

  // ==================== Catalog Feature ====================

  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailsUseCase(sl()));
  sl.registerLazySingleton(() => InvalidateCatalogCacheUseCase(sl()));

  sl.registerFactory(
    () => HomeCubit(
      getProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
      invalidateCatalogCacheUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductsCubit(
      getProductsUseCase: sl(),
      getProductsByCategoryUseCase: sl(),
      invalidateCatalogCacheUseCase: sl(),
    ),
  );

  sl.registerFactory(() => SearchCubit(sl()));

  sl.registerFactory(() => ProductDetailsCubit(sl()));

  // Local Storage (Hive)
  // The boxes are independent; open them concurrently instead of serially
  // blocking startup on each disk read.
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  final boxes = await Future.wait<Box<String>>([
    Hive.openBox<String>('favorites_box'),
    Hive.openBox<String>('cart_box'),
    Hive.openBox<String>('addresses_box'),
    Hive.openBox<String>('orders_box'),
    Hive.openBox<String>('notifications_box'),
  ]);
  final favoritesBox = boxes[0];
  final cartBox = boxes[1];
  final addressesBox = boxes[2];
  final ordersBox = boxes[3];
  final notificationsBox = boxes[4];

  sl.registerLazySingleton<Box<String>>(
    () => favoritesBox,
    instanceName: 'favoritesBox',
  );
  sl.registerLazySingleton<Box<String>>(() => cartBox, instanceName: 'cartBox');
  // ==================== Favorites Feature ====================
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sl(instanceName: 'favoritesBox')),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerFactory(
    () =>
        FavoritesCubit(getFavoritesUseCase: sl(), toggleFavoriteUseCase: sl()),
  );

  // ===> Cart Feature
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sl(instanceName: 'cartBox')),
  );
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantityUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  sl.registerFactory(
    () => CartCubit(
      getCartItemsUseCase: sl(),
      addToCartUseCase: sl(),
      updateCartQuantityUseCase: sl(),
      removeFromCartUseCase: sl(),
      clearCartUseCase: sl(),
    ),
  );

  // ===> Addresses Feature
  sl.registerLazySingleton<Box<String>>(
    () => addressesBox,
    instanceName: 'addressesBox',
  );
  sl.registerLazySingleton<AddressesLocalDataSource>(
    () => AddressesLocalDataSourceImpl(sl(instanceName: 'addressesBox')),
  );
  sl.registerLazySingleton<AddressesRepository>(
    () => AddressesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAddressesUseCase(sl()));
  sl.registerLazySingleton(() => AddAddressUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAddressUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAddressUseCase(sl()));
  sl.registerLazySingleton(() => SetDefaultAddressUseCase(sl()));
  sl.registerFactory(
    () => AddressesCubit(
      getAddressesUseCase: sl(),
      addAddressUseCase: sl(),
      updateAddressUseCase: sl(),
      deleteAddressUseCase: sl(),
      setDefaultAddressUseCase: sl(),
    ),
  );

  // ===> Orders Feature
  sl.registerLazySingleton<Box<String>>(
    () => ordersBox,
    instanceName: 'ordersBox',
  );
  sl.registerLazySingleton<OrdersLocalDataSource>(
    () => OrdersLocalDataSourceImpl(sl(instanceName: 'ordersBox')),
  );
  sl.registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => PlaceOrderUseCase(sl()));
  sl.registerFactory(
    () => OrdersCubit(getOrdersUseCase: sl(), placeOrderUseCase: sl()),
  );

  // ===> Notifications Feature
  sl.registerLazySingleton<Box<String>>(
    () => notificationsBox,
    instanceName: 'notificationsBox',
  );
  sl.registerLazySingleton<NotificationsLocalDataSource>(
    () =>
        NotificationsLocalDataSourceImpl(sl(instanceName: 'notificationsBox')),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => AddNotificationUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));
  sl.registerFactory(
    () => NotificationsCubit(
      getNotificationsUseCase: sl(),
      addNotificationUseCase: sl(),
      markNotificationReadUseCase: sl(),
      markAllNotificationsReadUseCase: sl(),
    ),
  );

  // ===> Session / logout
  sl.registerLazySingleton<SessionCleaner>(
    () => SessionCleaner(
      cartLocalDataSource: sl(),
      favoritesLocalDataSource: sl(),
      addressesLocalDataSource: sl(),
      ordersLocalDataSource: sl(),
      notificationsLocalDataSource: sl(),
      authLocalDataSource: sl(),
      sharedPreferences: sl(),
      clearDiskImageCache: AppImageCache.manager.emptyCache,
    ),
  );

  // ===> Checkout
  sl.registerFactory(
    () => CheckoutCubit(
      placeOrderUseCase: sl(),
      addNotificationUseCase: sl(),
      clearCartUseCase: sl(),
    ),
  );
}
