import 'package:bloc/bloc.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:raff_app/features/orders/domain/usecases/place_order_use_case.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;
  final PlaceOrderUseCase placeOrderUseCase;

  OrdersCubit({required this.getOrdersUseCase, required this.placeOrderUseCase})
    : super(const OrdersState());

  void loadOrders() {
    emit(state.copyWith(status: OrdersStatus.loading));

    final result = getOrdersUseCase();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: OrdersStatus.failure, failure: failure)),
      (orders) => emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: _refreshStatuses(orders),
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> placeOrder(OrderEntity order) async {
    final result = await placeOrderUseCase(order);
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(status: OrdersStatus.failure, failure: failure)),
      (orders) => emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: orders,
          clearFailure: true,
        ),
      ),
    );
  }

  /// محاكاة تقدم الطلب: الحالة بتتحسب من الوقت اللي عدّى من إنشائه.
  /// في تطبيق حقيقي الحالة بتيجي من السيرفر — هنا بنتعلم فكرة
  /// "الحالة المشتقة" (derived state) بدل ما نخزنها وننسى نحدثها.
  List<OrderEntity> _refreshStatuses(List<OrderEntity> orders) {
    return orders.map((order) {
      if (order.status == OrderStatus.cancelled) return order;
      final elapsed = DateTime.now().difference(order.createdAt);
      final OrderStatus derived;
      if (elapsed >= const Duration(minutes: 10)) {
        derived = OrderStatus.delivered;
      } else if (elapsed >= const Duration(minutes: 5)) {
        derived = OrderStatus.outForDelivery;
      } else if (elapsed >= const Duration(minutes: 2)) {
        derived = OrderStatus.shipped;
      } else if (elapsed >= const Duration(seconds: 30)) {
        derived = OrderStatus.confirmed;
      } else {
        derived = OrderStatus.placed;
      }
      return derived == order.status ? order : order.copyWith(status: derived);
    }).toList();
  }
}
