import 'package:raff_app/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    super.orderId,
    required super.createdAt,
    super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: NotificationType.values.byName(
        json['type'] as String? ?? 'general',
      ),
      orderId: json['orderId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type,
      orderId: entity.orderId,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'orderId': orderId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
