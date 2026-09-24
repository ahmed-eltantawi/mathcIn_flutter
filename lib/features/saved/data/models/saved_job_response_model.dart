import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';

class SavedJobResponseModel extends SavedJobEntity {
  const SavedJobResponseModel({
    required super.id,
    required super.title,
    required super.company,
    required super.location,
    required super.workMode,
    required super.experience,
    required super.jobType,
    required super.postedDate,
    required super.skills,
    super.matchPercentage,
    super.isSaved = true,
  });

  factory SavedJobResponseModel.fromJson(Map<String, dynamic> json) {
    // Company can be string or object {"name": "TechNova"}
    String companyName = 'Unknown Company';
    if (json['company'] is String) {
      companyName = json['company'] as String;
    } else if (json['company'] is Map<String, dynamic>) {
      companyName = (json['company']['name'] as String?) ?? 'Unknown Company';
    } else if (json['company_name'] is String) {
      companyName = json['company_name'] as String;
    }

    // Skills can be List<String> or List<Map>
    final List<String> parsedSkills = [];
    if (json['skills'] is List) {
      for (final skill in json['skills'] as List) {
        if (skill is String) {
          parsedSkills.add(skill);
        } else if (skill is Map<String, dynamic> && skill['name'] is String) {
          parsedSkills.add(skill['name'] as String);
        }
      }
    }

    return SavedJobResponseModel(
      id: (json['id'] as num?)?.toInt() ??
          (json['job_id'] as num?)?.toInt() ??
          (json['job_post_id'] as num?)?.toInt() ??
          0,
      title: (json['title'] as String?) ?? 'Job Title',
      company: companyName,
      location: (json['location'] as String?) ?? 'Cairo, Egypt',
      workMode: (json['work_mode'] as String?) ??
          (json['workMode'] as String?) ??
          'Hybrid',
      experience: (json['experience'] as String?) ??
          (json['experience_level'] as String?) ??
          '0-2 years',
      jobType: (json['job_type'] as String?) ??
          (json['jobType'] as String?) ??
          'Full-time',
      postedDate: (json['posted_date'] as String?) ??
          (json['postedDate'] as String?) ??
          (json['created_at'] as String?) ??
          'Recently',
      skills: parsedSkills,
      matchPercentage: (json['match_percentage'] as num?)?.toInt() ??
          (json['matchPercentage'] as num?)?.toInt(),
      isSaved: (json['is_saved'] as bool?) ?? true,
    );
  }
}
