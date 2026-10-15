import 'package:equatable/equatable.dart';

class UpdateCandidateProfileParams extends Equatable {
  const UpdateCandidateProfileParams({
    this.dateOfBirth = _unset,
    this.gender = _unset,
    this.jobTitle = _unset,
    this.country = _unset,
    this.state = _unset,
    this.city = _unset,
    this.githubUrl = _unset,
    this.linkedinUrl = _unset,
    this.militaryStatus = _unset,
    this.professionalSummary = _unset,
  });

  /// Sentinel marking a field as omitted from PATCH.
  /// `_unset` means "unchanged, do not send".
  /// An explicit `null` means "clear this field".
  /// A [String] value means "update to this value".
  final Object? dateOfBirth;
  final Object? gender;
  final Object? jobTitle;
  final Object? country;
  final Object? state;
  final Object? city;
  final Object? githubUrl;
  final Object? linkedinUrl;
  final Object? militaryStatus;
  final Object? professionalSummary;

  static const Object _unset = Object();

  static const Object unset = _unset;

  static bool isSet(Object? value) => !identical(value, _unset);

  bool get hasChanges =>
      isSet(dateOfBirth) ||
      isSet(gender) ||
      isSet(jobTitle) ||
      isSet(country) ||
      isSet(state) ||
      isSet(city) ||
      isSet(githubUrl) ||
      isSet(linkedinUrl) ||
      isSet(militaryStatus) ||
      isSet(professionalSummary);

  UpdateCandidateProfileParams copyWith({
    Object? dateOfBirth = _unset,
    Object? gender = _unset,
    Object? jobTitle = _unset,
    Object? country = _unset,
    Object? state = _unset,
    Object? city = _unset,
    Object? githubUrl = _unset,
    Object? linkedinUrl = _unset,
    Object? militaryStatus = _unset,
    Object? professionalSummary = _unset,
  }) {
    return UpdateCandidateProfileParams(
      dateOfBirth: identical(dateOfBirth, _unset)
          ? this.dateOfBirth
          : dateOfBirth,
      gender: identical(gender, _unset) ? this.gender : gender,
      jobTitle: identical(jobTitle, _unset) ? this.jobTitle : jobTitle,
      country: identical(country, _unset) ? this.country : country,
      state: identical(state, _unset) ? this.state : state,
      city: identical(city, _unset) ? this.city : city,
      githubUrl: identical(githubUrl, _unset) ? this.githubUrl : githubUrl,
      linkedinUrl: identical(linkedinUrl, _unset)
          ? this.linkedinUrl
          : linkedinUrl,
      militaryStatus: identical(militaryStatus, _unset)
          ? this.militaryStatus
          : militaryStatus,
      professionalSummary: identical(professionalSummary, _unset)
          ? this.professionalSummary
          : professionalSummary,
    );
  }

  @override
  List<Object?> get props => [
    dateOfBirth,
    gender,
    jobTitle,
    country,
    state,
    city,
    githubUrl,
    linkedinUrl,
    militaryStatus,
    professionalSummary,
  ];
}
