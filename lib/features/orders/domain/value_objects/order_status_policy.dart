import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

/// Single source of truth for the simulated order lifecycle.
///
/// The status is derived from the time elapsed since the order was created;
/// a cancelled order never changes.
abstract final class OrderStatusPolicy {
  static const List<OrderStatus> stages = [
    OrderStatus.placed,
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  /// Time after [OrderEntity.createdAt] at which each stage begins.
  static const List<Duration> offsets = [
    Duration.zero,
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 10),
  ];

  static OrderStatus deriveStatus({
    required OrderStatus current,
    required DateTime createdAt,
    DateTime? now,
  }) {
    if (current == OrderStatus.cancelled) return OrderStatus.cancelled;

    final elapsed = (now ?? DateTime.now()).difference(createdAt);
    var derived = stages.first;
    for (var i = 0; i < stages.length; i++) {
      if (elapsed >= offsets[i]) derived = stages[i];
    }
    return derived;
  }

  static int stageIndexOf(OrderStatus status) => stages.indexOf(status);

  static DateTime stageTime(DateTime createdAt, int stageIndex) =>
      createdAt.add(offsets[stageIndex]);
}
