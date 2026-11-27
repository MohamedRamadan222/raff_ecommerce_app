import 'package:equatable/equatable.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';

/// Base type for the notifications feature state.
///
/// Each concrete state represents exactly one lifecycle phase, so illegal
/// combinations such as "failure while showing data" are impossible.
sealed class NotificationsState extends Equatable {
  const NotificationsState();

  /// Notifications available in the current state.
  ///
  /// Empty for every non-success state so widgets can read it without null
  /// checks.
  List<NotificationEntity> get notifications => const [];

  int get unreadCount => 0;

  List<NotificationEntity> get todayNotifications => const [];

  List<NotificationEntity> get earlierNotifications => const [];

  @override
  List<Object?> get props => const [];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsSuccess extends NotificationsState {
  @override
  final List<NotificationEntity> notifications;

  const NotificationsSuccess(this.notifications);

  @override
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  List<NotificationEntity> get todayNotifications =>
      notifications.where((n) => _isToday(n.createdAt)).toList();

  @override
  List<NotificationEntity> get earlierNotifications =>
      notifications.where((n) => !_isToday(n.createdAt)).toList();

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  List<Object?> get props => [notifications];
}

final class NotificationsFailure extends NotificationsState {
  final Failure failure;

  const NotificationsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
