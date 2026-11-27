import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/paginated_products_entity.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_by_category_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/invalidate_catalog_cache_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_filter.dart';
import 'package:raff_app/features/catalog/presentation/cubit/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;
  final InvalidateCatalogCacheUseCase? invalidateCatalogCacheUseCase;

  ProductsCubit({
    required this.getProductsUseCase,
    required this.getProductsByCategoryUseCase,
    this.invalidateCatalogCacheUseCase,
  }) : super(const ProductsInitial());

  static const int _limit = 10;
  static const int _maxRetainedProducts = 200;
  static const double _defaultMaxPrice = 5000;

  String? _currentCategorySlug;
  List<ProductEntity> _allProducts = [];
  ProductSortOption _sortOption = ProductSortOption.popular;
  bool _discountsOnly = false;
  double _maxPrice = _defaultMaxPrice;
  int _generation = 0;
  int _nextSkip = 0;
  int _filtersRevision = 0;

  ProductSortOption get sortOption => _sortOption;
  bool get discountsOnly => _discountsOnly;
  double get maxPrice => _maxPrice;
  List<ProductEntity> get allProducts => List.unmodifiable(_allProducts);

  Future<void> loadProducts({
    String? categorySlug,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) invalidateCatalogCacheUseCase?.call();

    final generation = ++_generation;
    _currentCategorySlug = categorySlug;
    emit(const ProductsLoading());

    final result = await _fetchPage(skip: 0);
    if (isClosed || generation != _generation) return;

    result.fold((failure) => emit(ProductsFailure(failure)), (paginated) {
      _allProducts = _mergeProducts(
        const <ProductEntity>[],
        paginated.products,
      );
      _nextSkip = paginated.skip + paginated.products.length;
      emit(
        ProductsSuccess(
          products: _visibleProducts(),
          hasMore:
              paginated.hasMore && _allProducts.length < _maxRetainedProducts,
        ),
      );
    });
  }

  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! ProductsSuccess) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    final generation = _generation;
    emit(
      currentState.copyWith(isLoadingMore: true, clearPaginationFailure: true),
    );

    final result = await _fetchPage(skip: _nextSkip);
    if (isClosed || generation != _generation) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is! ProductsSuccess) return;
        emit(
          latestState.copyWith(
            isLoadingMore: false,
            paginationFailure: failure,
          ),
        );
      },
      (paginated) {
        final latestState = state;
        if (latestState is! ProductsSuccess) return;

        _allProducts = _mergeProducts(_allProducts, paginated.products);
        _nextSkip = paginated.skip + paginated.products.length;

        emit(
          latestState.copyWith(
            products: _visibleProducts(),
            hasMore:
                paginated.hasMore && _allProducts.length < _maxRetainedProducts,
            isLoadingMore: false,
            clearPaginationFailure: true,
          ),
        );
      },
    );
  }

  void setSortOption(ProductSortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    _emitVisibleProducts();
  }

  void setFilters({required bool discountsOnly, required double maxPrice}) {
    _discountsOnly = discountsOnly;
    _maxPrice = maxPrice;
    _emitVisibleProducts();
  }

  void resetFilters() {
    _discountsOnly = false;
    _maxPrice = _defaultMaxPrice;
    _emitVisibleProducts();
  }

  void _emitVisibleProducts() {
    final currentState = state;
    if (currentState is! ProductsSuccess) return;

    emit(
      currentState.copyWith(
        products: _visibleProducts(),
        filtersRevision: ++_filtersRevision,
      ),
    );
  }

  List<ProductEntity> _visibleProducts() {
    final filtered = _allProducts.where((product) {
      if (_discountsOnly && product.discountPercentage < 5) return false;
      if (product.price > _maxPrice) return false;
      return true;
    }).toList();

    switch (_sortOption) {
      case ProductSortOption.popular:
        break;
      case ProductSortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case ProductSortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
      case ProductSortOption.highestRated:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return filtered;
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
