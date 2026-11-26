import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:raff_app/features/notifications/domain/usecases/add_notification_use_case.dart';
import 'package:raff_app/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:raff_app/features/notifications/domain/usecases/mark_all_notifications_read_use_case.dart';
import 'package:raff_app/features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_state.dart';

class MockGetNotificationsUseCase extends Mock
    implements GetNotificationsUseCase {}

class MockAddNotificationUseCase extends Mock
    implements AddNotificationUseCase {}

class MockMarkNotificationReadUseCase extends Mock
    implements MarkNotificationReadUseCase {}

class MockMarkAllNotificationsReadUseCase extends Mock
    implements MarkAllNotificationsReadUseCase {}

void main() {
  late MockGetNotificationsUseCase getNotifications;
  late MockAddNotificationUseCase addNotification;
  late MockMarkNotificationReadUseCase markRead;
  late MockMarkAllNotificationsReadUseCase markAllRead;

  final promo = NotificationEntity(
    id: '1',
    type: NotificationType.promo,
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() => registerFallbackValue(promo));

  setUp(() {
    getNotifications = MockGetNotificationsUseCase();
    addNotification = MockAddNotificationUseCase();
    markRead = MockMarkNotificationReadUseCase();
    markAllRead = MockMarkAllNotificationsReadUseCase();
  });

  NotificationsCubit buildCubit() => NotificationsCubit(
    getNotificationsUseCase: getNotifications,
    addNotificationUseCase: addNotification,
    markNotificationReadUseCase: markRead,
    markAllNotificationsReadUseCase: markAllRead,
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'loadNotifications shows the saved notifications',
    build: () {
      when(() => getNotifications()).thenReturn(Right([promo]));
      return buildCubit();
    },
    act: (cubit) => cubit.loadNotifications(),
    expect: () => [
      const NotificationsState(status: NotificationsStatus.loading),
      NotificationsState(
        status: NotificationsStatus.success,
        notifications: [promo],
      ),
    ],
    verify: (_) => verifyNever(() => addNotification(any())),
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'loadNotifications adds the welcome promo when the list is empty',
    build: () {
      when(() => getNotifications()).thenReturn(const Right([]));
      when(() => addNotification(any()))
          .thenAnswer((_) async => Right([promo]));
      return buildCubit();
    },
    act: (cubit) => cubit.loadNotifications(),
    verify: (cubit) {
      final captured = verify(() => addNotification(captureAny())).captured;
      expect(
        (captured.single as NotificationEntity).type,
        NotificationType.promo,
      );
      expect(cubit.state.notifications, [promo]);
    },
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'loadNotifications emits failure when reading fails',
    build: () {
      when(() => getNotifications()).thenReturn(const Left(UnknownFailure()));
      return buildCubit();
    },
    act: (cubit) => cubit.loadNotifications(),
    expect: () => [
      const NotificationsState(status: NotificationsStatus.loading),
      const NotificationsState(
        status: NotificationsStatus.failure,
        failure: UnknownFailure(),
      ),
    ],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'markRead emits the updated list',
    build: () {
      when(() => markRead('1'))
          .thenAnswer((_) async => Right([promo.copyWith(isRead: true)]));
      return buildCubit();
    },
    act: (cubit) => cubit.markRead('1'),
    verify: (cubit) => expect(cubit.state.notifications.single.isRead, isTrue),
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'markAllRead emits the updated list',
    build: () {
      when(() => markAllRead())
          .thenAnswer((_) async => Right([promo.copyWith(isRead: true)]));
      return buildCubit();
    },
    act: (cubit) => cubit.markAllRead(),
    verify: (cubit) => expect(cubit.state.status, NotificationsStatus.success),
  );
}
