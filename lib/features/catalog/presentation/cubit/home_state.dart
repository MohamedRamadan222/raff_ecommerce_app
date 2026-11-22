import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';

import '../../domain/entities/product_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  List<Object?> get props => [];
}

class HomeSuccess extends HomeState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;

  const HomeSuccess({required this.categories, required this.products});

  @override
  List<Object?> get props => [categories, products];
}

class HomeFailure extends HomeState {
  final Failure failure;

  const HomeFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
