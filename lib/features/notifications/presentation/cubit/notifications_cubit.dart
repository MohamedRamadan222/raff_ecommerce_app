import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/domain/usecases/add_notification_use_case.dart';
import 'package:raff_app/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:raff_app/features/notifications/domain/usecases/mark_all_notifications_read_use_case.dart';
import 'package:raff_app/features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final AddNotificationUseCase addNotificationUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.addNotificationUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsReadUseCase,
  }) : super(const NotificationsState());

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    final result = getNotificationsUseCase();
    if (result.isLeft()) {
      result.fold(
        (failure) => emit(
          state.copyWith(status: NotificationsStatus.failure, failure: failure),
        ),
        (_) {},
      );
      return;
    }

    var items = result.getOrElse(() => <NotificationEntity>[]);

    // أول مرة يفتح التطبيق: نزرع إشعار ترحيب بالبرومو كود
    // عشان الشاشة متفتحش فاضية
    if (items.isEmpty) {
      final seed = await addNotificationUseCase(
        NotificationEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: NotificationType.promo,
          createdAt: DateTime.now(),
        ),
      );
      items = seed.getOrElse(() => <NotificationEntity>[]);
    }

    emit(
      state.copyWith(
        status: NotificationsStatus.success,
        notifications: items,
        clearFailure: true,
      ),
    );
  }

  Future<void> addNotification(NotificationEntity notification) async {
    final result = await addNotificationUseCase(notification);
    _emitResult(result);
  }

  Future<void> markRead(String id) async {
    final result = await markNotificationReadUseCase(id);
    _emitResult(result);
  }

  Future<void> markAllRead() async {
    final result = await markAllNotificationsReadUseCase();
    _emitResult(result);
  }

  void _emitResult(Either<Failure, List<NotificationEntity>> result) {
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: NotificationsStatus.failure, failure: failure),
      ),
      (items) => emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: items,
          clearFailure: true,
        ),
      ),
    );
  }
}
