import 'package:equatable/equatable.dart';

/// نوع الإشعار — النصوص بتتولد منه بالترجمة في الشاشة،
/// فمنخزنش أبدًا نص مترجم في قاعدة البيانات.
enum NotificationType { orderPlaced, promo, general }

class NotificationEntity extends Equatable {
  final String id;
  final NotificationType type;

  final String? orderId;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.type,
    this.orderId,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      type: type,
      orderId: orderId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, type, orderId, createdAt, isRead];
}
