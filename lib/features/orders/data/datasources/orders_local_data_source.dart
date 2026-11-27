import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/orders/data/models/order_model.dart';

abstract class OrdersLocalDataSource {
  List<OrderModel> getOrders();

  Future<List<OrderModel>> placeOrder(OrderModel order);

  Future<void> clearAll();
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  static const int _maxRetained = 200;

  final Box<String> box;

  OrdersLocalDataSourceImpl(this.box);

  /// الأوردرات مرتبة تنازليًا بالتاريخ، ومفكوكة من الـ JSON مرة واحدة.
  List<OrderModel>? _ordersCache;

  void _ensureLoaded() {
    if (_ordersCache != null) return;
    final orders = box.values
        .map(
          (raw) => OrderModel.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _trimOverflow(orders);
    _ordersCache = orders;
  }

  /// بيحافظ على أحدث [_maxRetained] أوردر بس، وبيحذف الأقدم من الـ box.
  void _trimOverflow(List<OrderModel> orders) {
    if (orders.length <= _maxRetained) return;
    final overflow = orders.sublist(_maxRetained);
    orders.removeRange(_maxRetained, orders.length);
    // Fire-and-forget: deletion failures must not surface as unhandled errors.
    box.deleteAll(overflow.map((order) => order.id).toList()).ignore();
  }

  List<OrderModel> get _orders {
    _ensureLoaded();
    return _ordersCache!;
  }

  @override
  List<OrderModel> getOrders() {
    return List<OrderModel>.unmodifiable(_orders);
  }

  @override
  Future<List<OrderModel>> placeOrder(OrderModel order) async {
    final orders = _orders;
    await box.put(order.id, jsonEncode(order.toJson()));

    final index = orders.indexWhere((o) => o.id == order.id);
    if (index >= 0) {
      orders[index] = order;
    } else {
      orders.add(order);
    }
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _trimOverflow(orders);
    return getOrders();
  }

  @override
  Future<void> clearAll() async {
    await box.clear();
    _ordersCache = <OrderModel>[];
  }
}
