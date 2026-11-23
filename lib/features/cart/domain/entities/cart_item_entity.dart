import 'package:equatable/equatable.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final String? colorHex;

  const CartItemEntity({
    required this.product,
    required this.quantity,
    this.colorHex,
  });

  double get totalPrice => product.price * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    String? colorHex,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [product, quantity, colorHex];
}
