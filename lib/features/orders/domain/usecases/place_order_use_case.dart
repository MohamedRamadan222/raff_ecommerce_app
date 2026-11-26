import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/repositories/orders_repository.dart';

class PlaceOrderUseCase {
  final OrdersRepository repository;

  PlaceOrderUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call(OrderEntity order) {
    return repository.placeOrder(order);
  }
}
