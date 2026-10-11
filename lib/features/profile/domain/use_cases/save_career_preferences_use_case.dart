import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class SaveCareerPreferencesUseCase {
  const SaveCareerPreferencesUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CareerPreferenceEntity>> call(
    SaveCareerPreferencesParams params,
  ) {
    return repository.saveCareerPreferences(params);
  }
}
