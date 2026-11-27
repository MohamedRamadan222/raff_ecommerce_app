import 'package:bloc/bloc.dart';
import 'package:raff_app/features/cart/domain/usecases/add_to_cart_use_case.dart';
import 'package:raff_app/features/cart/domain/usecases/clear_cart_use_case.dart';
import 'package:raff_app/features/cart/domain/usecases/get_cart_items_use_case.dart';
import 'package:raff_app/features/cart/domain/usecases/remove_from_cart_use_case.dart';
import 'package:raff_app/features/cart/domain/usecases/update_cart_quantity_use_case.dart';
import 'package:raff_app/features/cart/domain/value_objects/promo_code_policy.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/catalog/domain/entities/product_entity.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartItemsUseCase getCartItemsUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartCubit({
    required this.getCartItemsUseCase,
    required this.addToCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(const CartState());

  /// Clears in-memory cart state after the user-scoped storage is wiped.
  void reset() => emit(const CartState());

  void loadCart() {
    emit(state.copyWith(status: CartStatus.loading));

    final result = getCartItemsUseCase();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: CartStatus.failure, failure: failure)),
      (items) => emit(
        state.copyWith(
          status: CartStatus.success,
          items: items,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> addToCart(
    ProductEntity product, {
    int quantity = 1,
    String? colorHex,
  }) async {
    final result = await addToCartUseCase(
      product,
      quantity: quantity,
      colorHex: colorHex,
    );
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(status: CartStatus.failure, failure: failure)),
      (items) => emit(
        state.copyWith(
          status: CartStatus.success,
          items: items,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> incrementQuantity(int productId) async {
    final index = state.items.indexWhere((e) => e.product.id == productId);
    if (index == -1) return;

    final current = state.items[index];
    final result = await updateCartQuantityUseCase(
      productId,
      current.quantity + 1,
    );
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(status: CartStatus.failure, failure: failure)),
      (items) => emit(
        state.copyWith(
          status: CartStatus.success,
          items: items,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> decrementQuantity(int productId) async {
    final index = state.items.indexWhere((e) => e.product.id == productId);
    if (index == -1) return;

    final current = state.items[index];
    if (current.quantity <= 1) {
      await removeFromCart(productId);
      return;
    }

    final result = await updateCartQuantityUseCase(
      productId,
      current.quantity - 1,
    );
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(status: CartStatus.failure, failure: failure)),
      (items) => emit(
        state.copyWith(
          status: CartStatus.success,
          items: items,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> removeFromCart(int productId) async {
    final result = await removeFromCartUseCase(productId);
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(status: CartStatus.failure, failure: failure)),
      (items) => emit(
        state.copyWith(
          status: CartStatus.success,
          items: items,
          clearPromoCode: items.isEmpty,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> clearCart() async {
    final result = await clearCartUseCase();
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(status: CartStatus.failure, failure: failure)),
      (items) => emit(
        state.copyWith(
          status: CartStatus.success,
          items: items,
          clearPromoCode: true,
          isPromoInvalid: false,
          clearFailure: true,
        ),
      ),
    );
  }

  bool applyPromoCode(String rawCode) {
    final code = PromoCodePolicy.normalize(rawCode);
    if (code.isEmpty) return false;

    if (PromoCodePolicy.isValid(code)) {
      emit(state.copyWith(appliedPromoCode: code, isPromoInvalid: false));
      return true;
    }

    emit(state.copyWith(isPromoInvalid: true));
    return false;
  }

  void removePromoCode() {
    emit(state.copyWith(clearPromoCode: true, isPromoInvalid: false));
  }
}
