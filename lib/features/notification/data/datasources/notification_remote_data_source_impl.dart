import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:MatchIn/features/notification/data/models/notification_model.dart';
import 'package:MatchIn/features/notification/data/models/paginated_notifications_model.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<PaginatedNotificationsModel> getNotifications({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
  }) async {
    final queryParameters = <String, dynamic>{
      ApiKey.page: page,
      ApiKey.perPage: perPage,
      if (unreadOnly == true) ApiKey.unreadOnly: true,
    };

    final response = await apiConsumer.get(
      EndPoint.notifications,
      queryParameters: queryParameters,
    );

    if (response is Map<String, dynamic>) {
      return PaginatedNotificationsModel.fromJson(response);
    } else if (response is List) {
      return PaginatedNotificationsModel.fromJson({
        ApiKey.data: response,
        ApiKey.meta: {
          'current_page': page,
          'last_page': page,
          'total': response.length,
        },
      });
    }

    return const PaginatedNotificationsModel(
      notifications: [],
      currentPage: 1,
      lastPage: 1,
      total: 0,
      hasMorePages: false,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await apiConsumer.get(EndPoint.notificationsUnreadCount);

    if (response is Map<String, dynamic>) {
      final data = response[ApiKey.data];
      if (data is Map<String, dynamic>) {
        return (data[ApiKey.count] as num?)?.toInt() ?? 0;
      }
      return (response[ApiKey.count] as num?)?.toInt() ?? 0;
    }

    return 0;
  }

  @override
  Future<NotificationModel> markNotificationAsRead({required int id}) async {
    final response = await apiConsumer.patch(
      EndPoint.markNotificationAsRead(id),
    );

    if (response is Map<String, dynamic>) {
      final data = response[ApiKey.data];
      if (data is Map<String, dynamic>) {
        return NotificationModel.fromJson(data);
      }
      return NotificationModel.fromJson(response);
    }

    return NotificationModel(
      id: id,
      type: 'notification',
      title: '',
      message: '',
      isRead: true,
      readAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<int> markAllNotificationsAsRead() async {
    final response = await apiConsumer.patch(EndPoint.notificationsReadAll);

    if (response is Map<String, dynamic>) {
      final data = response[ApiKey.data];
      if (data is Map<String, dynamic>) {
        return (data[ApiKey.updatedCount] as num?)?.toInt() ?? 0;
      }
      return (response[ApiKey.updatedCount] as num?)?.toInt() ?? 0;
    }

    return 0;
  }
}
