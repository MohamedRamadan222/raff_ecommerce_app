import 'package:bloc/bloc.dart';
import 'package:raff_app/features/catalog/domain/usecases/get_product_details_use_case.dart';
import 'package:raff_app/features/catalog/presentation/cubit/product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductDetailsUseCase getProductDetailsUseCase;

  ProductDetailsCubit(this.getProductDetailsUseCase)
    : super(const ProductDetailsInitial());

  Future<void> loadProductDetails(int id) async {
    emit(const ProductDetailsLoading());

    final result = await getProductDetailsUseCase(id);
    if (isClosed) return;

    result.fold(
      (failure) => emit(ProductDetailsFailure(failure)),
      (product) => emit(ProductDetailsSuccess(product: product)),
    );
  }

  void selectImage(int index) {
    final currentState = state;
    if (currentState is! ProductDetailsSuccess) return;
    if (index < 0 || index >= currentState.product.images.length) return;

    emit(currentState.copyWith(selectedImageIndex: index));
  }
}
