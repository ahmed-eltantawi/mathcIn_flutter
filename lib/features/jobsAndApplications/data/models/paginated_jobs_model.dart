import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/job_links_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/job_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/job_pagination_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_pagination_entity.dart';

class PaginatedJobsModel {
  const PaginatedJobsModel({required this.data, this.links, this.meta});

  factory PaginatedJobsModel.fromJson(Map<String, dynamic> json) {
    List<JobModel> jobs = [];
    if (json[ApiKey.data] is List) {
      jobs = (json[ApiKey.data] as List)
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList();
    }

    JobLinksModel? links;
    if (json[ApiKey.links] is Map<String, dynamic>) {
      links = JobLinksModel.fromJson(json[ApiKey.links] as Map<String, dynamic>);
    }

    JobPaginationModel? meta;
    if (json[ApiKey.meta] is Map<String, dynamic>) {
      meta = JobPaginationModel.fromJson(json[ApiKey.meta] as Map<String, dynamic>);
    }

    return PaginatedJobsModel(data: jobs, links: links, meta: meta);
  }

  final List<JobModel> data;
  final JobLinksModel? links;
  final JobPaginationModel? meta;

  Map<String, dynamic> toJson() {
    return {
      ApiKey.data: data.map((j) => j.toJson()).toList(),
      ApiKey.links: links?.toJson(),
      ApiKey.meta: meta?.toJson(),
    };
  }

  PaginatedJobsEntity toEntity() {
    return PaginatedJobsEntity(
      jobs: data.map((model) => model.toEntity()).toList(),
      pagination: meta?.toEntity(),
    );
  }
}
