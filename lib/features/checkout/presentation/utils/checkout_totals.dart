import 'package:raff_app/features/cart/presentation/cubit/cart_state.dart';

/// قاعدة الشحن العادي نفس قاعدة الكارت: مجاني فوق حد معين.
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
    CartState cartState, {
    required String deliveryMethod,
    required String paymentMethod,
  }) {
    final subtotal = cartState.subtotal;
    final discount = cartState.discountAmount;

    final shipping = switch (deliveryMethod) {
      'pickup' => 0.0,
      'express' => expressFee,
      _ => cartState.hasFreeShipping ? 0.0 : CartState.standardShippingFee,
    };

    final codFee = paymentMethod == 'cod' ? codFeeAmount : 0.0;

    final total = (subtotal - discount + shipping + codFee).clamp(
      0.0,
      double.infinity,
    );

    return CheckoutTotals(
      subtotal: subtotal,
      discount: discount,
      shippingFee: shipping,
      codFee: codFee,
      total: total,
    );
  }
}
