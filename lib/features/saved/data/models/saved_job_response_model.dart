import 'package:MatchIn/features/jobsAndApplications/data/models/company_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/skill_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/company_entity.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';

class SavedJobResponseModel extends SavedJobEntity {
  const SavedJobResponseModel({
    required super.id,
    required super.title,
    required super.company,
    super.companyLogoUrl,
    super.companyEntity,
    required super.location,
    required super.workMode,
    required super.experience,
    required super.jobType,
    required super.postedDate,
    required super.skills,
    super.requiredSkills,
    super.preferredSkills,
    super.isExpired = false,
    super.matchPercentage,
    super.isSaved = true,
  });

  factory SavedJobResponseModel.fromJson(Map<String, dynamic> json) {
    // Company can be string or object {"name": "TechNova", "logo_url": "..."}
    String companyName = 'Unknown Company';
    String? companyLogoUrl;
    CompanyEntity? companyEntity;

    if (json['company'] is String) {
      companyName = json['company'] as String;
    } else if (json['company'] is Map<String, dynamic>) {
      final compMap = json['company'] as Map<String, dynamic>;
      final compModel = CompanyModel.fromJson(compMap);
      companyName = compModel.name.isNotEmpty ? compModel.name : 'Unknown Company';
      companyLogoUrl = compModel.logoUrl;
      companyEntity = compModel.toEntity();
    } else if (json['company_name'] is String) {
      companyName = json['company_name'] as String;
    }

    // Parse location (can be string or city/state/country)
    String location = 'Remote';
    if (json['location'] is String && (json['location'] as String).isNotEmpty) {
      location = json['location'] as String;
    } else {
      final locationParts = [
        json['city'],
        json['state'],
        json['country'],
      ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');
      if (locationParts.isNotEmpty) {
        location = locationParts;
      }
    }

    // Required and preferred skills parsing
    List<SkillModel>? reqSkillModels;
    if (json['required_skills'] is List) {
      reqSkillModels = (json['required_skills'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SkillModel.fromJson)
          .toList();
    }

    List<SkillModel>? prefSkillModels;
    if (json['preferred_skills'] is List) {
      prefSkillModels = (json['preferred_skills'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SkillModel.fromJson)
          .toList();
    }

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
    if (reqSkillModels != null) {
      for (final s in reqSkillModels) {
        if (!parsedSkills.contains(s.name)) {
          parsedSkills.add(s.name);
        }
      }
    }
    if (prefSkillModels != null) {
      for (final s in prefSkillModels) {
        if (!parsedSkills.contains(s.name)) {
          parsedSkills.add(s.name);
        }
      }
    }

    final postedDateStr = (json['published_at'] as String?) ??
        (json['posted_date'] as String?) ??
        (json['postedDate'] as String?) ??
        (json['created_at'] as String?) ??
        DateTime.now().toIso8601String();

    return SavedJobResponseModel(
      id: (json['id'] as num?)?.toInt() ??
          (json['job_id'] as num?)?.toInt() ??
          (json['job_post_id'] as num?)?.toInt() ??
          0,
      title: (json['title'] as String?) ?? 'Job Title',
      company: companyName,
      companyLogoUrl: companyLogoUrl,
      companyEntity: companyEntity,
      location: location,
      workMode: (json['work_mode'] as String?) ??
          (json['workMode'] as String?) ??
          'Hybrid',
      experience: (json['experience_level'] as String?) ??
          (json['experience'] as String?) ??
          '0-2 years',
      jobType: (json['employment_type'] as String?) ??
          (json['job_type'] as String?) ??
          (json['jobType'] as String?) ??
          'Full-time',
      postedDate: postedDateStr,
      skills: parsedSkills,
      requiredSkills: reqSkillModels?.map((s) => s.toEntity()).toList(),
      preferredSkills: prefSkillModels?.map((s) => s.toEntity()).toList(),
      isExpired: (json['is_expired'] as bool?) ?? false,
      matchPercentage: (json['match_percentage'] as num?)?.toInt() ??
          (json['matchPercentage'] as num?)?.toInt(),
      isSaved: (json['is_saved'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'company_logo_url': companyLogoUrl,
      'location': location,
      'work_mode': workMode,
      'experience': experience,
      'job_type': jobType,
      'posted_date': postedDate,
      'skills': skills,
      'match_percentage': matchPercentage,
      'is_saved': isSaved,
      'is_expired': isExpired,
    };
  }
}
