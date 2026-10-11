import 'package:equatable/equatable.dart';

class CareerPreferenceEntity extends Equatable {
  const CareerPreferenceEntity({
    required this.id,
    this.targetRole,
    this.jobType,
    this.workMode,
    this.preferredCountry,
    this.preferredCity,
    this.experienceLevel,
    this.careerGoal,
    this.openToRelocation,
    this.targetRoles = const [],
    this.preferredIndustries = const [],
  });

  final int id;

  final String? targetRole;
  final String? jobType;
  final String? workMode;

  final String? preferredCountry;
  final String? preferredCity;

  final String? experienceLevel;
  final String? careerGoal;

  final bool? openToRelocation;

  final List<String> targetRoles;
  final List<String> preferredIndustries;

  @override
  List<Object?> get props => [
    id,
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
