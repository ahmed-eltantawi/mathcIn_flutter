import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateExperienceUseCase {
  const UpdateExperienceUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, ExperienceEntity?>> call(
    UpdateExperienceParams params,
  ) {
    return repository.updateExperience(params);
  }
}
