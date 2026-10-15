import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetEducationsUseCase {
  const GetEducationsUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, List<EducationEntity>>> call() {
    return repository.getEducations();
  }
}
