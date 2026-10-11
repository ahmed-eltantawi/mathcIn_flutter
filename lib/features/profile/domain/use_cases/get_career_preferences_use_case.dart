import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetCareerPreferencesUseCase {
  const GetCareerPreferencesUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CareerPreferenceEntity?>> call() {
    return repository.getCareerPreferences();
  }
}
