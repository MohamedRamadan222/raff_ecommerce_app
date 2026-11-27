import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract final class AppImageCache {
  /// Use the package's default manager (200 objects / 30 days). A separate
  /// custom cache key left the Linux cache empty, so images never resolved;
  /// the default key also reuses the existing on-disk image cache.
  static final CacheManager manager = DefaultCacheManager();
}
