import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/domain/repositories/notifications_repository.dart';

class AddNotificationUseCase {
  final NotificationsRepository repository;

  AddNotificationUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call(
    NotificationEntity notification,
  ) {
    return repository.addNotification(notification);
  }
}
