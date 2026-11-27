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
  final readPromo = promo.copyWith(isRead: true);

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

  group('NotificationsState', () {
    test('non-success states expose safe empty collections', () {
      const states = <NotificationsState>[
        NotificationsInitial(),
        NotificationsLoading(),
        NotificationsFailure(UnknownFailure()),
      ];

      for (final state in states) {
        expect(state.notifications, isEmpty);
        expect(state.unreadCount, 0);
        expect(state.todayNotifications, isEmpty);
        expect(state.earlierNotifications, isEmpty);
      }

      const failure = NotificationsFailure(UnknownFailure());
      expect(failure.failure, const UnknownFailure());
    });

    test('success exposes unread count and time groups', () {
      final today = NotificationEntity(
        id: 'today',
        type: NotificationType.general,
        createdAt: DateTime.now(),
      );
      final earlier = NotificationEntity(
        id: 'earlier',
        type: NotificationType.orderPlaced,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      );

      final state = NotificationsSuccess([today, earlier]);

      expect(state.unreadCount, 1);
      expect(state.todayNotifications.map((n) => n.id), ['today']);
      expect(state.earlierNotifications.map((n) => n.id), ['earlier']);
    });
  });

  blocTest<NotificationsCubit, NotificationsState>(
    'loadNotifications shows the saved notifications',
    build: () {
      when(() => getNotifications()).thenReturn(Right([promo]));
      return buildCubit();
    },
    act: (cubit) => cubit.loadNotifications(),
    expect: () => [
      const NotificationsLoading(),
      NotificationsSuccess([promo]),
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
    expect: () => [
      const NotificationsLoading(),
      NotificationsSuccess([promo]),
    ],
    verify: (cubit) {
      final captured = verify(() => addNotification(captureAny())).captured;
      expect(
        (captured.single as NotificationEntity).type,
        NotificationType.promo,
      );
      expect(cubit.state, NotificationsSuccess([promo]));
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
      const NotificationsLoading(),
      const NotificationsFailure(UnknownFailure()),
    ],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'ensureLoaded loads from the initial state',
    build: () {
      when(() => getNotifications()).thenReturn(Right([promo]));
      return buildCubit();
    },
    act: (cubit) => cubit.ensureLoaded(),
    expect: () => [
      const NotificationsLoading(),
      NotificationsSuccess([promo]),
    ],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'ensureLoaded retries after a failure',
    build: () {
      when(() => getNotifications()).thenReturn(Right([promo]));
      return buildCubit();
    },
    seed: () => const NotificationsFailure(NetworkFailure()),
    act: (cubit) => cubit.ensureLoaded(),
    expect: () => [
      const NotificationsLoading(),
      NotificationsSuccess([promo]),
    ],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'ensureLoaded does not reload when data already exists',
    build: buildCubit,
    seed: () => NotificationsSuccess([promo]),
    act: (cubit) => cubit.ensureLoaded(),
    expect: () => const <NotificationsState>[],
    verify: (_) => verifyNever(() => getNotifications()),
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'reset returns to the initial state',
    build: buildCubit,
    seed: () => NotificationsSuccess([promo]),
    act: (cubit) => cubit.reset(),
    expect: () => [const NotificationsInitial()],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'markRead emits the updated list',
    build: () {
      when(() => markRead('1')).thenAnswer((_) async => Right([readPromo]));
      return buildCubit();
    },
    act: (cubit) => cubit.markRead('1'),
    expect: () => [
      NotificationsSuccess([readPromo]),
    ],
    verify: (cubit) {
      expect(cubit.state, NotificationsSuccess([readPromo]));
      expect(cubit.state.unreadCount, 0);
    },
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'markRead emits failure when the update fails',
    build: () {
      when(() => markRead('1'))
          .thenAnswer((_) async => const Left(NetworkFailure()));
      return buildCubit();
    },
    act: (cubit) => cubit.markRead('1'),
    expect: () => [const NotificationsFailure(NetworkFailure())],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'markAllRead emits the updated list',
    build: () {
      when(() => markAllRead()).thenAnswer((_) async => Right([readPromo]));
      return buildCubit();
    },
    act: (cubit) => cubit.markAllRead(),
    expect: () => [
      NotificationsSuccess([readPromo]),
    ],
    verify: (cubit) => expect(cubit.state, NotificationsSuccess([readPromo])),
  );
}
