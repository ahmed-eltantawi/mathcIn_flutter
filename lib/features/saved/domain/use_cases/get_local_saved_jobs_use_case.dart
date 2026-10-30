import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';

class GetLocalSavedJobsUseCase {
  const GetLocalSavedJobsUseCase({required this.repository});

  final SavedJobsRepository repository;

  Future<List<SavedJobEntity>> call() {
    return repository.getLocalSavedJobs();
  }
}
