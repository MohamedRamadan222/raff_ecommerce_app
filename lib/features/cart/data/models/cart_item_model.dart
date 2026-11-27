import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/catalog/data/mappers/product_mapper.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.product,
    required super.quantity,
    super.colorHex,
  });

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      product: entity.product,
      quantity: entity.quantity,
      colorHex: entity.colorHex,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productMap = json['product'] as Map<String, dynamic>? ?? const {};

    return CartItemModel(
      product: ProductMapper.fromJson(productMap),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      colorHex: json['colorHex'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': ProductMapper.toSummaryJson(product),
      'quantity': quantity,
      'colorHex': colorHex,
    };
  }
}
