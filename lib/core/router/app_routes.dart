class AppRoutes {
  // البداية
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';

  // التابات
  static const home = '/home';
  static const categories = '/categories';
  static const cart = '/cart';
  static const favorites = '/favorites';
  static const account = '/account';

  // التسوق
  static const products = '/products';
  static const productDetails = '/product/:id';
  static const search = '/search';

  // الدفع
  static const checkout = '/checkout';
  static const orderConfirmation = '/order-confirmation';

  // الحساب
  static const orders = '/orders';
  static const trackOrder = '/orders/:id/track';
  static const notifications = '/notifications';
  static const addresses = '/addresses';
}
