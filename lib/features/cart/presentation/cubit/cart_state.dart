import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:raff_app/features/cart/domain/value_objects/cart_pricing.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  static const double freeShippingThreshold = CartPricing.freeShippingThreshold;
  static const double standardShippingFee = CartPricing.standardShippingFee;

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

  CartPricing get _pricing => CartPricing.from(items, appliedPromoCode);

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _pricing.subtotal;

  bool get hasFreeShipping => _pricing.hasFreeShipping;

  double get remainingForFreeShipping => _pricing.remainingForFreeShipping;

  double get freeShippingProgress => _pricing.freeShippingProgress;

  double get shippingFee => _pricing.shippingFee;

  double get discountAmount => _pricing.discountAmount;

  double get total => _pricing.total;

  bool isInCart(int productId) =>
      items.any((item) => item.product.id == productId);

  Set<int> get productIds => items.map((item) => item.product.id).toSet();

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
