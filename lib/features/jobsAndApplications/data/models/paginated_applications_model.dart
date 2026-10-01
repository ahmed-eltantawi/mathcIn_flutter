import 'package:MatchIn/features/jobsAndApplications/data/models/application_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/paginated_applications_entity.dart';

class PaginatedApplicationsModel {
  const PaginatedApplicationsModel({
    required this.applications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasNextPage,
  });

  factory PaginatedApplicationsModel.fromJson(Map<String, dynamic> json) {
    List<ApplicationModel> apps = [];

    if (json['data'] is List) {
      final list = json['data'] as List;
      apps = list
          .whereType<Map<String, dynamic>>()
          .map((item) => ApplicationModel.fromJson(item))
          .toList();
    }

    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    final currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
    final total = (meta['total'] as num?)?.toInt() ?? apps.length;
    final hasNextPage = currentPage < lastPage;

    return PaginatedApplicationsModel(
      applications: apps,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasNextPage: hasNextPage,
    );
  }

  final List<ApplicationModel> applications;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasNextPage;

  Map<String, dynamic> toJson() {
    return {
      'data': applications.map((app) => app.toJson()).toList(),
      'meta': {
        'current_page': currentPage,
        'last_page': lastPage,
        'total': total,
      },
    };
  }

  PaginatedApplicationsEntity toEntity() {
    return PaginatedApplicationsEntity(
      applications: applications.map((app) => app.toEntity()).toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasNextPage: hasNextPage,
    );
  }
}
