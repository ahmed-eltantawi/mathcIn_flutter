import 'package:equatable/equatable.dart';

class AddExperienceParams extends Equatable {
  const AddExperienceParams({
    required this.jobTitle,
    required this.companyName,
    this.employmentType,
    this.country,
    this.city,
    this.description,
    this.technologies = const [],
    this.isCurrent = false,
    this.startDate,
    this.endDate,
  });

  final String jobTitle;
  final String companyName;
  final String? employmentType;
  final String? country;
  final String? city;
  final String? description;
  final List<String> technologies;
  final bool isCurrent;
  final String? startDate;
  final String? endDate;

  @override
  List<Object?> get props => [
    jobTitle,
    companyName,
    employmentType,
    country,
    city,
    description,
    technologies,
    isCurrent,
    startDate,
    endDate,
  ];
}
