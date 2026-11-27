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
  }) : super(const NotificationsInitial());

  /// Clears in-memory notifications state after the user-scoped storage is
  /// wiped.
  void reset() => emit(const NotificationsInitial());

  /// Loads only when there is no usable state yet. Safe to call from screens.
  void ensureLoaded() {
    switch (state) {
      case NotificationsInitial():
      case NotificationsFailure():
        loadNotifications();
        break;
      case NotificationsLoading():
      case NotificationsSuccess():
        break;
    }
  }

  Future<void> loadNotifications() async {
    if (isClosed || state is NotificationsLoading) return;

    emit(const NotificationsLoading());

    final result = getNotificationsUseCase();
    if (isClosed) return;

    switch (result) {
      case Left(value: final failure):
        emit(NotificationsFailure(failure));
        return;
      case Right(value: final loaded):
        if (loaded.isNotEmpty) {
          emit(NotificationsSuccess(loaded));
          return;
        }
    }

    // أول مرة يفتح التطبيق: نزرع إشعار ترحيب بالبرومو كود
    // عشان الشاشة متفتحش فاضية
    final seedResult = await addNotificationUseCase(
      NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotificationType.promo,
        createdAt: DateTime.now(),
      ),
    );

    if (isClosed) return;

    final seeded = seedResult.fold(
      (_) => const <NotificationEntity>[],
      (items) => items,
    );
    emit(NotificationsSuccess(seeded));
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

    switch (result) {
      case Left(value: final failure):
        emit(NotificationsFailure(failure));
        break;
      case Right(value: final items):
        emit(NotificationsSuccess(items));
        break;
    }
  }
}
