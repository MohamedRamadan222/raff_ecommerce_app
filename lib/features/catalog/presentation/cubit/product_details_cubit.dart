import 'package:bloc/bloc.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_product_details_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductDetailsUseCase getProductDetailsUseCase;

  ProductDetailsCubit(this.getProductDetailsUseCase)
    : super(const ProductDetailsInitial());

  int _generation = 0;

  Future<void> loadProductDetails(int id) async {
    final generation = ++_generation;
    emit(const ProductDetailsLoading());

    final result = await getProductDetailsUseCase(id);
    if (isClosed || generation != _generation) return;

    result.fold(
      (failure) => emit(ProductDetailsFailure(failure)),
      (product) => emit(ProductDetailsSuccess(product: product)),
    );
  }
}
