import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source.dart';
import 'package:MatchIn/features/saved/data/models/paginated_saved_jobs_model.dart';
import 'package:MatchIn/features/saved/data/models/save_job_toggle_model.dart';

class SavedJobsRemoteDataSourceImpl implements SavedJobsRemoteDataSource {
  const SavedJobsRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<PaginatedSavedJobsModel> getSavedJobs({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await apiConsumer.get(
      EndPoint.savedJobs,
      queryParameters: {
        ApiKey.page: page,
        ApiKey.perPage: perPage,
      },
    );

    if (response is Map<String, dynamic>) {
      return PaginatedSavedJobsModel.fromJson(response);
    }
    throw const FormatException('Invalid response format for saved jobs');
  }

  @override
  Future<SaveJobToggleModel> saveJob({required int jobPostId}) async {
    final response = await apiConsumer.post(
      EndPoint.saveJob(jobPostId),
    );

    if (response is Map<String, dynamic>) {
      return SaveJobToggleModel.fromJson(response);
    }
    return SaveJobToggleModel(jobId: jobPostId, isSaved: true);
  }

  @override
  Future<SaveJobToggleModel> unsaveJob({required int jobPostId}) async {
    final response = await apiConsumer.delete(
      EndPoint.saveJob(jobPostId),
    );

    if (response is Map<String, dynamic>) {
      return SaveJobToggleModel.fromJson(response);
    }
    return SaveJobToggleModel(jobId: jobPostId, isSaved: false);
  }
}
