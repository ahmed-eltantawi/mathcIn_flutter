import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/notification/data/models/notification_model.dart';
import 'package:MatchIn/features/notification/domain/entities/paginated_notifications_entity.dart';

class PaginatedNotificationsModel extends PaginatedNotificationsEntity {
  const PaginatedNotificationsModel({
    required super.notifications,
    required super.currentPage,
    required super.lastPage,
    required super.total,
    required super.hasMorePages,
  });

  factory PaginatedNotificationsModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawItems = [];
    if (json[ApiKey.data] is List) {
      rawItems = json[ApiKey.data] as List;
    } else if (json['items'] is List) {
      rawItems = json['items'] as List;
    } else if (json[ApiKey.data] is Map<String, dynamic> &&
        (json[ApiKey.data] as Map<String, dynamic>)['items'] is List) {
      rawItems = (json[ApiKey.data] as Map<String, dynamic>)['items'] as List;
    }

    final notifications = rawItems
        .whereType<Map<String, dynamic>>()
        .map((item) => NotificationModel.fromJson(item))
        .toList();

    final meta = json[ApiKey.meta] is Map<String, dynamic>
        ? json[ApiKey.meta] as Map<String, dynamic>
        : (json['pagination'] is Map<String, dynamic>
            ? json['pagination'] as Map<String, dynamic>
            : json);

    final currentPage = (meta['current_page'] as num?)?.toInt() ??
        (meta[ApiKey.page] as num?)?.toInt() ??
        1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ??
        (meta['total_pages'] as num?)?.toInt() ??
        (notifications.isEmpty ? 1 : currentPage);
    final total = (meta['total'] as num?)?.toInt() ?? notifications.length;
    final hasMorePages = currentPage < lastPage;

    return PaginatedNotificationsModel(
      notifications: notifications,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasMorePages: hasMorePages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKey.data: notifications
          .whereType<NotificationModel>()
          .map((n) => n.toJson())
          .toList(),
      ApiKey.meta: {
        'current_page': currentPage,
        'last_page': lastPage,
        'total': total,
      },
    };
  }
}
