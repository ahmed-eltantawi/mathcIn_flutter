import 'dart:async';

import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';

class NotificationService {
  NotificationService();

  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  Stream<int> get unreadCountStream => _unreadCountController.stream;

  void updateUnreadCount(int count) {
    if (!_unreadCountController.isClosed) {
      _unreadCountController.add(count < 0 ? 0 : count);
    }
  }

  int calculateUnreadCount(List<NotificationEntity> notifications) {
    return notifications.where((notification) => !notification.isRead).length;
  }

  List<NotificationEntity> filterUnreadOnly(
    List<NotificationEntity> notifications,
  ) {
    return notifications.where((notification) => !notification.isRead).toList();
  }

  List<NotificationEntity> markNotificationAsReadInList({
    required List<NotificationEntity> notifications,
    required int id,
    String? readAt,
  }) {
    return notifications.map((notification) {
      if (notification.id == id) {
        return notification.copyWith(
          isRead: true,
          readAt: readAt ?? DateTime.now().toIso8601String(),
        );
      }
      return notification;
    }).toList();
  }

  List<NotificationEntity> markAllNotificationsAsReadInList({
    required List<NotificationEntity> notifications,
    String? readAt,
  }) {
    final nowIso = readAt ?? DateTime.now().toIso8601String();
    return notifications.map((notification) {
      if (!notification.isRead) {
        return notification.copyWith(
          isRead: true,
          readAt: nowIso,
        );
      }
      return notification;
    }).toList();
  }

  NotificationEntity normalizeNotification(NotificationEntity notification) {
    return notification.copyWith(
      title: notification.title.trim(),
      message: notification.message.trim(),
    );
  }

  void dispose() {
    _unreadCountController.close();
  }
}
