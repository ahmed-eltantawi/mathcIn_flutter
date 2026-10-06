import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';
import 'package:MatchIn/features/notification/domain/entities/paginated_notifications_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, PaginatedNotificationsEntity>> getNotifications({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, NotificationEntity>> markNotificationAsRead({
    required int id,
  });

  Future<Either<Failure, int>> markAllNotificationsAsRead();
}
