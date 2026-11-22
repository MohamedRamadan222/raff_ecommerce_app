import 'package:bloc/bloc.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_categories_use_case.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_products_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsUseCase getProductsUseCase;

  HomeCubit({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
  }) : super(const HomeInitial());

  Future<void> loadHomeData() async {
    emit(const HomeLoading());

    final categoriesFuture = getCategoriesUseCase();
    final productsFuture = getProductsUseCase(limit: 10, skip: 0);

    await Future.wait([categoriesFuture, productsFuture]);

    if (isClosed) return;

    final categoriesResult = await categoriesFuture;
    final productsResult = await productsFuture;

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
