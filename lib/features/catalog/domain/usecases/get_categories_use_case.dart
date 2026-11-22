import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/repositories/catalog_repository.dart';

import '../entities/category_entity.dart';

class GetCategoriesUseCase {
  final CatalogRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return _repository.getCategories();
  }
}
