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

  Future<void> clearAll();
}

class NotificationsLocalDataSourceImpl implements NotificationsLocalDataSource {
  /// أقصى عدد إشعارات محفوظة، الأحدث بس هو اللي بيفضل.
  static const int _maxRetained = 100;

  final Box<String> box;

  NotificationsLocalDataSourceImpl(this.box);

  /// الإشعارات مرتبة تنازليًا بالتاريخ، ومفكوكة من الـ JSON مرة واحدة.
  List<NotificationModel>? _notificationsCache;

  void _ensureLoaded() {
    if (_notificationsCache != null) return;
    final notifications = box.values
        .map(
          (raw) => NotificationModel.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          ),
        )
        .toList();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (notifications.length > _maxRetained) {
      final overflow = notifications.sublist(_maxRetained);
      notifications.removeRange(_maxRetained, notifications.length);
      // Disk cleanup can finish in the background; the memory cap is applied
      // immediately and the next add trims again if needed. Ignore deletion
      // errors so a cleanup failure cannot crash the app.
      box.deleteAll(overflow.map((n) => n.id)).ignore();
    }

    _notificationsCache = notifications;
  }

  List<NotificationModel> get _notifications {
    _ensureLoaded();
    return _notificationsCache!;
  }

  @override
  List<NotificationModel> getNotifications() {
    return List<NotificationModel>.unmodifiable(_notifications);
  }

  @override
  Future<List<NotificationModel>> addNotification(
    NotificationModel notification,
  ) async {
    final notifications = _notifications;
    await box.put(notification.id, jsonEncode(notification.toJson()));

    final index = notifications.indexWhere((n) => n.id == notification.id);
    if (index >= 0) {
      notifications[index] = notification;
    } else {
      notifications.add(notification);
    }
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (notifications.length > _maxRetained) {
      final overflow = notifications.sublist(_maxRetained);
      notifications.removeRange(_maxRetained, notifications.length);
      await box.deleteAll(overflow.map((n) => n.id));
    }
    return getNotifications();
  }

  @override
  Future<List<NotificationModel>> markRead(String id) async {
    final notifications = _notifications;
    final index = notifications.indexWhere((n) => n.id == id);
    if (index >= 0 && !notifications[index].isRead) {
      final updated = NotificationModel.fromEntity(
        notifications[index].copyWith(isRead: true),
      );
      notifications[index] = updated;
      await box.put(id, jsonEncode(updated.toJson()));
    }
    return getNotifications();
  }

  @override
  Future<List<NotificationModel>> markAllRead() async {
    final notifications = _notifications;
    final changed = <String, String>{};
    for (var i = 0; i < notifications.length; i++) {
      final model = notifications[i];
      if (model.isRead) continue;
      final updated = NotificationModel.fromEntity(
        model.copyWith(isRead: true),
      );
      notifications[i] = updated;
      changed[updated.id] = jsonEncode(updated.toJson());
    }
    if (changed.isNotEmpty) {
      await box.putAll(changed);
    }
    return getNotifications();
  }

  @override
  Future<void> clearAll() async {
    await box.clear();
    _notificationsCache = <NotificationModel>[];
  }
}
