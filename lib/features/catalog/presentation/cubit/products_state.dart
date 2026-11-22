import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsSuccess extends ProductsState {
  final List<ProductEntity> products;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? paginationFailure;

  const ProductsSuccess({
    required this.products,
    required this.hasMore,
    this.isLoadingMore = false,
    this.paginationFailure,
  });

  ProductsSuccess copyWith({
    List<ProductEntity>? products,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? paginationFailure,
  }) {
    return ProductsSuccess(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationFailure: paginationFailure,
    );
  }

  @override
  List<Object?> get props => [
    products,
    hasMore,
    isLoadingMore,
    paginationFailure,
  ];
}

class ProductsFailure extends ProductsState {
  final Failure failure;

  const ProductsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
