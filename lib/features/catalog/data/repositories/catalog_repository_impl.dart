import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/paginated_products_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remoteDataSource;

  CatalogRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() {
    return _safeCall(() => _remoteDataSource.getCategories());
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(int id) {
    return _safeCall(() => _remoteDataSource.getProductDetails(id));
  }

  @override
  Future<Either<Failure, PaginatedProductsEntity>> getProducts({
    int limit = 10,
    int skip = 0,
  }) {
    return _safeCall(
      () => _remoteDataSource.getProducts(limit: limit, skip: skip),
    );
  }

  @override
  Future<Either<Failure, PaginatedProductsEntity>> getProductsByCategory({
    required String categorySlug,
    int limit = 10,
    int skip = 0,
  }) {
    return _safeCall(
      () => _remoteDataSource.getProductsByCategory(
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
    return _safeCall(
      () => _remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
      ),
    );
  }

  Future<Either<Failure, T>> _safeCall<T>(Future<T> Function() call) async {
    try {
      final res = await call();
      return Right(res);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final data = e.response?.data;
        final errorMessage = data is Map
            ? (data['message']?.toString() ?? 'خطأ في السيرفر')
            : 'خطأ في السيرفر';
        return ServerFailure(errorMessage);

      default:
        return const UnknownFailure();
    }
  }
}
