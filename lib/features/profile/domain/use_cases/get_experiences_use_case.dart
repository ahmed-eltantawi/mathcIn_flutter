import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetExperiencesUseCase {
  const GetExperiencesUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, List<ExperienceEntity>>> call() {
    return repository.getExperiences();
  }
}
