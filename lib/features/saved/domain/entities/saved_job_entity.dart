import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
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
    this.matchPercentage,
    this.isSaved = true,
  });

  final int id;
  final String title;
  final String company;
  final String location;
  final String workMode;
  final String experience;
  final String jobType;
  final String postedDate;
  final List<String> skills;
  final int? matchPercentage;
  final bool isSaved;

  SavedJobEntity copyWith({
    int? id,
    String? title,
    String? company,
    String? location,
    String? workMode,
    String? experience,
    String? jobType,
    String? postedDate,
    List<String>? skills,
    int? matchPercentage,
    bool? isSaved,
  }) {
    return SavedJobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      experience: experience ?? this.experience,
      jobType: jobType ?? this.jobType,
      postedDate: postedDate ?? this.postedDate,
      skills: skills ?? this.skills,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  JobEntity toJobEntity() {
    return JobEntity(
      id: id.toString(),
      title: title,
      companyName: company,
      location: location,
      workMode: workMode,
      employmentType: jobType,
      experienceLevel: experience,
      postedDate: DateTime.tryParse(postedDate) ?? DateTime.now(),
      skills: skills,
      matchPercentage: matchPercentage,
      isSaved: isSaved,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        company,
        location,
        workMode,
        experience,
        jobType,
        postedDate,
        skills,
        matchPercentage,
        isSaved,
      ];
}
