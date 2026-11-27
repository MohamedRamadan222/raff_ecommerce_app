import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

/// حالة الطلبات كـ sealed class: كل حالة بتحمل اللي متاح فيها بس، فمستحيل
/// نوصل لحالة "نجاح" من غير قائمة أو "فشل" من غير سبب.
sealed class OrdersState extends Equatable {
  const OrdersState();

  /// افتراضيات آمنة للشاشات اللي بتقرأ ملخص بسيط (عدّادات الحساب مثلًا).
  List<OrderEntity> get orders => const [];

  List<OrderEntity> get currentOrders => const [];

  List<OrderEntity> get pastOrders => const [];

  OrderEntity? orderById(String id) => null;
}

final class OrdersInitial extends OrdersState {
  const OrdersInitial();

  @override
  List<Object?> get props => [];
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();

  @override
  List<Object?> get props => [];
}

final class OrdersSuccess extends OrdersState {
  @override
  final List<OrderEntity> orders;

  const OrdersSuccess(this.orders);

  bool get isEmpty => orders.isEmpty;

  @override
  List<OrderEntity> get currentOrders => orders
      .where(
        (o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled,
      )
      .toList();

  @override
  List<OrderEntity> get pastOrders => orders
      .where(
        (o) =>
            o.status == OrderStatus.delivered ||
            o.status == OrderStatus.cancelled,
      )
      .toList();

  @override
  OrderEntity? orderById(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  List<Object?> get props => [orders];
}

final class OrdersFailure extends OrdersState {
  final Failure failure;

  const OrdersFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
