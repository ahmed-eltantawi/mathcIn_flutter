import 'package:MatchIn/features/jobsAndApplications/domain/entities/company_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/skill_entity.dart';
import 'package:equatable/equatable.dart';

enum JobApplicationStatus {
  notApplied,
  pending,
  reviewed,
  shortlisted,
  accepted,
  rejected,
}

class JobEntity extends Equatable {
  const JobEntity({
    required this.id,
    required this.title,
    required this.companyName,
    this.companyLogoUrl,
    required this.location,
    required this.workMode,
    required this.employmentType,
    required this.experienceLevel,
    this.salaryMin,
    this.salaryMax,
    this.currency,
    required this.postedDate,
    required this.skills,
    required this.matchedSkills,
    required this.missingSkills,
    this.matchPercentage,
    this.isSaved = false,
    this.applicationStatus = JobApplicationStatus.notApplied,
    this.company,
    this.requiredSkills,
    this.preferredSkills,
    this.isExpired = false,
  });

  final String id;
  final String title;
  final String companyName;
  final String? companyLogoUrl;

  final String location;
  final String workMode;
  final String employmentType;
  final String experienceLevel;

  final double? salaryMin;
  final double? salaryMax;
  final String? currency;

  final DateTime postedDate;

  /// All skills required by the job.
  final List<String> skills;

  /// Job skills that the current candidate already has.
  final List<String> matchedSkills;

  /// Job skills that the current candidate is missing.
  final List<String> missingSkills;

  /// Calculated by the backend per candidate.
  final int? matchPercentage;

  /// Calculated based on the current candidate's saved jobs.
  final bool isSaved;

  final JobApplicationStatus applicationStatus;

  final CompanyEntity? company;
  final List<SkillEntity>? requiredSkills;
  final List<SkillEntity>? preferredSkills;
  final bool isExpired;

  JobEntity copyWith({
    String? id,
    String? title,
    String? companyName,
    String? companyLogoUrl,
    String? location,
    String? workMode,
    String? employmentType,
    String? experienceLevel,
    double? salaryMin,
    double? salaryMax,
    String? currency,
    DateTime? postedDate,
    List<String>? skills,
    List<String>? matchedSkills,
    List<String>? missingSkills,
    int? matchPercentage,
    bool? isSaved,
    JobApplicationStatus? applicationStatus,
    CompanyEntity? company,
    List<SkillEntity>? requiredSkills,
    List<SkillEntity>? preferredSkills,
    bool? isExpired,
  }) {
    return JobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      employmentType: employmentType ?? this.employmentType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      currency: currency ?? this.currency,
      postedDate: postedDate ?? this.postedDate,
      skills: skills ?? this.skills,
      matchedSkills: matchedSkills ?? this.matchedSkills,
      missingSkills: missingSkills ?? this.missingSkills,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      isSaved: isSaved ?? this.isSaved,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      company: company ?? this.company,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      preferredSkills: preferredSkills ?? this.preferredSkills,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    companyName,
    companyLogoUrl,
    location,
    workMode,
    employmentType,
    experienceLevel,
    salaryMin,
    salaryMax,
    currency,
    postedDate,
    skills,
    matchedSkills,
    missingSkills,
    matchPercentage,
    isSaved,
    applicationStatus,
    company,
    requiredSkills,
    preferredSkills,
    isExpired,
  ];
}
