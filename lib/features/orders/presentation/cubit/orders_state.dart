import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<OrderEntity> orders;
  final Failure? failure;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.failure,
  });

  List<OrderEntity> get currentOrders => orders
      .where(
        (o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled,
      )
      .toList();

  List<OrderEntity> get pastOrders => orders
      .where(
        (o) =>
            o.status == OrderStatus.delivered ||
            o.status == OrderStatus.cancelled,
      )
      .toList();

  OrderEntity? orderById(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, orders, failure];
}
