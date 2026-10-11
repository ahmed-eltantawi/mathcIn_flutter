import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/paginated_applications_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/applications_repository.dart';
import 'package:dartz/dartz.dart';

class GetCachedApplicationsUseCase {
  const GetCachedApplicationsUseCase({required this.repository});

  final ApplicationsRepository repository;

  Future<Either<Failure, PaginatedApplicationsEntity?>> call({
    String? status,
    String? search,
  }) {
    return repository.getCachedApplications(status: status, search: search);
  }
}
