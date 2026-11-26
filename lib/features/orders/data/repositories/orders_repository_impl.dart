import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:raff_app/features/orders/data/models/order_model.dart';
import 'package:raff_app/features/orders/domain/entities/order_entity.dart';
import 'package:raff_app/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersLocalDataSource localDataSource;

  OrdersRepositoryImpl(this.localDataSource);

  @override
  Either<Failure, List<OrderEntity>> getOrders() {
    try {
      return Right(localDataSource.getOrders());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> placeOrder(
    OrderEntity order,
  ) async {
    try {
      final model = OrderModel.fromEntity(order);
      return Right(await localDataSource.placeOrder(model));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
