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
    this.matchPercentage,
    this.isSaved = false,
    this.applicationStatus =
        JobApplicationStatus.notApplied,
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
  final List<String> skills;

  /// جاي محسوب من السيرفر (per-candidate)، مش عمود ثابت في job_posts
  final int? matchPercentage;

  /// جاي محسوب من السيرفر بمقارنة saved_jobs
  final bool isSaved;

  final JobApplicationStatus applicationStatus;

  JobEntity copyWith({
    bool? isSaved,
    JobApplicationStatus? applicationStatus,
  }) {
    return JobEntity(
      id: id,
      title: title,
      companyName: companyName,
      companyLogoUrl: companyLogoUrl,
      location: location,
      workMode: workMode,
      employmentType: employmentType,
      experienceLevel: experienceLevel,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      currency: currency,
      postedDate: postedDate,
      skills: skills,
      matchPercentage: matchPercentage,
      isSaved: isSaved ?? this.isSaved,
      applicationStatus:
          applicationStatus ?? this.applicationStatus,
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
    matchPercentage,
    isSaved,
    applicationStatus,
  ];
}
