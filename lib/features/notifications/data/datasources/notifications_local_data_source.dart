import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/notifications/data/models/notification_model.dart';

abstract class NotificationsLocalDataSource {
  List<NotificationModel> getNotifications();

  Future<List<NotificationModel>> addNotification(
    NotificationModel notification,
  );

  Future<List<NotificationModel>> markRead(String id);

  Future<List<NotificationModel>> markAllRead();
}

class NotificationsLocalDataSourceImpl implements NotificationsLocalDataSource {
  final Box<String> box;

  NotificationsLocalDataSourceImpl(this.box);

  @override
  List<NotificationModel> getNotifications() {
    final list = box.values.map((raw) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationModel.fromJson(map);
    }).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<NotificationModel>> addNotification(
    NotificationModel notification,
  ) async {
    await box.put(notification.id, jsonEncode(notification.toJson()));
    return getNotifications();
  }

  @override
  Future<List<NotificationModel>> markRead(String id) async {
    final raw = box.get(id);
    if (raw != null) {
      final model = NotificationModel.fromJson(jsonDecode(raw));
      final updated = NotificationModel.fromEntity(
        model.copyWith(isRead: true),
      );
      await box.put(id, jsonEncode(updated.toJson()));
    }
    return getNotifications();
  }

  @override
  Future<List<NotificationModel>> markAllRead() async {
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      final model = NotificationModel.fromJson(jsonDecode(raw));
      if (!model.isRead) {
        final updated = NotificationModel.fromEntity(
          model.copyWith(isRead: true),
        );
        await box.put(key, jsonEncode(updated.toJson()));
      }
    }
    return getNotifications();
  }
}
