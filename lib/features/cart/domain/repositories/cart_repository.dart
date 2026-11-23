import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

abstract class CartRepository {
  Either<Failure, List<CartItemEntity>> getCartItems();

  Future<Either<Failure, List<CartItemEntity>>> addToCart(
    ProductEntity product, {
    int quantity = 1,
    String? colorHex,
  });

  Future<Either<Failure, List<CartItemEntity>>> updateQuantity(
    int productId,
    int quantity,
  );

  Future<Either<Failure, List<CartItemEntity>>> removeFromCart(int productId);

  Future<Either<Failure, List<CartItemEntity>>> clearCart();
}
