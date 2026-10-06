import 'package:MatchIn/features/jobsAndApplications/data/models/job_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.type,
    required this.status,
    this.coverLetter,
    this.appliedAt,
    this.createdAt,
    this.updatedAt,
    this.job,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Check if JSON has a nested 'data' key or attributes
    final dataObj = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final id = (dataObj['id'] ?? json['id'] ?? '').toString();
    final type = (dataObj['type'] ?? json['type'] ?? 'applications').toString();

    final attributes = dataObj['attributes'] is Map<String, dynamic>
        ? dataObj['attributes'] as Map<String, dynamic>
        : dataObj;

    final status = (attributes['status'] ?? 'applied').toString();
    final coverLetter = attributes['cover_letter'] as String?;

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    final appliedAt = parseDate(attributes['applied_at']);
    final createdAt = parseDate(attributes['created_at']);
    final updatedAt = parseDate(attributes['updated_at']);

    JobModel? job;
    if (attributes['job'] is Map<String, dynamic>) {
      job = JobModel.fromJson(attributes['job'] as Map<String, dynamic>);
    } else if (dataObj['job'] is Map<String, dynamic>) {
      job = JobModel.fromJson(dataObj['job'] as Map<String, dynamic>);
    }

    return ApplicationModel(
      id: id,
      type: type,
      status: status,
      coverLetter: coverLetter,
      appliedAt: appliedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      job: job,
    );
  }

  final String id;
  final String type;
  final String status;
  final String? coverLetter;
  final DateTime? appliedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final JobModel? job;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'attributes': {
        'status': status,
        'cover_letter': coverLetter,
        'applied_at': appliedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        if (job != null) 'job': job!.toJson(),
      },
    };
  }

  ApplicationEntity toEntity() {
    return ApplicationEntity(
      id: id,
      type: type,
      status: ApplicationStatus.fromString(status),
      coverLetter: coverLetter,
      appliedAt: appliedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      job: job?.toEntity(),
    );
  }
}
