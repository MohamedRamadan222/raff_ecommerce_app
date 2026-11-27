import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/domain/usecases/search_products_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchProductsUseCase searchProductsUseCase;

  SearchCubit(this.searchProductsUseCase) : super(const SearchInitial());

  static const int _limit = 10;
  static const int _maxRetainedProducts = 200;

  Timer? _debounceTimer;
  String _currentQuery = '';
  int _generation = 0;
  int _nextSkip = 0;

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();

    final generation = ++_generation;
    final trimmed = query.trim();
    _currentQuery = trimmed;

    if (trimmed.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(trimmed, generation);
    });
  }

  Future<void> _performSearch(String query, int generation) async {
    if (isClosed || generation != _generation || _currentQuery != query) return;

    emit(const SearchLoading());

    final result = await searchProductsUseCase(
      query: query,
      limit: _limit,
      skip: 0,
    );

    if (isClosed || generation != _generation || _currentQuery != query) return;

    result.fold((failure) => emit(SearchFailure(failure)), (paginated) {
      _nextSkip = paginated.skip + paginated.products.length;

      final products = _mergeProducts(
        const <ProductEntity>[],
        paginated.products,
      );
      emit(
        SearchSuccess(
          products: products,
          hasMore: paginated.hasMore && products.length < _maxRetainedProducts,
        ),
      );
    });
  }

  Future<void> loadMoreResults() async {
    if (_debounceTimer?.isActive ?? false) return;
    final currentState = state;
    if (currentState is! SearchSuccess) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    final generation = _generation;
    final query = _currentQuery;

    emit(
      currentState.copyWith(isLoadingMore: true, clearPaginationFailure: true),
    );

    final result = await searchProductsUseCase(
      query: query,
      limit: _limit,
      skip: _nextSkip,
    );

    if (isClosed || generation != _generation || _currentQuery != query) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is! SearchSuccess) return;
        emit(
          latestState.copyWith(
            isLoadingMore: false,
            paginationFailure: failure,
          ),
        );
      },
      (paginated) {
        final latestState = state;
        if (latestState is! SearchSuccess) return;

        _nextSkip = paginated.skip + paginated.products.length;
        final products = _mergeProducts(
          latestState.products,
          paginated.products,
        );

        emit(
          latestState.copyWith(
            products: products,
            hasMore:
                paginated.hasMore && products.length < _maxRetainedProducts,
            isLoadingMore: false,
            clearPaginationFailure: true,
          ),
        );
      },
    );
  }

  List<ProductEntity> _mergeProducts(
    List<ProductEntity> current,
    List<ProductEntity> incoming,
  ) {
    final seenIds = <int>{};
    final merged = <ProductEntity>[];

    for (final product in [...current, ...incoming]) {
      if (seenIds.add(product.id)) {
        merged.add(product);
      }
    }

    if (merged.length > _maxRetainedProducts) {
      return merged.sublist(0, _maxRetainedProducts);
    }
    return merged;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
