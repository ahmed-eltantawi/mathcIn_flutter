import 'package:equatable/equatable.dart';

class EducationEntity extends Equatable {
  const EducationEntity({
    required this.id,
    required this.degree,
    required this.institution,
    this.educationLevel,
    this.fieldOfStudy,
    this.isCurrent = false,
    this.description,
    this.source,
    this.startDate,
    this.endDate,
    this.grade,
  });

  final int id;
  final String degree;
  final String institution;
  final String? educationLevel;
  final String? fieldOfStudy;
  final bool isCurrent;
  final String? description;
  final String? source;
  final String? startDate;
  final String? endDate;
  final String? grade;

  @override
  List<Object?> get props => [
    id,
    degree,
    institution,
    educationLevel,
    fieldOfStudy,
    isCurrent,
    description,
    source,
    startDate,
    endDate,
    grade,
  ];
}
