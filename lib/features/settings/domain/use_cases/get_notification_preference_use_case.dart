import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class GetNotificationPreferenceUseCase {
  const GetNotificationPreferenceUseCase({required this.repository});

  final SettingsRepository repository;

  Future<Either<Failure, bool>> call() {
    return repository.getNotificationPreference();
  }
}
