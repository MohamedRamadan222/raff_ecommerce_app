import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:raff_app/features/cart/data/models/cart_item_model.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Either<Failure, List<CartItemEntity>> getCartItems() {
    try {
      return Right(localDataSource.getCartItems());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> addToCart(
    ProductEntity product, {
    int quantity = 1,
    String? colorHex,
  }) async {
    try {
      final model = CartItemModel(
        product: product,
        quantity: quantity,
        colorHex: colorHex,
      );
      await localDataSource.addToCart(model);
      return Right(localDataSource.getCartItems());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> updateQuantity(
    int productId,
    int quantity,
  ) async {
    try {
      await localDataSource.updateQuantity(productId, quantity);
      return Right(localDataSource.getCartItems());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> removeFromCart(
    int productId,
  ) async {
    try {
      await localDataSource.removeFromCart(productId);
      return Right(localDataSource.getCartItems());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return const Right([]);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
