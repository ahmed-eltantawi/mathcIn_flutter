import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/applications_repository.dart';
import 'package:dartz/dartz.dart';

class GetApplicationDetailsUseCase {
  const GetApplicationDetailsUseCase({required this.repository});

  final ApplicationsRepository repository;

  Future<Either<Failure, ApplicationEntity>> call(String applicationId) {
    return repository.getApplicationDetails(applicationId);
  }
}
