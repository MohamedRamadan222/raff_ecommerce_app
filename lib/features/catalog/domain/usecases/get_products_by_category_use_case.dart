import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/repositories/catalog_repository.dart';

import '../entities/paginated_products_entity.dart';

class GetProductsByCategoryUseCase {
  final CatalogRepository _repository;

  const GetProductsByCategoryUseCase(this._repository);

  Future<Either<Failure, PaginatedProductsEntity>> call({
    required String categorySlug,
    int limit = 10,
    int skip = 0,
  }) {
    return _repository.getProductsByCategory(
      categorySlug: categorySlug,
      limit: limit,
      skip: skip,
    );
  }
}
