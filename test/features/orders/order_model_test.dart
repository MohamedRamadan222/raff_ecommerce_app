import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/features/orders/data/models/order_model.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('toJson then fromJson gives back the same order', () {
    final order = OrderModel.fromEntity(fakeOrder(status: OrderStatus.shipped));

    final json = jsonDecode(jsonEncode(order.toJson()));
    final restored = OrderModel.fromJson(json);

    expect(restored, order);
    expect(restored.items.single.quantity, 2);
    expect(restored.status, OrderStatus.shipped);
  });

  test('fromJson uses defaults for the optional fields', () {
    final order = OrderModel.fromJson({
      'id': 'RF-9',
      'items': <dynamic>[],
      'subtotal': 10,
      'total': 10,
      'createdAt': '2026-01-01T10:00:00.000',
    });

    expect(order.status, OrderStatus.placed);
    expect(order.deliveryMethod, 'standard');
    expect(order.paymentMethod, 'cod');
    expect(order.discount, 0);
  });

  test('totalItemsCount sums the quantities', () {
    expect(fakeOrder().totalItemsCount, 2);
  });
}
