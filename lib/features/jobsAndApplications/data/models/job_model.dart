import 'package:MatchIn/features/jobsAndApplications/data/models/company_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/skill_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';

///! Constants for JSON keys used in JobModel
abstract class JobModelKey {
  static const String id = 'id';
  static const String title = 'title';
  static const String jobType = 'job_type';
  static const String workMode = 'work_mode';
  static const String employmentType = 'employment_type';
  static const String experienceLevel = 'experience_level';
  static const String country = 'country';
  static const String state = 'state';
  static const String city = 'city';
  static const String minYearsExperience = 'min_years_experience';
  static const String maxYearsExperience = 'max_years_experience';
  static const String source = 'source';
  static const String applicationMethod = 'application_method';
  static const String publishedAt = 'published_at';
  static const String expiresAt = 'expires_at';
  static const String isActive = 'is_active';
  static const String company = 'company';
  static const String requiredSkills = 'required_skills';
  static const String preferredSkills = 'preferred_skills';
  static const String isExpired = 'is_expired';
  static const String isSaved = 'is_saved';
  static const String salaryMin = 'salary_min';
  static const String salaryMax = 'salary_max';
  static const String salaryCurrency = 'salary_currency';
  static const String match = 'match';
  static const String matchScore = 'match_score';
  static const String matchPercentage = 'match_percentage';
}

class JobModel {
  const JobModel({
    required this.id,
    required this.title,
    this.jobType,
    this.workMode,
    this.employmentType,
    this.experienceLevel,
    this.country,
    this.state,
    this.city,
    this.minYearsExperience,
    this.maxYearsExperience,
    this.source,
    this.applicationMethod,
    this.publishedAt,
    this.expiresAt,
    this.isActive = true,
    this.company,
    this.requiredSkills,
    this.preferredSkills,
    this.isExpired = false,
    this.isSaved = false,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
    this.matchScore,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic value) {
      if (value is num) return value;
      return num.tryParse(value?.toString() ?? '');
    }

    // Recommended-jobs nests the score in `match: {match_score}`.
    final matchObj = json[JobModelKey.match];
    final nestedScore = matchObj is Map<String, dynamic>
        ? asNum(matchObj[JobModelKey.matchScore])
        : null;

    return JobModel(
      id: json[JobModelKey.id] is int
          ? json[JobModelKey.id] as int
          : int.tryParse(json[JobModelKey.id]?.toString() ?? '0') ?? 0,
      title: json[JobModelKey.title] as String? ?? '',
      jobType: json[JobModelKey.jobType] as String?,
      workMode: json[JobModelKey.workMode] as String?,
      employmentType: json[JobModelKey.employmentType] as String?,
      experienceLevel: json[JobModelKey.experienceLevel] as String?,
      country: json[JobModelKey.country] as String?,
      state: json[JobModelKey.state] as String?,
      city: json[JobModelKey.city] as String?,
      minYearsExperience: json[JobModelKey.minYearsExperience] is int
          ? json[JobModelKey.minYearsExperience] as int
          : int.tryParse(json[JobModelKey.minYearsExperience]?.toString() ?? ''),
      maxYearsExperience: json[JobModelKey.maxYearsExperience] is int
          ? json[JobModelKey.maxYearsExperience] as int
          : int.tryParse(json[JobModelKey.maxYearsExperience]?.toString() ?? ''),
      source: json[JobModelKey.source] as String?,
      applicationMethod: json[JobModelKey.applicationMethod] as String?,
      publishedAt: json[JobModelKey.publishedAt] as String?,
      expiresAt: json[JobModelKey.expiresAt] as String?,
      isActive: json[JobModelKey.isActive] as bool? ?? true,
      company: json[JobModelKey.company] is Map<String, dynamic>
          ? CompanyModel.fromJson(json[JobModelKey.company] as Map<String, dynamic>)
          : null,
      requiredSkills: json[JobModelKey.requiredSkills] is List
          ? (json[JobModelKey.requiredSkills] as List)
              .whereType<Map<String, dynamic>>()
              .map(SkillModel.fromJson)
              .toList()
          : null,
      preferredSkills: json[JobModelKey.preferredSkills] is List
          ? (json[JobModelKey.preferredSkills] as List)
              .whereType<Map<String, dynamic>>()
              .map(SkillModel.fromJson)
              .toList()
          : null,
      isExpired: json[JobModelKey.isExpired] as bool? ?? false,
      isSaved: json[JobModelKey.isSaved] as bool? ?? false,
      salaryMin: asNum(json[JobModelKey.salaryMin])?.toDouble(),
      salaryMax: asNum(json[JobModelKey.salaryMax])?.toDouble(),
      salaryCurrency: json[JobModelKey.salaryCurrency] as String?,
      matchScore:
          nestedScore?.toDouble() ??
          asNum(json[JobModelKey.matchScore])?.toDouble() ??
          asNum(json[JobModelKey.matchPercentage])?.toDouble(),
    );
  }

