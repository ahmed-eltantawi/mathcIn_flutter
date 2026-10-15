import 'package:equatable/equatable.dart';

class AddEducationParams extends Equatable {
  const AddEducationParams({
    required this.institution,
    this.degree,
    this.fieldOfStudy,
    this.educationLevel,
    this.grade,
    this.description,
    this.isCurrent = false,
    this.startDate,
    this.endDate,
  });

  final String institution;
  final String? degree;
  final String? fieldOfStudy;
  final String? educationLevel;
  final String? grade;
  final String? description;
  final bool isCurrent;
  final String? startDate;
  final String? endDate;

  @override
  List<Object?> get props => [
    institution,
    degree,
    fieldOfStudy,
    educationLevel,
    grade,
    description,
    isCurrent,
    startDate,
    endDate,
  ];
}
