import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/router/main_shell.dart';
import 'package:raff_app/features/account/presentation/screens/account_screen.dart';
import 'package:raff_app/features/addresses/presentation/screens/addresses_screen.dart';
import 'package:raff_app/features/auth/presentation/screens/login_screen.dart';
import 'package:raff_app/features/auth/presentation/screens/register_screen.dart';
import 'package:raff_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/product_details_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/search_cubit.dart';
import 'package:raff_app/features/catalog/presentation/screens/categories_screen.dart';
import 'package:raff_app/features/catalog/presentation/screens/home_screen.dart';
import 'package:raff_app/features/catalog/presentation/screens/product_details_screen.dart';
import 'package:raff_app/features/catalog/presentation/screens/products_screen.dart';
import 'package:raff_app/features/catalog/presentation/screens/search_screen.dart';
import 'package:raff_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:raff_app/features/checkout/presentation/screens/order_confirmation_screen.dart';
import 'package:raff_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:raff_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:raff_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:raff_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:raff_app/features/orders/presentation/screens/track_order_screen.dart';
import 'package:raff_app/features/splash/presentation/screens/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, _) => const RegisterScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => BlocProvider(
        create: (_) => sl<HomeCubit>()..loadHomeData(),
        child: MainShell(shell: shell),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, _) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.categories,
              builder: (_, _) => const CategoriesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (_, _) => const CartScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (_, _) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.account,
              builder: (_, _) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.products,
      builder: (_, state) {
        final args = state.extra as Map<String, dynamic>?;
        final categorySlug = args?['slug'] as String?;
        final categoryName = args?['name'] as String?;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  sl<ProductsCubit>()..loadProducts(categorySlug: categorySlug),
            ),
            BlocProvider(create: (_) => sl<HomeCubit>()..loadHomeData()),
          ],
          child: ProductsScreen(
            initialCategorySlug: categorySlug,
            initialCategoryName: categoryName,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      builder: (_, state) {
        final productId = state.extra is int
            ? state.extra as int
            : int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return BlocProvider(
          create: (_) =>
              sl<ProductDetailsCubit>()..loadProductDetails(productId),
          child: const ProductDetailsScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (_, _) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<SearchCubit>()),
          BlocProvider(create: (_) => sl<HomeCubit>()..loadHomeData()),
        ],
        child: const SearchScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      builder: (_, _) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderConfirmation,
      builder: (_, _) => const OrderConfirmationScreen(),
    ),
    GoRoute(path: AppRoutes.orders, builder: (_, _) => const OrdersScreen()),
    GoRoute(
      path: AppRoutes.trackOrder,
      builder: (_, _) => const TrackOrderScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (_, _) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.addresses,
      builder: (_, _) => const AddressesScreen(),
    ),
  ],
);
