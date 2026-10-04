import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';

class CandidateProjectModel extends CandidateProjectEntity {
  const CandidateProjectModel({
    required super.id,
    required super.name,
    required super.technologies,
    required super.source,
    super.description,
    super.projectUrl,
    super.githubUrl,
    super.startDate,
    super.endDate,
  });

  factory CandidateProjectModel.fromJson(Map<String, dynamic> json) {
    return CandidateProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      technologies:
          (json['technologies'] as List<dynamic>?)
              ?.map((technology) => technology.toString())
              .toList() ??
          const [],
      projectUrl: json['project_url'] as String?,
      githubUrl: json['github_url'] as String?,
      source: json['source'] as String? ?? 'manual',
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }
}
