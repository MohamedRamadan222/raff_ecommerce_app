import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

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

    final product = ProductEntity(
      id: (productMap['id'] as num?)?.toInt() ?? 0,
      title: productMap['title'] as String? ?? '',
      description: productMap['description'] as String? ?? '',
      category: productMap['category'] as String? ?? '',
      price: (productMap['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (productMap['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (productMap['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (productMap['stock'] as num?)?.toInt() ?? 0,
      brand: productMap['brand'] as String?,
      thumbnail: productMap['thumbnail'] as String? ?? '',
      images:
          (productMap['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );

    return CartItemModel(
      product: product,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      colorHex: json['colorHex'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': {
        'id': product.id,
        'title': product.title,
        'description': product.description,
        'category': product.category,
        'price': product.price,
        'discountPercentage': product.discountPercentage,
        'rating': product.rating,
        'stock': product.stock,
        'brand': product.brand,
        'thumbnail': product.thumbnail,
        'images': product.images,
      },
      'quantity': quantity,
      'colorHex': colorHex,
    };
  }
}
