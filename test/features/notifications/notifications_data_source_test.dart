import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:raff_app/features/notifications/data/models/notification_model.dart';
import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';

import '../../helpers/hive_helper.dart';

void main() {
  late Box<String> box;
  late Directory dir;
  late NotificationsLocalDataSourceImpl dataSource;

  NotificationModel notification(String id, DateTime createdAt) {
    return NotificationModel(
      id: id,
      type: NotificationType.general,
      createdAt: createdAt,
    );
  }

  setUp(() async {
    (box, dir) = await openTempBox('notifications_test');
    dataSource = NotificationsLocalDataSourceImpl(box);
  });

  tearDown(() => closeTempBox(box, dir));

  test('the newest notification comes first', () async {
    await dataSource.addNotification(notification('old', DateTime(2026, 1, 1)));
    final result = await dataSource.addNotification(
      notification('new', DateTime(2026, 2, 1)),
    );

    expect(result.map((n) => n.id), ['new', 'old']);
  });

  test('markRead only changes that notification', () async {
    await dataSource.addNotification(notification('a', DateTime(2026, 1, 1)));
    await dataSource.addNotification(notification('b', DateTime(2026, 1, 2)));

    final result = await dataSource.markRead('a');

    expect(result.firstWhere((n) => n.id == 'a').isRead, isTrue);
    expect(result.firstWhere((n) => n.id == 'b').isRead, isFalse);
  });

  test('markAllRead marks every notification', () async {
    await dataSource.addNotification(notification('a', DateTime(2026, 1, 1)));
    await dataSource.addNotification(notification('b', DateTime(2026, 1, 2)));

    final result = await dataSource.markAllRead();

    expect(result.every((n) => n.isRead), isTrue);
  });

  test('only the 100 newest notifications are kept', () async {
    final base = DateTime(2026, 1, 1);
    for (var i = 0; i < 105; i++) {
      await dataSource.addNotification(
        notification('n$i', base.add(Duration(minutes: i))),
      );
    }

    final result = dataSource.getNotifications();

    expect(result, hasLength(100));
    expect(box.length, 100);
    expect(result.first.id, 'n104');
    expect(result.last.id, 'n5');
    expect(result.any((n) => n.id == 'n0'), isFalse);
  });

  test('the returned list is a copy that cannot change the cache', () async {
    await dataSource.addNotification(notification('a', DateTime(2026, 1, 1)));

    final list = dataSource.getNotifications();

    expect(
      () => list.add(notification('b', DateTime(2026, 1, 2))),
      throwsUnsupportedError,
    );
    expect(dataSource.getNotifications(), hasLength(1));
  });

  test('clearAll empties the box and the cache', () async {
    await dataSource.addNotification(notification('a', DateTime(2026, 1, 1)));

    await dataSource.clearAll();

    expect(dataSource.getNotifications(), isEmpty);
    expect(box.isEmpty, isTrue);
  });
}
