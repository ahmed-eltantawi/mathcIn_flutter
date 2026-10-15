import 'package:equatable/equatable.dart';

class SaveCareerPreferencesParams extends Equatable {
  const SaveCareerPreferencesParams({
    this.targetRole = _unset,
    this.jobType = _unset,
    this.workMode = _unset,
    this.preferredCountry = _unset,
    this.preferredCity = _unset,
    this.experienceLevel = _unset,
    this.careerGoal = _unset,
    this.openToRelocation = _unset,
    this.targetRoles = _unset,
    this.preferredIndustries = _unset,
  });

  /// Sentinel marking a field as omitted from PATCH.
  /// `_unset` means "unchanged, do not send".
  /// An explicit `null` means "clear this field".
  /// A value means "update to this value".
  ///
  /// `targetRoles` and `preferredIndustries` intentionally have no
  /// editor yet: they stay [_unset] (omitted) so existing backend
  /// values are never cleared by an unrelated save.
  final Object? targetRole;
  final Object? jobType;
  final Object? workMode;
  final Object? preferredCountry;
  final Object? preferredCity;
  final Object? experienceLevel;
  final Object? careerGoal;
  final Object? openToRelocation;
  final Object? targetRoles;
  final Object? preferredIndustries;

  static const Object _unset = Object();

  static const Object unset = _unset;

  static bool isSet(Object? value) => !identical(value, _unset);

  bool get hasChanges =>
      isSet(targetRole) ||
      isSet(jobType) ||
      isSet(workMode) ||
      isSet(preferredCountry) ||
      isSet(preferredCity) ||
      isSet(experienceLevel) ||
      isSet(careerGoal) ||
      isSet(openToRelocation) ||
      isSet(targetRoles) ||
      isSet(preferredIndustries);

  SaveCareerPreferencesParams copyWith({
    Object? targetRole = _unset,
    Object? jobType = _unset,
    Object? workMode = _unset,
    Object? preferredCountry = _unset,
    Object? preferredCity = _unset,
    Object? experienceLevel = _unset,
    Object? careerGoal = _unset,
    Object? openToRelocation = _unset,
    Object? targetRoles = _unset,
    Object? preferredIndustries = _unset,
  }) {
    return SaveCareerPreferencesParams(
      targetRole: identical(targetRole, _unset) ? this.targetRole : targetRole,
      jobType: identical(jobType, _unset) ? this.jobType : jobType,
      workMode: identical(workMode, _unset) ? this.workMode : workMode,
      preferredCountry: identical(preferredCountry, _unset)
          ? this.preferredCountry
          : preferredCountry,
      preferredCity: identical(preferredCity, _unset)
          ? this.preferredCity
          : preferredCity,
      experienceLevel: identical(experienceLevel, _unset)
          ? this.experienceLevel
          : experienceLevel,
      careerGoal: identical(careerGoal, _unset) ? this.careerGoal : careerGoal,
      openToRelocation: identical(openToRelocation, _unset)
          ? this.openToRelocation
          : openToRelocation,
      targetRoles: identical(targetRoles, _unset)
          ? this.targetRoles
          : targetRoles,
      preferredIndustries: identical(preferredIndustries, _unset)
          ? this.preferredIndustries
          : preferredIndustries,
    );
  }

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
