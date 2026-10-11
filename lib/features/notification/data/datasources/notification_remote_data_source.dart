import 'package:MatchIn/features/notification/data/models/notification_model.dart';
import 'package:MatchIn/features/notification/data/models/paginated_notifications_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<PaginatedNotificationsModel> getNotifications({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
  });

  Future<int> getUnreadCount();

  Future<NotificationModel> markNotificationAsRead({required int id});

  Future<int> markAllNotificationsAsRead();
}
