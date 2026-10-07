import 'package:MatchIn/features/jobsAndApplications/domain/entities/company_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/skill_entity.dart';
import 'package:equatable/equatable.dart';

class SavedJobEntity extends Equatable {
  const SavedJobEntity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.workMode,
    required this.experience,
    required this.jobType,
    required this.postedDate,
    required this.skills,
    this.companyLogoUrl,
    this.companyEntity,
    this.requiredSkills,
    this.preferredSkills,
    this.isExpired = false,
    this.matchPercentage,
    this.isSaved = true,
  });

  final int id;
  final String title;
  final String company;
  final String? companyLogoUrl;
  final CompanyEntity? companyEntity;
  final String location;
  final String workMode;
  final String experience;
  final String jobType;
  final String postedDate;
  final List<String> skills;
  final List<SkillEntity>? requiredSkills;
  final List<SkillEntity>? preferredSkills;
  final bool isExpired;
  final int? matchPercentage;
  final bool isSaved;

  SavedJobEntity copyWith({
    int? id,
    String? title,
    String? company,
    String? companyLogoUrl,
    CompanyEntity? companyEntity,
    String? location,
    String? workMode,
    String? experience,
    String? jobType,
    String? postedDate,
    List<String>? skills,
    List<SkillEntity>? requiredSkills,
    List<SkillEntity>? preferredSkills,
    bool? isExpired,
    int? matchPercentage,
    bool? isSaved,
  }) {
    return SavedJobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      companyEntity: companyEntity ?? this.companyEntity,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      experience: experience ?? this.experience,
      jobType: jobType ?? this.jobType,
      postedDate: postedDate ?? this.postedDate,
      skills: skills ?? this.skills,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      preferredSkills: preferredSkills ?? this.preferredSkills,
      isExpired: isExpired ?? this.isExpired,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  JobEntity toJobEntity() {
    return JobEntity(
      id: id.toString(),
      title: title,
      companyName: company,
      companyLogoUrl: companyLogoUrl,
      location: location,
      workMode: workMode,
      employmentType: jobType,
      experienceLevel: experience,
      postedDate: DateTime.tryParse(postedDate) ?? DateTime.now(),
      skills: skills,
      matchedSkills: const [],
      missingSkills: const [],
      matchPercentage: matchPercentage,
      isSaved: isSaved,
      company: companyEntity,
      requiredSkills: requiredSkills,
      preferredSkills: preferredSkills,
      isExpired: isExpired,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    company,
    companyLogoUrl,
    companyEntity,
    location,
    workMode,
    experience,
    jobType,
    postedDate,
    skills,
    requiredSkills,
    preferredSkills,
    isExpired,
    matchPercentage,
    isSaved,
  ];
}
