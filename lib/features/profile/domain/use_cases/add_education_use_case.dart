import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class AddEducationUseCase {
  const AddEducationUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, EducationEntity?>> call(AddEducationParams params) {
    return repository.addEducation(params);
  }
}
