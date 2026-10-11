import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SetLanguageUseCase {
  const SetLanguageUseCase({required this.repository});

  final SettingsRepository repository;

  Future<Either<Failure, Unit>> call(String languageCode) {
    return repository.setLanguageCode(languageCode);
  }
}
