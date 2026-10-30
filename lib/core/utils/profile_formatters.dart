import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';

abstract class ProfileFormatters {
  static String location(
    CandidateProfileDetailsEntity? profile,
  ) {
    if (profile == null) {
      return '';
    }
    final location = profile.location?.trim();
    if (location != null && location.isNotEmpty) return location;

    final parts = <String>[];
    for (final value in [profile.city, profile.state, profile.country]) {
      final normalized = value?.trim();
      if (normalized != null &&
          normalized.isNotEmpty &&
          !parts.any(
            (part) => part.toLowerCase() == normalized.toLowerCase(),
          )) {
        parts.add(normalized);
      }
    }
    return parts.join(', ');
  }
}
