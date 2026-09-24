import 'package:MatchIn/features/saved/data/models/paginated_saved_jobs_model.dart';
import 'package:MatchIn/features/saved/data/models/save_job_toggle_model.dart';

abstract class SavedJobsRemoteDataSource {
  Future<PaginatedSavedJobsModel> getSavedJobs({
    int page = 1,
    int perPage = 15,
  });

  Future<SaveJobToggleModel> saveJob({required int jobPostId});

  Future<SaveJobToggleModel> unsaveJob({required int jobPostId});
}
