import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/repositories/catalog_repository.dart';

import '../entities/product_entity.dart';

class GetProductDetailsUseCase {
  final CatalogRepository _repository;

  const GetProductDetailsUseCase(this._repository);

  Future<Either<Failure, ProductEntity>> call(int id) {
    return _repository.getProductDetails(id);
  }
}
