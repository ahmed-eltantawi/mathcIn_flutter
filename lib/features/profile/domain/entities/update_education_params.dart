import 'package:equatable/equatable.dart';

class UpdateEducationParams extends Equatable {
  const UpdateEducationParams({
    required this.educationId,
    this.institution = _unset,
    this.degree = _unset,
    this.fieldOfStudy = _unset,
    this.educationLevel = _unset,
    this.grade = _unset,
    this.description = _unset,
    this.isCurrent = _unset,
    this.startDate = _unset,
    this.endDate = _unset,
  });

  /// Sentinel marking a field as omitted from PATCH.
  /// `_unset` means "unchanged, do not send".
  /// An explicit `null` means "clear this field".
  /// A value means "update to this value".
  final int educationId;
  final Object? institution;
  final Object? degree;
  final Object? fieldOfStudy;
  final Object? educationLevel;
  final Object? grade;
  final Object? description;
  final Object? isCurrent;
  final Object? startDate;
  final Object? endDate;

  static const Object _unset = Object();

  static const Object unset = _unset;

  static bool isSet(Object? value) => !identical(value, _unset);

  bool get hasChanges =>
      isSet(institution) ||
      isSet(degree) ||
      isSet(fieldOfStudy) ||
      isSet(educationLevel) ||
      isSet(grade) ||
      isSet(description) ||
      isSet(isCurrent) ||
      isSet(startDate) ||
      isSet(endDate);

  UpdateEducationParams copyWith({
    required int educationId,
    Object? institution = _unset,
    Object? degree = _unset,
    Object? fieldOfStudy = _unset,
    Object? educationLevel = _unset,
    Object? grade = _unset,
    Object? description = _unset,
    Object? isCurrent = _unset,
    Object? startDate = _unset,
    Object? endDate = _unset,
  }) {
    return UpdateEducationParams(
      educationId: educationId,
      institution: identical(institution, _unset)
          ? this.institution
          : institution,
      degree: identical(degree, _unset) ? this.degree : degree,
      fieldOfStudy: identical(fieldOfStudy, _unset)
          ? this.fieldOfStudy
          : fieldOfStudy,
      educationLevel: identical(educationLevel, _unset)
          ? this.educationLevel
          : educationLevel,
      grade: identical(grade, _unset) ? this.grade : grade,
      description: identical(description, _unset)
          ? this.description
          : description,
      isCurrent: identical(isCurrent, _unset) ? this.isCurrent : isCurrent,
      startDate: identical(startDate, _unset) ? this.startDate : startDate,
      endDate: identical(endDate, _unset) ? this.endDate : endDate,
    );
  }

  @override
  List<Object?> get props => [
    educationId,
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
