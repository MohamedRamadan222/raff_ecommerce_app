import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/core/network/failure_mapper.dart';
import 'package:raff_app/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/paginated_products_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remoteDataSource;

  CatalogRepositoryImpl(this._remoteDataSource);

  static const Duration _categoriesTtl = Duration(minutes: 5);
  static const Duration _productsTtl = Duration(seconds: 60);
  static const Duration _searchTtl = Duration(seconds: 30);
  static const Duration _productDetailsTtl = Duration(minutes: 2);
  static const int _maxEntriesPerCache = 64;

  final Map<String, _CacheEntry<List<CategoryEntity>>> _categoriesCache = {};
  final Map<String, _CacheEntry<PaginatedProductsEntity>> _productsCache = {};
  final Map<String, _CacheEntry<PaginatedProductsEntity>> _searchCache = {};
  final Map<String, _CacheEntry<ProductEntity>> _productDetailsCache = {};

  final Map<String, Future<Either<Failure, List<CategoryEntity>>>>
  _categoriesInFlight = {};
  final Map<String, Future<Either<Failure, PaginatedProductsEntity>>>
  _productsInFlight = {};
  final Map<String, Future<Either<Failure, PaginatedProductsEntity>>>
  _searchInFlight = {};
  final Map<String, Future<Either<Failure, ProductEntity>>>
  _productDetailsInFlight = {};

  /// Bumped on every invalidation so requests started before it cannot write
  /// stale data into the caches.
  int _cacheGeneration = 0;

  @override
  void invalidateCache() {
    _cacheGeneration++;
    _categoriesCache.clear();
    _productsCache.clear();
    _searchCache.clear();
    _productDetailsCache.clear();
    // Drop in-flight requests too: a pull-to-refresh must not join a request
    // that was started before the invalidation.
    _categoriesInFlight.clear();
    _productsInFlight.clear();
    _searchInFlight.clear();
    _productDetailsInFlight.clear();
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() {
    return _cached(
      key: 'categories',
      ttl: _categoriesTtl,
      cache: _categoriesCache,
      inFlight: _categoriesInFlight,
      load: () => _remoteDataSource.getCategories(),
    );
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(int id) {
    return _cached(
      key: 'details:$id',
      ttl: _productDetailsTtl,
      cache: _productDetailsCache,
      inFlight: _productDetailsInFlight,
      load: () => _remoteDataSource.getProductDetails(id),
    );
  }

  @override
  Future<Either<Failure, PaginatedProductsEntity>> getProducts({
    int limit = 10,
    int skip = 0,
  }) {
    return _cached(
      key: 'products:$limit:$skip:',
      ttl: _productsTtl,
      cache: _productsCache,
      inFlight: _productsInFlight,
      load: () => _remoteDataSource.getProducts(limit: limit, skip: skip),
    );
  }

  @override
  Future<Either<Failure, PaginatedProductsEntity>> getProductsByCategory({
    required String categorySlug,
    int limit = 10,
    int skip = 0,
  }) {
    return _cached(
      key: 'category:$categorySlug:$limit:$skip',
      ttl: _productsTtl,
      cache: _productsCache,
      inFlight: _productsInFlight,
      load: () => _remoteDataSource.getProductsByCategory(
        categorySlug: categorySlug,
        limit: limit,
        skip: skip,
      ),
    );
  }

  @override
  Future<Either<Failure, PaginatedProductsEntity>> searchProducts({
    required String query,
    int limit = 10,
    int skip = 0,
  }) {
    return _cached(
      key: 'search:$query:$limit:$skip',
      ttl: _searchTtl,
      cache: _searchCache,
      inFlight: _searchInFlight,
      load: () => _remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
      ),
    );
  }

  Future<Either<Failure, T>> _cached<T>({
    required String key,
    required Duration ttl,
    required Map<String, _CacheEntry<T>> cache,
    required Map<String, Future<Either<Failure, T>>> inFlight,
    required Future<T> Function() load,
  }) {
    final cached = cache[key];
    if (cached != null) {
      if (!cached.isExpired) {
        return Future.value(Right(cached.value));
      }
      cache.remove(key);
    }

    final pending = inFlight[key];
    if (pending != null) return pending;

    final generation = _cacheGeneration;
    late final Future<Either<Failure, T>> future;
    future = _safeCall(load)
        .then((result) {
          // Ignore results from requests started before the last invalidation;
          // otherwise an old response could overwrite fresher data.
          if (generation == _cacheGeneration) {
            result.fold((_) {}, (value) {
              cache[key] = _CacheEntry<T>(value, DateTime.now().add(ttl));
              _prune(cache);
            });
          }
          return result;
        })
        .whenComplete(() {
          // Only remove our own entry: after an invalidation a newer request
          // may already own this key.
          if (identical(inFlight[key], future)) {
            inFlight.remove(key);
          }
        });

    inFlight[key] = future;
    return future;
  }

  void _prune<T>(Map<String, _CacheEntry<T>> cache) {
    cache.removeWhere((_, entry) => entry.isExpired);
    while (cache.length > _maxEntriesPerCache) {
      cache.remove(cache.keys.first);
    }
  }

  Future<Either<Failure, T>> _safeCall<T>(Future<T> Function() call) async {
    try {
      final res = await call();
      return Right(res);
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  const _CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
