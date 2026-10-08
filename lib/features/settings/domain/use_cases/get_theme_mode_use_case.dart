import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class GetThemeModeUseCase {
  const GetThemeModeUseCase({required this.repository});

  final SettingsRepository repository;

  Future<Either<Failure, String>> call() {
    return repository.getThemeMode();
  }
}
