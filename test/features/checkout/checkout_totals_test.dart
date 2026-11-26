import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:raff_app/features/checkout/presentation/utils/checkout_totals.dart';

import '../../helpers/fixtures.dart';

void main() {
  final smallCart = CartState(items: [fakeCartItem(price: 100)]);
  final bigCart = CartState(items: [fakeCartItem(price: 300)]);

  CheckoutTotals totalsFor(
    CartState cart, {
    String delivery = 'standard',
    String payment = 'card',
  }) {
    return CheckoutTotals.from(
      cart,
      deliveryMethod: delivery,
      paymentMethod: payment,
    );
  }

  group('shipping', () {
    test('standard delivery is charged below the free shipping threshold', () {
      expect(totalsFor(smallCart).shippingFee, CartState.standardShippingFee);
      expect(totalsFor(smallCart).total, 125);
    });

    test('standard delivery is free above the threshold', () {
      expect(totalsFor(bigCart).shippingFee, 0);
      expect(totalsFor(bigCart).total, 300);
    });

    test('express always costs the express fee', () {
      expect(
        totalsFor(bigCart, delivery: 'express').shippingFee,
        CheckoutTotals.expressFee,
      );
    });

    test('pickup is always free', () {
      expect(totalsFor(smallCart, delivery: 'pickup').shippingFee, 0);
    });
  });

  group('payment', () {
    test('cash on delivery adds the cod fee', () {
      final totals = totalsFor(bigCart, payment: 'cod');

      expect(totals.codFee, CheckoutTotals.codFeeAmount);
      expect(totals.total, 310);
    });

    test('other payment methods have no extra fee', () {
      for (final method in ['apple', 'card', 'split']) {
        expect(totalsFor(bigCart, payment: method).codFee, 0);
      }
    });
  });

  test('the promo discount is subtracted from the total', () {
    final cart = bigCart.copyWith(appliedPromoCode: 'RAFF10');
    final totals = totalsFor(cart);

    expect(totals.discount, 30);
    expect(totals.total, 270);
  });
}
