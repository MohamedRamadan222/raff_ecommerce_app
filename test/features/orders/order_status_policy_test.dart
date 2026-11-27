import 'package:flutter_test/flutter_test.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/value_objects/order_status_policy.dart';

void main() {
  final createdAt = DateTime(2026, 1, 1, 10);

  OrderStatus statusAt(Duration elapsed) {
    return OrderStatusPolicy.deriveStatus(
      current: OrderStatus.placed,
      createdAt: createdAt,
      now: createdAt.add(elapsed),
    );
  }

  group('deriveStatus', () {
    test('follows the simulated stages', () {
      expect(statusAt(Duration.zero), OrderStatus.placed);
      expect(statusAt(const Duration(seconds: 29)), OrderStatus.placed);
      expect(statusAt(const Duration(seconds: 30)), OrderStatus.confirmed);
      expect(statusAt(const Duration(minutes: 2)), OrderStatus.shipped);
      expect(statusAt(const Duration(minutes: 5)), OrderStatus.outForDelivery);
      expect(statusAt(const Duration(minutes: 10)), OrderStatus.delivered);
    });

    test('a cancelled order never changes', () {
      final status = OrderStatusPolicy.deriveStatus(
        current: OrderStatus.cancelled,
        createdAt: createdAt,
        now: createdAt.add(const Duration(days: 1)),
      );

      expect(status, OrderStatus.cancelled);
    });
  });

  test('stageTime uses the offset of the requested stage', () {
    expect(OrderStatusPolicy.stageTime(createdAt, 0), createdAt);
    expect(
      OrderStatusPolicy.stageTime(createdAt, 1),
      createdAt.add(const Duration(seconds: 30)),
    );
    expect(
      OrderStatusPolicy.stageTime(createdAt, 4),
      createdAt.add(const Duration(minutes: 10)),
    );
  });

  test('stageIndexOf maps statuses to their timeline position', () {
    expect(OrderStatusPolicy.stageIndexOf(OrderStatus.placed), 0);
    expect(OrderStatusPolicy.stageIndexOf(OrderStatus.delivered), 4);
    expect(OrderStatusPolicy.stageIndexOf(OrderStatus.cancelled), -1);
  });
}
