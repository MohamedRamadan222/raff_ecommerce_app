import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/paginated_products_entity.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_by_category_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;

  ProductsCubit({
    required this.getProductsUseCase,
    required this.getProductsByCategoryUseCase,
  }) : super(const ProductsInitial());

  static const int _limit = 10;
  String? _currentCategorySlug;

  Future<void> loadProducts({String? categorySlug}) async {
    _currentCategorySlug = categorySlug;
    emit(const ProductsLoading());
    final result = await _fetchPage(skip: 0);
    if (isClosed) return;

    result.fold(
      (failure) => emit(ProductsFailure(failure)),
      (paginated) => emit(
        ProductsSuccess(
          products: paginated.products,
          hasMore: paginated.hasMore,
        ),
      ),
    );
  }

  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! ProductsSuccess) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    final result = await _fetchPage(skip: currentState.products.length);
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

  Future<Either<Failure, PaginatedProductsEntity>> _fetchPage({
    required int skip,
  }) {
    if (_currentCategorySlug != null && _currentCategorySlug!.isNotEmpty) {
      return getProductsByCategoryUseCase(
        categorySlug: _currentCategorySlug!,
        limit: _limit,
        skip: skip,
      );
    }
    return getProductsUseCase(limit: _limit, skip: skip);
  }
}
