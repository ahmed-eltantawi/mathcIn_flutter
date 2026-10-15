import 'package:MatchIn/features/jobsAndApplications/data/models/job_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.type,
    required this.status,
    this.coverLetter,
    this.notes,
    this.appliedAt,
    this.createdAt,
    this.updatedAt,
    this.job,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Live API shapes:
    //   details -> {'data': {'id','status','cover_letter','notes',...,'job'}}
    //   list    -> {'id','status','cover_letter','notes',...,'job'}
    // Legacy JSON:API -> {'data': {'id','type','attributes': {...}}}
    // Attributes (legacy) take precedence only when present.
    final dataObj = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final attributes = dataObj['attributes'] is Map<String, dynamic>
        ? dataObj['attributes'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final id = (dataObj['id'] ?? json['id'] ?? '').toString();
    final type =
        (dataObj['type'] ?? json['type'] ?? 'applications').toString();

    final status =
        (dataObj['status'] ?? attributes['status'] ?? 'applied').toString();
    final coverLetter =
        (dataObj['cover_letter'] ?? attributes['cover_letter']) as String?;
    final notes =
        (dataObj['notes'] ?? attributes['notes']) as String?;

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    final appliedAt = parseDate(
      dataObj['applied_at'] ?? attributes['applied_at'],
    );
    final createdAt = parseDate(
      dataObj['created_at'] ?? attributes['created_at'],
    );
    final updatedAt = parseDate(
      dataObj['updated_at'] ?? attributes['updated_at'],
    );

    JobModel? job;
    final jobJson =
        dataObj['job'] ?? attributes['job'] ?? dataObj['job_post'];
    if (jobJson is Map<String, dynamic>) {
      job = JobModel.fromJson(jobJson);
    }

    return ApplicationModel(
      id: id,
      type: type,
      status: status,
      coverLetter: coverLetter,
      notes: notes,
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
  final String? notes;
  final DateTime? appliedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final JobModel? job;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'cover_letter': coverLetter,
      'notes': notes,
      'applied_at': appliedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (job != null) 'job': job!.toJson(),
    };
  }

  ApplicationEntity toEntity() {
    return ApplicationEntity(
      id: id,
      type: type,
      status: ApplicationStatus.fromString(status),
      coverLetter: coverLetter,
      notes: notes,
      appliedAt: appliedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      job: job?.toEntity(),
    );
  }
}
