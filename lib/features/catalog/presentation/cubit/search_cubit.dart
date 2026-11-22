import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:raff_app/features/catalog/domain/usecases/search_products_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchProductsUseCase searchProductsUseCase;

  SearchCubit(this.searchProductsUseCase) : super(const SearchInitial());

  static const int _limit = 10;
  Timer? _debounceTimer;
  String _currentQuery = '';

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    _currentQuery = trimmed;

    if (trimmed.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(trimmed);
    });
  }

  Future<void> _performSearch(String query) async {
    emit(const SearchLoading());

    final result = await searchProductsUseCase(
      query: query,
      limit: _limit,
      skip: 0,
    );

    if (isClosed || _currentQuery != query) return;

    result.fold(
      (failure) => emit(SearchFailure(failure)),
      (paginated) => emit(
        SearchSuccess(products: paginated.products, hasMore: paginated.hasMore),
      ),
    );
  }

  Future<void> loadMoreResults() async {
    final currentState = state;
    if (currentState is! SearchSuccess) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await searchProductsUseCase(
      query: _currentQuery,
      limit: _limit,
      skip: currentState.products.length,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        currentState.copyWith(isLoadingMore: false, paginationFailure: failure),
      ),
      (paginated) => emit(
        currentState.copyWith(
          products: [...currentState.products, ...paginated.products],
          hasMore: paginated.hasMore,
          isLoadingMore: false,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
