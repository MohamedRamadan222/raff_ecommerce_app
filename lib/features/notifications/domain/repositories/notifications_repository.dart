import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsRepository {
  Either<Failure, List<NotificationEntity>> getNotifications();

  Future<Either<Failure, List<NotificationEntity>>> addNotification(
    NotificationEntity notification,
  );

  Future<Either<Failure, List<NotificationEntity>>> markRead(String id);

  Future<Either<Failure, List<NotificationEntity>>> markAllRead();
}
