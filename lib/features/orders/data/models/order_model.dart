import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.title,
    required super.thumbnail,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as int,
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      productId: entity.productId,
      title: entity.title,
      thumbnail: entity.thumbnail,
      price: entity.price,
      quantity: entity.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'thumbnail': thumbnail,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.shippingFee,
    required super.codFee,
    required super.total,
    super.promoCode,
    required super.status,
    required super.createdAt,
    required super.addressLabel,
    required super.addressFull,
    required super.deliveryMethod,
    required super.paymentMethod,
    super.courierNote,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num? ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] as num? ?? 0).toDouble(),
      codFee: (json['codFee'] as num? ?? 0).toDouble(),
      total: (json['total'] as num).toDouble(),
      promoCode: json['promoCode'] as String?,
      status: OrderStatus.values.byName(json['status'] as String? ?? 'placed'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      addressLabel: json['addressLabel'] as String? ?? '',
      addressFull: json['addressFull'] as String? ?? '',
      deliveryMethod: json['deliveryMethod'] as String? ?? 'standard',
      paymentMethod: json['paymentMethod'] as String? ?? 'cod',
      courierNote: json['courierNote'] as String?,
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      items: entity.items.map(OrderItemModel.fromEntity).toList(),
      subtotal: entity.subtotal,
      discount: entity.discount,
      shippingFee: entity.shippingFee,
      codFee: entity.codFee,
      total: entity.total,
      promoCode: entity.promoCode,
      status: entity.status,
      createdAt: entity.createdAt,
      addressLabel: entity.addressLabel,
      addressFull: entity.addressFull,
      deliveryMethod: entity.deliveryMethod,
      paymentMethod: entity.paymentMethod,
      courierNote: entity.courierNote,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => OrderItemModel.fromEntity(e).toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'shippingFee': shippingFee,
      'codFee': codFee,
      'total': total,
      'promoCode': promoCode,
      'status': status.name,
      // التاريخ بيتخزن كنص ISO عشان نرجعه بـ DateTime.parse
      'createdAt': createdAt.toIso8601String(),
      'addressLabel': addressLabel,
      'addressFull': addressFull,
      'deliveryMethod': deliveryMethod,
      'paymentMethod': paymentMethod,
      'courierNote': courierNote,
    };
  }
}
