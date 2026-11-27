import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/paginated_products_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

abstract class CatalogRepository {
  /// Drops cached catalog responses so a pull-to-refresh hits the network.
  void invalidateCache();

  Future<Either<Failure, PaginatedProductsEntity>> getProducts({
    int limit = 10,
    int skip = 0,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, PaginatedProductsEntity>> getProductsByCategory({
    required String categorySlug,
    int limit = 10,
    int skip = 0,
  });

  Future<Either<Failure, PaginatedProductsEntity>> searchProducts({
    required String query,
    int limit = 10,
    int skip = 0,
  });

  Future<Either<Failure, ProductEntity>> getProductDetails(int id);
}
