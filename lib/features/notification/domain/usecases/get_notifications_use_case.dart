import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/notification/domain/entities/paginated_notifications_entity.dart';
import 'package:MatchIn/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase({required this.repository});

  final NotificationRepository repository;

  Future<Either<Failure, PaginatedNotificationsEntity>> call({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
  }) {
    return repository.getNotifications(
      page: page,
      perPage: perPage,
      unreadOnly: unreadOnly,
    );
  }
}
