import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:raff_app/features/favorites/domain/repositories/favorites_repository.dart';

import '../models/favorite_product_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl(this.localDataSource);

  @override
  Either<Failure, List<ProductEntity>> getFavorite() {
    try {
      return Right(localDataSource.getFavorites());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  bool isFavorite(int productId) {
    return localDataSource.isFavorite(productId);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> toggleFavorite(
    ProductEntity product,
  ) async {
    try {
      final model = FavoriteProductModel.fromEntity(product);
      await localDataSource.toggleFavorite(model);
      return Right(localDataSource.getFavorites());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
