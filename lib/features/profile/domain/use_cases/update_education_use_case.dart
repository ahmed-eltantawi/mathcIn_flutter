import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_education_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateEducationUseCase {
  const UpdateEducationUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, EducationEntity?>> call(UpdateEducationParams params) {
    return repository.updateEducation(params);
  }
}
