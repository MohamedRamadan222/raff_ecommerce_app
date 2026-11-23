import 'package:bloc/bloc.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';
import 'package:raff_app/features/favorites/domain/usecases/get_favorites_use_case.dart';
import 'package:raff_app/features/favorites/domain/usecases/toggle_favorite_use_case.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesCubit({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(const FavoritesState());

  void loadFavorites() {
    emit(state.copyWith(status: FavoritesStatus.loading));

    final result = getFavoritesUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(status: FavoritesStatus.failure, failure: failure),
      ),
      (items) => emit(
        state.copyWith(
          status: FavoritesStatus.success,
          favorites: items,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> toggleFavorite(ProductEntity product) async {
    final result = await toggleFavoriteUseCase(product);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: FavoritesStatus.failure, failure: failure),
      ),
      (items) => emit(
        state.copyWith(
          status: FavoritesStatus.success,
          favorites: items,
          clearFailure: true,
        ),
      ),
    );
  }

  bool isFavorite(int productId) => state.isFavorite(productId);
}
