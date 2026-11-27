import 'package:equatable/equatable.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/cart/domain/value_objects/promo_code_policy.dart';

/// Immutable pricing snapshot for a list of cart items.
class CartPricing extends Equatable {
  static const double freeShippingThreshold = 200.0;
  static const double standardShippingFee = 25.0;

  final double subtotal;
  final double discountAmount;
  final double shippingFee;
  final double total;
  final bool hasFreeShipping;
  final double remainingForFreeShipping;
  final double freeShippingProgress;

  const CartPricing({
    required this.subtotal,
    required this.discountAmount,
    required this.shippingFee,
    required this.total,
    required this.hasFreeShipping,
    required this.remainingForFreeShipping,
    required this.freeShippingProgress,
  });

  factory CartPricing.from(List<CartItemEntity> items, String? promoCode) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final hasFreeShipping = subtotal >= freeShippingThreshold;
    final discountAmount = PromoCodePolicy.discountFor(promoCode, subtotal);
    final shippingFee = (items.isEmpty || hasFreeShipping)
        ? 0.0
        : standardShippingFee;

    return CartPricing(
      subtotal: subtotal,
      discountAmount: discountAmount,
      shippingFee: shippingFee,
      total: (subtotal - discountAmount + shippingFee).clamp(
        0.0,
        double.infinity,
      ),
      hasFreeShipping: hasFreeShipping,
      remainingForFreeShipping: (freeShippingThreshold - subtotal).clamp(
        0.0,
        freeShippingThreshold,
      ),
      freeShippingProgress: (subtotal / freeShippingThreshold).clamp(0.0, 1.0),
    );
  }

  @override
  List<Object?> get props => [
    subtotal,
    discountAmount,
    shippingFee,
    total,
    hasFreeShipping,
    remainingForFreeShipping,
    freeShippingProgress,
  ];
}
