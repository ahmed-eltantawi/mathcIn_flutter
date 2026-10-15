import 'package:equatable/equatable.dart';

class ExperienceEntity extends Equatable {
  const ExperienceEntity({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    this.employmentType,
    this.country,
    this.city,
    this.description,
    this.technologies = const [],
    this.startDate,
    this.endDate,
    this.isCurrent = false,
  });

  final int id;
  final String jobTitle;
  final String companyName;
  final String? employmentType;
  final String? country;
  final String? city;
  final String? description;
  final List<String> technologies;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;

  @override
  List<Object?> get props => [
    id,
    jobTitle,
    companyName,
    employmentType,
    country,
    city,
    description,
    technologies,
    startDate,
    endDate,
    isCurrent,
  ];
}
