import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

abstract class FavoritesRepository {
  Either<Failure, List<ProductEntity>> getFavorite();

  Future<Either<Failure, List<ProductEntity>>> toggleFavorite(
    ProductEntity product,
  );

  bool isFavorite(int productId);
}
