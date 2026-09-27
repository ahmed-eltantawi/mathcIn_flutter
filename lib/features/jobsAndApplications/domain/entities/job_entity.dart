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

  /// All skills required by the job.
  final List<String> skills;

  /// Job skills that the current candidate already has.
  ///
  /// Candidate-specific and should be calculated by the backend.
  final List<String> matchedSkills;

  /// Job skills that the current candidate is missing.
  ///
  /// Candidate-specific and should be calculated by the backend.
  final List<String> missingSkills;

  /// Calculated by the backend per candidate.
  final int? matchPercentage;

  /// Calculated based on the current candidate's saved jobs.
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
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      matchPercentage: matchPercentage,
      isSaved: isSaved ?? this.isSaved,
      applicationStatus:
          applicationStatus ?? this.applicationStatus,
    );
  }

  @override
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
  ];
}
