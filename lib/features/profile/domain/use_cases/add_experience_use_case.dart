import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class AddExperienceUseCase {
  const AddExperienceUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, ExperienceEntity?>> call(AddExperienceParams params) {
    return repository.addExperience(params);
  }
}
