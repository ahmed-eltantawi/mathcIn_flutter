import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';

class EditProfilePatchMapper {
  const EditProfilePatchMapper._();

  /// Builds PATCH params by diffing current form values against [baseline].
  ///
  /// Unchanged fields stay [_unset] (omitted from PATCH).
  /// Changed text emptied by the user becomes `null` (explicit clear).
  /// `professionalSummary` is never included: the Edit Profile form
  /// has no editor for it.
  /// User fields name and phone are included because the profile PATCH
  /// contract accepts `full_name` and `phone`; avatar uses its own endpoint.
  static UpdateCandidateProfileParams fromDiff({
    required CandidateProfileEntity baseline,
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String? gender,
    required String jobTitle,
    required String? country,
    required String? state,
    required String? city,
    String? location,
    required String githubUrl,
    required String linkedinUrl,
    required String? militaryStatus,
  }) {
    final details = baseline.profile;

    var params = const UpdateCandidateProfileParams();

    final normalizedFullName = _normalizedOrNull(fullName);
    if (normalizedFullName != _normalizedOrNull(baseline.user.name)) {
      params = params.copyWith(fullName: normalizedFullName ?? '');
    }

    final normalizedPhone = _normalizedOrNull(phone);
    if (normalizedPhone != _normalizedOrNull(baseline.user.phone)) {
      params = params.copyWith(phone: normalizedPhone ?? '');
    }

    final normalizedDateOfBirth = _normalizedOrNull(dateOfBirth);
    if (normalizedDateOfBirth != _normalizedOrNull(details?.dateOfBirth)) {
      params = params.copyWith(dateOfBirth: normalizedDateOfBirth);
    }

    if (gender != details?.gender) {
      params = params.copyWith(gender: gender);
    }

    final normalizedJobTitle = _normalizedOrNull(jobTitle);
    if (normalizedJobTitle != _normalizedOrNull(details?.jobTitle)) {
      params = params.copyWith(jobTitle: normalizedJobTitle);
    }

    if (location == null && country != details?.country) {
      params = params.copyWith(country: country);
    }

    if (location == null && state != details?.state) {
      params = params.copyWith(state: state);
    }

    if (location == null && city != details?.city) {
      params = params.copyWith(city: city);
    }

    final normalizedLocation = location == null
        ? _normalizedLocation(city, state, country)
        : _normalizedOrNull(location);
    final baselineLocation = _normalizedOrNull(details?.location) ??
        _normalizedLocation(details?.city, details?.state, details?.country);
    if (normalizedLocation != baselineLocation) {
      params = params.copyWith(location: normalizedLocation ?? '');
    }

    final normalizedGithub = _normalizedOrNull(githubUrl);
    if (normalizedGithub != _normalizedOrNull(details?.githubUrl)) {
      params = params.copyWith(githubUrl: normalizedGithub);
    }

    final normalizedLinkedin = _normalizedOrNull(linkedinUrl);
    if (normalizedLinkedin != _normalizedOrNull(details?.linkedinUrl)) {
      params = params.copyWith(linkedinUrl: normalizedLinkedin);
    }

    if (militaryStatus != details?.militaryStatus) {
      params = params.copyWith(militaryStatus: militaryStatus);
    }

    return params;
  }

  static String? _normalizedOrNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _normalizedLocation(
    String? city,
    String? state,
    String? country,
  ) {
    final parts = <String>[];
    for (final value in [city, state, country]) {
      final normalized = _normalizedOrNull(value);
      if (normalized != null &&
          !parts.any((part) => part.toLowerCase() == normalized.toLowerCase())) {
        parts.add(normalized);
      }
    }
    return parts.isEmpty ? null : parts.join(', ');
  }
}
