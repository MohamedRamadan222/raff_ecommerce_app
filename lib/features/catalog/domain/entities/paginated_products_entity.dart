import 'package:equatable/equatable.dart';

import 'product_entity.dart';

class PaginatedProductsEntity extends Equatable {
  final List<ProductEntity> products;
  final int total;
  final int skip;
  final int limit;

  const PaginatedProductsEntity({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => (skip + products.length) < total;

  @override
  List<Object?> get props => [products, total, skip, limit];
}
