import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SetThemeModeUseCase {
  const SetThemeModeUseCase({required this.repository});

  final SettingsRepository repository;

  Future<Either<Failure, Unit>> call(String themeMode) {
    return repository.setThemeMode(themeMode);
  }
}
