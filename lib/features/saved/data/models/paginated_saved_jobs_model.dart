import 'package:MatchIn/features/saved/data/models/saved_job_response_model.dart';
import 'package:MatchIn/features/saved/domain/entities/paginated_saved_jobs_entity.dart';

class PaginatedSavedJobsModel extends PaginatedSavedJobsEntity {
  const PaginatedSavedJobsModel({
    required super.jobs,
    required super.currentPage,
    required super.lastPage,
    required super.total,
    required super.hasMorePages,
  });

  factory PaginatedSavedJobsModel.fromJson(Map<String, dynamic> json) {
    // Extract list of items
    List<dynamic> rawItems = [];
    if (json['data'] is List) {
      rawItems = json['data'] as List;
    } else if (json['items'] is List) {
      rawItems = json['items'] as List;
    } else if (json['data'] is Map<String, dynamic> && json['data']['items'] is List) {
      rawItems = json['data']['items'] as List;
    }

    final jobs = rawItems
        .whereType<Map<String, dynamic>>()
        .map((item) => SavedJobResponseModel.fromJson(item))
        .toList();

    // Extract pagination meta
    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : (json['pagination'] is Map<String, dynamic>
            ? json['pagination'] as Map<String, dynamic>
            : json);

    final currentPage = (meta['current_page'] as num?)?.toInt() ??
        (meta['page'] as num?)?.toInt() ??
        1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ??
        (meta['total_pages'] as num?)?.toInt() ??
        1;
    final total = (meta['total'] as num?)?.toInt() ?? jobs.length;
    final hasMorePages = currentPage < lastPage;

    return PaginatedSavedJobsModel(
      jobs: jobs,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasMorePages: hasMorePages,
    );
  }
}
