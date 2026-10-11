import 'package:equatable/equatable.dart';

class SaveCareerPreferencesParams extends Equatable {
  const SaveCareerPreferencesParams({
    this.targetRole,
    this.jobType,
    this.workMode,
    this.preferredCountry,
    this.preferredCity,
    this.experienceLevel,
    this.careerGoal,
    this.openToRelocation,
    this.targetRoles,
    this.preferredIndustries,
  });

  final String? targetRole;
  final String? jobType;
  final String? workMode;

  final String? preferredCountry;
  final String? preferredCity;

  final String? experienceLevel;
  final String? careerGoal;

  final bool? openToRelocation;

  final List<String>? targetRoles;
  final List<String>? preferredIndustries;

  @override
  List<Object?> get props => [
    targetRole,
    jobType,
    workMode,
    preferredCountry,
    preferredCity,
    experienceLevel,
    careerGoal,
    openToRelocation,
    targetRoles,
    preferredIndustries,
  ];
}
