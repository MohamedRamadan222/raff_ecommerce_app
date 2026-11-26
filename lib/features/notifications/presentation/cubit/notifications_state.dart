import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final Failure? failure;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.failure,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationEntity> get todayNotifications =>
      notifications.where((n) => _isToday(n.createdAt)).toList();

  List<NotificationEntity> get earlierNotifications =>
      notifications.where((n) => !_isToday(n.createdAt)).toList();

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, notifications, failure];
}
