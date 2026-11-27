import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/features/cart/domain/value_objects/cart_pricing.dart';
import 'package:raff_app/features/cart/domain/value_objects/promo_code_policy.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('PromoCodePolicy', () {
    test('normalizes with trim and upper case', () {
      expect(PromoCodePolicy.normalize('  raff10 '), 'RAFF10');
    });

    test('only RAFF10 is valid', () {
      expect(PromoCodePolicy.isValid('RAFF10'), isTrue);
      expect(PromoCodePolicy.isValid('SAVE20'), isFalse);
    });

    test('discountFor normalizes and ignores unsupported codes', () {
      expect(PromoCodePolicy.discountFor(' raff10 ', 200), 20);
      expect(PromoCodePolicy.discountFor('WRONG', 200), 0);
      expect(PromoCodePolicy.discountFor(null, 200), 0);
    });
  });

  group('CartPricing', () {
    test('empty cart has no shipping and zero total', () {
      final pricing = CartPricing.from(const [], null);

      expect(pricing.subtotal, 0);
      expect(pricing.shippingFee, 0);
      expect(pricing.total, 0);
      expect(pricing.freeShippingProgress, 0);
    });

    test('charges standard shipping below the threshold', () {
      final pricing = CartPricing.from([fakeCartItem(price: 100)], null);

      expect(pricing.hasFreeShipping, isFalse);
      expect(pricing.shippingFee, CartPricing.standardShippingFee);
      expect(pricing.remainingForFreeShipping, 100);
      expect(pricing.freeShippingProgress, 0.5);
      expect(pricing.total, 125);
    });

    test('free shipping starts at the threshold', () {
      final pricing = CartPricing.from([fakeCartItem(price: 200)], null);

      expect(pricing.hasFreeShipping, isTrue);
      expect(pricing.shippingFee, 0);
      expect(pricing.remainingForFreeShipping, 0);
      expect(pricing.freeShippingProgress, 1);
      expect(pricing.total, 200);
    });

    test('applies the promo discount to the subtotal', () {
      final pricing = CartPricing.from([fakeCartItem(price: 300)], 'RAFF10');

      expect(pricing.discountAmount, 30);
      expect(pricing.total, 270);
    });

    test('ignores unsupported promo codes', () {
      final pricing = CartPricing.from([fakeCartItem(price: 300)], 'WRONG');

      expect(pricing.discountAmount, 0);
      expect(pricing.total, 300);
    });
  });
}
