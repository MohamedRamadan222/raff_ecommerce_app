import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:raff_app/features/notifications/data/models/notification_model.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsLocalDataSource localDataSource;

  NotificationsRepositoryImpl(this.localDataSource);

  @override
  Either<Failure, List<NotificationEntity>> getNotifications() {
    try {
      return Right(localDataSource.getNotifications());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> addNotification(
    NotificationEntity notification,
  ) async {
    try {
      final model = NotificationModel.fromEntity(notification);
      return Right(await localDataSource.addNotification(model));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> markRead(String id) async {
    try {
      return Right(await localDataSource.markRead(id));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> markAllRead() async {
    try {
      return Right(await localDataSource.markAllRead());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
