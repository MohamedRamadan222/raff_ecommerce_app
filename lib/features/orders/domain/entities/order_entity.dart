import 'package:equatable/equatable.dart';

enum OrderStatus {
  placed,
  confirmed,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderItemEntity extends Equatable {
  final int productId;
  final String title;
  final String thumbnail;
  final double price;
  final int quantity;

  const OrderItemEntity({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [productId, title, thumbnail, price, quantity];
}

class OrderEntity extends Equatable {
  final String id;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double codFee;
  final double total;
  final String? promoCode;
  final OrderStatus status;
  final DateTime createdAt;
  final String addressLabel;
  final String addressFull;
  final String deliveryMethod; // standard | express | pickup
  final String paymentMethod; // apple | card | split | cod
  final String? courierNote;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.codFee,
    required this.total,
    this.promoCode,
    required this.status,
    required this.createdAt,
    required this.addressLabel,
    required this.addressFull,
    required this.deliveryMethod,
    required this.paymentMethod,
    this.courierNote,
  });

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderEntity copyWith({OrderStatus? status}) {
    return OrderEntity(
      id: id,
      items: items,
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      codFee: codFee,
      total: total,
      promoCode: promoCode,
      status: status ?? this.status,
      createdAt: createdAt,
      addressLabel: addressLabel,
      addressFull: addressFull,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      courierNote: courierNote,
    );
  }

  @override
  List<Object?> get props => [id, items, total, status, createdAt];
}
