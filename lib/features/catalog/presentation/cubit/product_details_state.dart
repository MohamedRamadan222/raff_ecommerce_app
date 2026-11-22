import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

class ProductDetailsSuccess extends ProductDetailsState {
  final ProductEntity product;
  final int selectedImageIndex;

  const ProductDetailsSuccess({
    required this.product,
    this.selectedImageIndex = 0,
  });

  ProductDetailsSuccess copyWith({
    ProductEntity? product,
    int? selectedImageIndex,
  }) {
    return ProductDetailsSuccess(
      product: product ?? this.product,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
    );
  }

  @override
  List<Object?> get props => [product, selectedImageIndex];
}

class ProductDetailsFailure extends ProductDetailsState {
  final Failure failure;

  const ProductDetailsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
