import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<ProductEntity> favorites;
  final Failure? failure;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.failure,
  });

  bool isFavorite(int productId) =>
      favorites.any((item) => item.id == productId);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<ProductEntity>? favorites,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, favorites, failure];
}
