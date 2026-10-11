import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/paginated_applications_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ApplicationsRepository {
  Future<Either<Failure, PaginatedApplicationsEntity>> getApplications({
    String? status,
    String? search,
    int page = 1,
  });

  Future<Either<Failure, PaginatedApplicationsEntity?>> getCachedApplications({
    String? status,
    String? search,
  });

  Future<Either<Failure, ApplicationEntity>> getApplicationDetails(
    String applicationId,
  );

  Future<Either<Failure, ApplicationEntity>> applyToJob({
    required int jobId,
    String? coverLetter,
  });

  Future<Either<Failure, ApplicationEntity>> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? notes,
  });

  Future<Either<Failure, ApplicationEntity>> withdrawApplication(
    String applicationId,
  );
}
