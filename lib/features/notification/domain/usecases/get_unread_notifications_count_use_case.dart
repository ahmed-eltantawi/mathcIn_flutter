import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';

class GetUnreadNotificationsCountUseCase {
  const GetUnreadNotificationsCountUseCase({required this.repository});

  final NotificationRepository repository;

  Future<Either<Failure, int>> call() {
    return repository.getUnreadCount();
  }
}
