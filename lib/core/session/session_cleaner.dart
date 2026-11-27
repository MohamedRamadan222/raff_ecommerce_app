import 'package:flutter/painting.dart';
import 'package:raff_app/features/addresses/data/datasources/addresses_local_data_source.dart';
import 'package:raff_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:raff_app/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:raff_app/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:raff_app/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:raff_app/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clears every piece of user-scoped data when signing out.
class SessionCleaner {
  static const String _recentSearchesKey = 'RECENT_SEARCH_QUERIES';

  final CartLocalDataSource cartLocalDataSource;
  final FavoritesLocalDataSource favoritesLocalDataSource;
  final AddressesLocalDataSource addressesLocalDataSource;
  final OrdersLocalDataSource ordersLocalDataSource;
  final NotificationsLocalDataSource notificationsLocalDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final SharedPreferences sharedPreferences;

  /// Clears the on-disk image cache, when a disk cache is configured.
  final Future<void> Function()? clearDiskImageCache;

  SessionCleaner({
    required this.cartLocalDataSource,
    required this.favoritesLocalDataSource,
    required this.addressesLocalDataSource,
    required this.ordersLocalDataSource,
    required this.notificationsLocalDataSource,
    required this.authLocalDataSource,
    required this.sharedPreferences,
    this.clearDiskImageCache,
  });

  Future<void> clearAll() async {
    // Attempt every store even if one fails; logout should not be blocked by
    // a single corrupted box.
    await Future.wait([
      _safe(cartLocalDataSource.clearAll),
      _safe(favoritesLocalDataSource.clearAll),
      _safe(addressesLocalDataSource.clearAll),
      _safe(ordersLocalDataSource.clearAll),
      _safe(notificationsLocalDataSource.clearAll),
      _safe(() async {
        await sharedPreferences.remove(_recentSearchesKey);
      }),
    ]);
    await authLocalDataSource.clearUser();
    _clearImageCache();
    final clearDiskCache = clearDiskImageCache;
    if (clearDiskCache != null) {
      // Best-effort: a corrupt disk cache must not block logout.
      await _safe(clearDiskCache);
    }
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Best-effort cleanup: continue with the remaining stores.
    }
  }

  void _clearImageCache() {
    try {
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
    } on Object {
      // The Flutter binding may not be initialized in pure unit tests.
      return;
    }
  }
}
