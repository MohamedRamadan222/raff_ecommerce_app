import 'package:raff_app/features/catalog/data/mappers/product_mapper.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

class FavoriteProductModel extends ProductEntity {
  const FavoriteProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    super.brand,
    required super.thumbnail,
    required super.images,
  });

  factory FavoriteProductModel.fromEntity(ProductEntity entity) {
    return FavoriteProductModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      price: entity.price,
      discountPercentage: entity.discountPercentage,
      rating: entity.rating,
      stock: entity.stock,
      brand: entity.brand,
      thumbnail: entity.thumbnail,
      images: entity.images,
    );
  }

  factory FavoriteProductModel.fromJson(Map<String, dynamic> json) {
    final product = ProductMapper.fromJson(json);
    return FavoriteProductModel(
      id: product.id,
      title: product.title,
      description: product.description,
      category: product.category,
      price: product.price,
      discountPercentage: product.discountPercentage,
      rating: product.rating,
      stock: product.stock,
      brand: product.brand,
      thumbnail: product.thumbnail,
      images: product.images,
    );
  }

  Map<String, dynamic> toJson() => ProductMapper.toSummaryJson(this);
}
