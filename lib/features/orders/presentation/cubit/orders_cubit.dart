import 'package:bloc/bloc.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:raff_app/features/orders/domain/usecases/place_order_use_case.dart';
import 'package:raff_app/features/orders/domain/value_objects/order_status_policy.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;
  final PlaceOrderUseCase placeOrderUseCase;

  OrdersCubit({required this.getOrdersUseCase, required this.placeOrderUseCase})
    : super(const OrdersInitial());

  void loadOrders() {
    if (isClosed) return;
    emit(const OrdersLoading());

    final result = getOrdersUseCase();
    if (isClosed) return;

    result.fold(
      (failure) => emit(OrdersFailure(failure)),
      (orders) => emit(OrdersSuccess(_refreshStatuses(orders))),
    );
  }

  /// بتحمّل الطلبات بس لو لسه ما اتحمّلتش أو فشل تحميلها؛ آمنة للنداء
  /// المتكرر من الشاشات من غير قراءة جديدة من التخزين كل مرة.
  void ensureLoaded() {
    if (state is OrdersInitial || state is OrdersFailure) {
      loadOrders();
    }
  }

  /// بتحدّث الحالات المشتقة من الوقت الحالي من غير حالة loading.
  /// مش بتطلع emit لو مفيش طلب اتغيرت حالته.
  void refreshStatuses() {
    final current = state;
    if (current is! OrdersSuccess) return;

    final refreshed = _refreshStatuses(current.orders);

    var changed = false;
    for (var i = 0; i < current.orders.length; i++) {
      if (current.orders[i].status != refreshed[i].status) {
        changed = true;
        break;
      }
    }
    if (!changed || isClosed) return;

    emit(OrdersSuccess(refreshed));
  }

  /// بتصفّر الحالة عند الخروج من الحساب.
  void reset() => emit(const OrdersInitial());

  Future<void> placeOrder(OrderEntity order) async {
    final result = await placeOrderUseCase(order);
    if (isClosed) return;

    result.fold(
      (failure) => emit(OrdersFailure(failure)),
      (orders) => emit(OrdersSuccess(orders)),
    );
  }

  /// محاكاة تقدم الطلب: الحالة بتتحسب من الوقت اللي عدّى من إنشائه.
  /// في تطبيق حقيقي الحالة بتيجي من السيرفر — هنا بنتعلم فكرة
  /// "الحالة المشتقة" (derived state) بدل ما نخزنها وننسى نحدثها.
  List<OrderEntity> _refreshStatuses(List<OrderEntity> orders) {
    return orders.map((order) {
      final derived = OrderStatusPolicy.deriveStatus(
        current: order.status,
        createdAt: order.createdAt,
      );
      return derived == order.status ? order : order.copyWith(status: derived);
    }).toList();
  }
}
