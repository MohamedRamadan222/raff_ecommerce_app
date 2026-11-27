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

  /// Changes when sort/filter settings change, even if the visible list is
  /// identical, so the filter chips still rebuild.
  final int filtersRevision;

  const ProductsSuccess({
    required this.products,
    required this.hasMore,
    this.isLoadingMore = false,
    this.paginationFailure,
    this.filtersRevision = 0,
  });

  ProductsSuccess copyWith({
    List<ProductEntity>? products,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? paginationFailure,
    bool clearPaginationFailure = false,
    int? filtersRevision,
  }) {
    return ProductsSuccess(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationFailure: clearPaginationFailure
          ? null
          : (paginationFailure ?? this.paginationFailure),
      filtersRevision: filtersRevision ?? this.filtersRevision,
    );
  }

  @override
  List<Object?> get props => [
    products,
    hasMore,
    isLoadingMore,
    paginationFailure,
    filtersRevision,
  ];
}

class ProductsFailure extends ProductsState {
  final Failure failure;

  const ProductsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
