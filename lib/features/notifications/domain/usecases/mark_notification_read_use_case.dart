import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call(String id) {
    return repository.markRead(id);
  }
}
