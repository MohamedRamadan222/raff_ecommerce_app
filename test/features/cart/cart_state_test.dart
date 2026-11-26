import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('CartState', () {
    test('subtotal and items count are summed from the items', () {
      final state = CartState(
        items: [
          fakeCartItem(id: 1, price: 50, quantity: 2),
          fakeCartItem(id: 2, price: 30),
        ],
      );

      expect(state.subtotal, 130);
      expect(state.totalItemsCount, 3);
    });

    test('shipping is charged below the free shipping threshold', () {
      final state = CartState(items: [fakeCartItem(price: 100)]);

      expect(state.hasFreeShipping, isFalse);
      expect(state.shippingFee, CartState.standardShippingFee);
      expect(state.remainingForFreeShipping, 100);
      expect(state.freeShippingProgress, 0.5);
    });

    test('shipping is free at the threshold', () {
      final state = CartState(items: [fakeCartItem(price: 200)]);

      expect(state.hasFreeShipping, isTrue);
      expect(state.shippingFee, 0);
      expect(state.remainingForFreeShipping, 0);
      expect(state.freeShippingProgress, 1);
    });

    test('an empty cart has no shipping fee and zero total', () {
      const state = CartState();

      expect(state.shippingFee, 0);
      expect(state.total, 0);
    });

    test('RAFF10 gives 10% off the subtotal', () {
      final state = CartState(
        items: [fakeCartItem(price: 200)],
        appliedPromoCode: 'RAFF10',
      );

      expect(state.discountAmount, 20);
      expect(state.total, 180);
    });

    test('isInCart finds the product by id', () {
      final state = CartState(items: [fakeCartItem(id: 7)]);

      expect(state.isInCart(7), isTrue);
      expect(state.isInCart(8), isFalse);
    });

    test('copyWith can clear the promo code and the failure', () {
      const state = CartState(appliedPromoCode: 'RAFF10');

      expect(state.copyWith(clearPromoCode: true).appliedPromoCode, isNull);
      expect(state.copyWith().appliedPromoCode, 'RAFF10');
    });
  });
}
