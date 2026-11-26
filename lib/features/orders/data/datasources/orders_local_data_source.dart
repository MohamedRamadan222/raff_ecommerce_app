import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/orders/data/models/order_model.dart';

abstract class OrdersLocalDataSource {
  List<OrderModel> getOrders();

  Future<List<OrderModel>> placeOrder(OrderModel order);
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final Box<String> box;

  OrdersLocalDataSourceImpl(this.box);

  @override
  List<OrderModel> getOrders() {
    final orders = box.values.map((raw) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return OrderModel.fromJson(map);
    }).toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<List<OrderModel>> placeOrder(OrderModel order) async {
    await box.put(order.id, jsonEncode(order.toJson()));
    return getOrders();
  }
}
