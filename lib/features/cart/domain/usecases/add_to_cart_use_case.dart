import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<Either<Failure, List<CartItemEntity>>> call(
    ProductEntity product, {
    int quantity = 1,
    String? colorHex,
  }) {
    return repository.addToCart(
      product,
      quantity: quantity,
      colorHex: colorHex,
    );
  }
}
