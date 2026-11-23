import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  static const double freeShippingThreshold = 200.0;
  static const double standardShippingFee = 25.0;

  final CartStatus status;
  final List<CartItemEntity> items;
  final String? appliedPromoCode;
  final bool isPromoInvalid;
  final Failure? failure;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.appliedPromoCode,
    this.isPromoInvalid = false,
    this.failure,
  });

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get hasFreeShipping => subtotal >= freeShippingThreshold;

  double get remainingForFreeShipping =>
      (freeShippingThreshold - subtotal).clamp(0.0, freeShippingThreshold);

  double get freeShippingProgress =>
      (subtotal / freeShippingThreshold).clamp(0.0, 1.0);

  double get shippingFee =>
      (items.isEmpty || hasFreeShipping) ? 0.0 : standardShippingFee;

  double get discountAmount =>
      appliedPromoCode == 'RAFF10' ? subtotal * 0.10 : 0.0;

  double get total =>
      (subtotal - discountAmount + shippingFee).clamp(0.0, double.infinity);

  bool isInCart(int productId) =>
      items.any((item) => item.product.id == productId);

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? appliedPromoCode,
    bool clearPromoCode = false,
    bool? isPromoInvalid,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      appliedPromoCode: clearPromoCode
          ? null
          : (appliedPromoCode ?? this.appliedPromoCode),
      isPromoInvalid: isPromoInvalid ?? this.isPromoInvalid,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    appliedPromoCode,
    isPromoInvalid,
    failure,
  ];
}
