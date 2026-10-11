import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';
import 'package:MatchIn/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';

class MarkNotificationAsReadUseCase {
  const MarkNotificationAsReadUseCase({required this.repository});

  final NotificationRepository repository;

  Future<Either<Failure, NotificationEntity>> call({required int id}) {
    return repository.markNotificationAsRead(id: id);
  }
}
