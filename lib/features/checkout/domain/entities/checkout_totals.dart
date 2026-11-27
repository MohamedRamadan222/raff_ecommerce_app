import 'package:raff_app/features/cart/domain/value_objects/cart_pricing.dart';

/// Totals for the checkout flow, derived from [CartPricing].
///
/// Standard shipping follows the cart rule (free above the threshold);
/// express and cash-on-delivery add their own fees.
class CheckoutTotals {
  static const double expressFee = 35.0;
  static const double codFeeAmount = 10.0;

  final double subtotal;
  final double discount;
  final double shippingFee;
  final double codFee;
  final double total;

  const CheckoutTotals({
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.codFee,
    required this.total,
  });

  factory CheckoutTotals.from(
    CartPricing pricing, {
    required String deliveryMethod,
    required String paymentMethod,
  }) {
    final shipping = switch (deliveryMethod) {
      'pickup' => 0.0,
      'express' => expressFee,
      _ => pricing.shippingFee,
    };

    final codFee = paymentMethod == 'cod' ? codFeeAmount : 0.0;

    final total =
        (pricing.subtotal - pricing.discountAmount + shipping + codFee).clamp(
          0.0,
          double.infinity,
        );

    return CheckoutTotals(
      subtotal: pricing.subtotal,
      discount: pricing.discountAmount,
      shippingFee: shipping,
      codFee: codFee,
      total: total,
    );
  }
}