  final int id;
  final String title;
  final String? jobType;
  final String? workMode;
  final String? employmentType;
  final String? experienceLevel;
  final String? country;
  final String? state;
  final String? city;
  final int? minYearsExperience;
  final int? maxYearsExperience;
  final String? source;
  final String? applicationMethod;
  final String? publishedAt;
  final String? expiresAt;
  final bool isActive;
  final CompanyModel? company;
  final List<SkillModel>? requiredSkills;
  final List<SkillModel>? preferredSkills;
  final bool isExpired;
  final bool isSaved;
  final double? salaryMin;
  final double? salaryMax;
  final String? salaryCurrency;
  final double? matchScore;

  Map<String, dynamic> toJson() {
    return {
      JobModelKey.id: id,
      JobModelKey.title: title,
      JobModelKey.jobType: jobType,
      JobModelKey.workMode: workMode,
      JobModelKey.employmentType: employmentType,
      JobModelKey.experienceLevel: experienceLevel,
      JobModelKey.country: country,
      JobModelKey.state: state,
      JobModelKey.city: city,
      JobModelKey.minYearsExperience: minYearsExperience,
      JobModelKey.maxYearsExperience: maxYearsExperience,
      JobModelKey.source: source,
      JobModelKey.applicationMethod: applicationMethod,
      JobModelKey.publishedAt: publishedAt,
      JobModelKey.expiresAt: expiresAt,
      JobModelKey.isActive: isActive,
      JobModelKey.company: company?.toJson(),
      JobModelKey.requiredSkills: requiredSkills?.map((s) => s.toJson()).toList(),
      JobModelKey.preferredSkills: preferredSkills?.map((s) => s.toJson()).toList(),
      JobModelKey.isExpired: isExpired,
      JobModelKey.isSaved: isSaved,
      JobModelKey.salaryMin: salaryMin,
      JobModelKey.salaryMax: salaryMax,
      JobModelKey.salaryCurrency: salaryCurrency,
      JobModelKey.matchScore: matchScore,
    };
  }

  JobEntity toEntity() {
    final locationParts = [city, state, country]
        .where((element) => element != null && element.trim().isNotEmpty)
        .join(', ');

    DateTime parsedPostedDate;
    if (publishedAt != null && publishedAt!.isNotEmpty) {
      parsedPostedDate = DateTime.tryParse(publishedAt!) ?? DateTime.now();
    } else {
      parsedPostedDate = DateTime.now();
    }

    final reqSkillEntities = requiredSkills?.map((s) => s.toEntity()).toList();
    final prefSkillEntities = preferredSkills?.map((s) => s.toEntity()).toList();

    final skillNames = <String>[
      if (reqSkillEntities != null) ...reqSkillEntities.map((s) => s.name),
      if (prefSkillEntities != null) ...prefSkillEntities.map((s) => s.name),
    ];

    return JobEntity(
      id: id.toString(),
      title: title,
      companyName: company?.name ?? '',
      companyLogoUrl: company?.logoUrl,
      location: locationParts.isNotEmpty ? locationParts : 'Remote',
      workMode: workMode ?? 'Remote',
      employmentType: employmentType ?? 'Full-time',
      experienceLevel: experienceLevel ?? 'Entry Level',
      postedDate: parsedPostedDate,
      skills: skillNames,
      matchedSkills: const [],
      missingSkills: const [],
      isSaved: isSaved,
      matchPercentage: matchScore?.round(),
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      currency: salaryCurrency,
      company: company?.toEntity(),
      requiredSkills: reqSkillEntities,
      preferredSkills: prefSkillEntities,
      isExpired: isExpired,
      applicationMethod: applicationMethod,
      websiteUrl: company?.website,
    );
  }
}