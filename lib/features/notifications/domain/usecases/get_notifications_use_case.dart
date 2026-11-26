import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Either<Failure, List<NotificationEntity>> call() {
    return repository.getNotifications();
  }
}
