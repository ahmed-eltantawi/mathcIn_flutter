import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase {
  const LogoutUseCase({required this.repository});

  final SettingsRepository repository;

  Future<Either<Failure, Unit>> call() {
    return repository.logout();
  }
}
