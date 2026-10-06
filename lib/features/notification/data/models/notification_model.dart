import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    super.readAt,
    required super.isRead,
    super.createdAt,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawIsRead = json[ApiKey.isRead];
    final readAt = json[ApiKey.readAt]?.toString();
    final bool isRead;
    if (rawIsRead is bool) {
      isRead = rawIsRead;
    } else if (rawIsRead is num) {
      isRead = rawIsRead == 1;
    } else {
      isRead = readAt != null;
    }

    return NotificationModel(
      id: (json[ApiKey.id] as num?)?.toInt() ?? 0,
      type: json[ApiKey.type]?.toString() ?? '',
      title: json[ApiKey.title]?.toString() ?? '',
      message: json[ApiKey.errorMessage]?.toString() ?? '',
      readAt: readAt,
      isRead: isRead,
      createdAt: json[ApiKey.createdAt]?.toString(),
      data: json[ApiKey.data] is Map<String, dynamic>
          ? json[ApiKey.data] as Map<String, dynamic>
          : null,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      message: entity.message,
      readAt: entity.readAt,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      data: entity.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKey.id: id,
      ApiKey.type: type,
      ApiKey.title: title,
      ApiKey.errorMessage: message,
      ApiKey.readAt: readAt,
      ApiKey.isRead: isRead,
      ApiKey.createdAt: createdAt,
      ApiKey.data: data,
    };
  }
}
