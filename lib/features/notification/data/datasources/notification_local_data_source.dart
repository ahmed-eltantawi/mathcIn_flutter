import 'package:MatchIn/features/notification/data/models/notification_model.dart';

abstract interface class NotificationLocalDataSource {
  Future<List<NotificationModel>> getCachedNotifications({bool? unreadOnly});

  Future<void> saveNotifications(
    List<NotificationModel> notifications, {
    bool replace = false,
  });

  Future<NotificationModel?> markNotificationAsReadLocally(int id);

  Future<int> markAllNotificationsAsReadLocally();

  Future<int> getCachedUnreadCount();

  Future<void> saveUnreadCount(int count);

  Future<void> clearCache();
}
