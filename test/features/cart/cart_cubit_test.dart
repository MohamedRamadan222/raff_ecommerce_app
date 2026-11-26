import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/cart/domain/usecases/add_to_cart_use_case.dart';
import 'package:raff_app/features/cart/domain/usecases/clear_cart_use_case.dart';
import 'package:raff_app/features/cart/domain/usecases/get_cart_items_use_case.dart';
import 'package:raff_app/features/cart/domain/usecases/remove_from_cart_use_case.dart';
import 'package:raff_app/features/cart/domain/usecases/update_cart_quantity_use_case.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';

import '../../helpers/fixtures.dart';

class MockGetCartItemsUseCase extends Mock implements GetCartItemsUseCase {}

class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}

class MockUpdateCartQuantityUseCase extends Mock
    implements UpdateCartQuantityUseCase {}

class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockGetCartItemsUseCase getCartItems;
  late MockAddToCartUseCase addToCart;
  late MockUpdateCartQuantityUseCase updateQuantity;
  late MockRemoveFromCartUseCase removeFromCart;
  late MockClearCartUseCase clearCart;

  final product = fakeProduct(id: 1, price: 100);
  final oneItem = [fakeCartItem(id: 1, quantity: 1)];
  final twoItems = [fakeCartItem(id: 1, quantity: 2)];

  setUpAll(() {
    registerFallbackValue(fakeProduct());
  });

  setUp(() {
    getCartItems = MockGetCartItemsUseCase();
    addToCart = MockAddToCartUseCase();
    updateQuantity = MockUpdateCartQuantityUseCase();
    removeFromCart = MockRemoveFromCartUseCase();
    clearCart = MockClearCartUseCase();
  });

  CartCubit buildCubit() => CartCubit(
    getCartItemsUseCase: getCartItems,
    addToCartUseCase: addToCart,
    updateCartQuantityUseCase: updateQuantity,
    removeFromCartUseCase: removeFromCart,
    clearCartUseCase: clearCart,
  );

  group('loadCart', () {
    blocTest<CartCubit, CartState>(
      'emits loading then success with the saved items',
      build: () {
        when(() => getCartItems()).thenReturn(Right(oneItem));
        return buildCubit();
      },
      act: (cubit) => cubit.loadCart(),
      expect: () => [
        const CartState(status: CartStatus.loading),
        CartState(status: CartStatus.success, items: oneItem),
      ],
    );

    blocTest<CartCubit, CartState>(
      'emits failure when reading the cart fails',
      build: () {
        when(() => getCartItems()).thenReturn(const Left(UnknownFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadCart(),
      expect: () => [
        const CartState(status: CartStatus.loading),
        const CartState(status: CartStatus.failure, failure: UnknownFailure()),
      ],
    );
  });

  group('addToCart', () {
    blocTest<CartCubit, CartState>(
      'emits success with the updated items',
      build: () {
        when(
          () => addToCart(
            any(),
            quantity: any(named: 'quantity'),
            colorHex: any(named: 'colorHex'),
          ),
        ).thenAnswer((_) async => Right(oneItem));
        return buildCubit();
      },
      act: (cubit) => cubit.addToCart(product),
      expect: () => [CartState(status: CartStatus.success, items: oneItem)],
    );
  });

  group('quantity', () {
    blocTest<CartCubit, CartState>(
      'incrementQuantity asks for current quantity + 1',
      build: () {
        when(() => updateQuantity(1, 2))
            .thenAnswer((_) async => Right(twoItems));
        return buildCubit();
      },
      seed: () => CartState(status: CartStatus.success, items: oneItem),
      act: (cubit) => cubit.incrementQuantity(1),
      expect: () => [CartState(status: CartStatus.success, items: twoItems)],
      verify: (_) => verify(() => updateQuantity(1, 2)).called(1),
    );

    blocTest<CartCubit, CartState>(
      'decrementQuantity on quantity 1 removes the item instead',
      build: () {
        when(() => removeFromCart(1)).thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      seed: () => CartState(status: CartStatus.success, items: oneItem),
      act: (cubit) => cubit.decrementQuantity(1),
      expect: () => [const CartState(status: CartStatus.success)],
      verify: (_) {
        verify(() => removeFromCart(1)).called(1);
        verifyNever(() => updateQuantity(any(), any()));
      },
    );

    blocTest<CartCubit, CartState>(
      'incrementQuantity ignores a product that is not in the cart',
      build: buildCubit,
      act: (cubit) => cubit.incrementQuantity(99),
      expect: () => <CartState>[],
    );
  });

  group('removeFromCart and clearCart', () {
    blocTest<CartCubit, CartState>(
      'removing the last item also clears the promo code',
      build: () {
        when(() => removeFromCart(1)).thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      seed: () => CartState(
        status: CartStatus.success,
        items: oneItem,
        appliedPromoCode: 'RAFF10',
      ),
      act: (cubit) => cubit.removeFromCart(1),
      expect: () => [const CartState(status: CartStatus.success)],
    );

    blocTest<CartCubit, CartState>(
      'clearCart empties the items and the promo code',
      build: () {
        when(() => clearCart()).thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      seed: () => CartState(
        status: CartStatus.success,
        items: oneItem,
        appliedPromoCode: 'RAFF10',
      ),
      act: (cubit) => cubit.clearCart(),
      expect: () => [const CartState(status: CartStatus.success)],
    );
  });

  group('promo code', () {
    test('RAFF10 is accepted in any case and with spaces', () {
      final cubit = buildCubit();

      expect(cubit.applyPromoCode('  raff10 '), isTrue);
      expect(cubit.state.appliedPromoCode, 'RAFF10');
      expect(cubit.state.isPromoInvalid, isFalse);
    });

    test('an unknown code is rejected and flagged invalid', () {
      final cubit = buildCubit();

      expect(cubit.applyPromoCode('WRONG'), isFalse);
      expect(cubit.state.appliedPromoCode, isNull);
      expect(cubit.state.isPromoInvalid, isTrue);
    });

    test('an empty code is ignored', () {
      final cubit = buildCubit();

      expect(cubit.applyPromoCode('   '), isFalse);
      expect(cubit.state.isPromoInvalid, isFalse);
    });

    test('removePromoCode clears the code and the invalid flag', () {
      final cubit = buildCubit()..applyPromoCode('RAFF10');

      cubit.removePromoCode();

      expect(cubit.state.appliedPromoCode, isNull);
      expect(cubit.state.isPromoInvalid, isFalse);
    });
  });
}
