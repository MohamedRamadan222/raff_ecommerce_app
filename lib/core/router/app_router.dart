import 'package:go_router/go_router.dart';
import 'package:raff_app/features/account/presentation/screens/account_screen.dart';
import 'package:raff_app/features/addresses/presentation/screens/addresses_screen.dart';
import 'package:raff_app/features/auth/presentation/screens/login_screen.dart';
import 'package:raff_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:raff_app/features/auth/presentation/screens/register_screen.dart';
import 'package:raff_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:raff_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:raff_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:raff_app/features/checkout/presentation/screens/order_confirmation_screen.dart';
import 'package:raff_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:raff_app/features/home/presentation/screens/home_screen.dart';
import 'package:raff_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:raff_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:raff_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:raff_app/features/orders/presentation/screens/track_order_screen.dart';
import 'package:raff_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:raff_app/features/products/presentation/screens/products_screen.dart';
import 'package:raff_app/features/search/presentation/screens/search_screen.dart';
import 'package:raff_app/features/splash/presentation/screens/splash_screen.dart';

import '../widgets/design_system_screen.dart';
import 'app_routes.dart';
import 'main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/design-system',
  routes: [
    GoRoute(
      path: '/design-system',
      builder: (_, _) => const DesignSystemScreen(),
    ),
    // باقي الـ routes زي ما هي
    // final appRouter = GoRouter(
    //   initialLocation: AppRoutes.splash,
    //   routes: [
    //     GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, _) => const RegisterScreen(),
    ),
    GoRoute(path: AppRoutes.otp, builder: (_, _) => const OtpScreen()),

    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => MainShell(shell: shell),
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
      builder: (_, _) => const ProductsScreen(),
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      builder: (_, _) => const ProductDetailsScreen(),
    ),
    GoRoute(path: AppRoutes.search, builder: (_, _) => const SearchScreen()),
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
