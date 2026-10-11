import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SetNotificationPreferenceUseCase {
  const SetNotificationPreferenceUseCase({required this.repository});

  final SettingsRepository repository;

  Future<Either<Failure, Unit>> call(bool enabled) {
    return repository.setNotificationPreference(enabled);
  }
}
