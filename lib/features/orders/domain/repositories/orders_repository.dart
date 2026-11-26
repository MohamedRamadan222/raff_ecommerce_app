import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';

abstract class OrdersRepository {
  Either<Failure, List<OrderEntity>> getOrders();

  Future<Either<Failure, List<OrderEntity>>> placeOrder(OrderEntity order);
}
