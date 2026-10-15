import 'package:equatable/equatable.dart';

class UpdateExperienceParams extends Equatable {
  const UpdateExperienceParams({
    required this.experienceId,
    this.jobTitle = _unset,
    this.companyName = _unset,
    this.employmentType = _unset,
    this.country = _unset,
    this.city = _unset,
    this.description = _unset,
    this.technologies = _unset,
    this.isCurrent = _unset,
    this.startDate = _unset,
    this.endDate = _unset,
  });

  /// Sentinel marking a field as omitted from PATCH.
  /// `_unset` means "unchanged, do not send".
  /// An explicit `null` means "clear this field".
  /// A value means "update to this value".
  final int experienceId;
  final Object? jobTitle;
  final Object? companyName;
  final Object? employmentType;
  final Object? country;
  final Object? city;
  final Object? description;
  final Object? technologies;
  final Object? isCurrent;
  final Object? startDate;
  final Object? endDate;

  static const Object _unset = Object();

  static const Object unset = _unset;

  static bool isSet(Object? value) => !identical(value, _unset);

  bool get hasChanges =>
      isSet(jobTitle) ||
      isSet(companyName) ||
      isSet(employmentType) ||
      isSet(country) ||
      isSet(city) ||
      isSet(description) ||
      isSet(technologies) ||
      isSet(isCurrent) ||
      isSet(startDate) ||
      isSet(endDate);

  UpdateExperienceParams copyWith({
    required int experienceId,
    Object? jobTitle = _unset,
    Object? companyName = _unset,
    Object? employmentType = _unset,
    Object? country = _unset,
    Object? city = _unset,
    Object? description = _unset,
    Object? technologies = _unset,
    Object? isCurrent = _unset,
    Object? startDate = _unset,
    Object? endDate = _unset,
  }) {
    return UpdateExperienceParams(
      experienceId: experienceId,
      jobTitle: identical(jobTitle, _unset) ? this.jobTitle : jobTitle,
      companyName: identical(companyName, _unset)
          ? this.companyName
          : companyName,
      employmentType: identical(employmentType, _unset)
          ? this.employmentType
          : employmentType,
      country: identical(country, _unset) ? this.country : country,
      city: identical(city, _unset) ? this.city : city,
      description: identical(description, _unset)
          ? this.description
          : description,
      technologies: identical(technologies, _unset)
          ? this.technologies
          : technologies,
      isCurrent: identical(isCurrent, _unset) ? this.isCurrent : isCurrent,
      startDate: identical(startDate, _unset) ? this.startDate : startDate,
      endDate: identical(endDate, _unset) ? this.endDate : endDate,
    );
  }

  @override
  List<Object?> get props => [
    experienceId,
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
