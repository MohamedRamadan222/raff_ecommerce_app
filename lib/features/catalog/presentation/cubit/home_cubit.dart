import 'package:bloc/bloc.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_categories_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/invalidate_catalog_cache_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsUseCase getProductsUseCase;
  final InvalidateCatalogCacheUseCase? invalidateCatalogCacheUseCase;

  HomeCubit({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
    this.invalidateCatalogCacheUseCase,
  }) : super(const HomeInitial());

  int _generation = 0;

  Future<void> loadHomeData({bool forceRefresh = false}) async {
    if (forceRefresh) invalidateCatalogCacheUseCase?.call();

    final generation = ++_generation;
    emit(const HomeLoading());

    final categoriesFuture = getCategoriesUseCase();
    final productsFuture = getProductsUseCase(limit: 10, skip: 0);

    await Future.wait([categoriesFuture, productsFuture]);

    if (isClosed || generation != _generation) return;

    final categoriesResult = await categoriesFuture;
    final productsResult = await productsFuture;

    if (isClosed || generation != _generation) return;

    productsResult.fold((failure) => emit(HomeFailure(failure)), (
      paginatedProducts,
    ) {
      final categories = categoriesResult.getOrElse(() => []);

      emit(
        HomeSuccess(
          categories: categories,
          products: paginatedProducts.products,
        ),
      );
    });
  }
}
