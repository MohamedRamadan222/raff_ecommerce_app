import 'package:raff_app/features/catalog/domain/entities/paginated_products_entity.dart';

import 'product_model.dart';

class PaginatedProductsModel extends PaginatedProductsEntity {
  const PaginatedProductsModel({
    required super.products,
    required super.total,
    required super.skip,
    required super.limit,
  });

  factory PaginatedProductsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedProductsModel(
      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}
