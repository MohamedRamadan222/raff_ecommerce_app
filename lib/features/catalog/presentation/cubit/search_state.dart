import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchSuccess extends SearchState {
  final List<ProductEntity> products;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? paginationFailure;

  const SearchSuccess({
    required this.products,
    required this.hasMore,
    this.isLoadingMore = false,
    this.paginationFailure,
  });

  SearchSuccess copyWith({
    List<ProductEntity>? products,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? paginationFailure,
    bool clearPaginationFailure = false,
  }) {
    return SearchSuccess(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationFailure: clearPaginationFailure
          ? null
          : (paginationFailure ?? this.paginationFailure),
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

class SearchFailure extends SearchState {
  final Failure failure;

  const SearchFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
