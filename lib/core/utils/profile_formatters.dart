import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';

abstract class ProfileFormatters {
  static String location(
    CandidateProfileDetailsEntity? profile,
  ) {
    if (profile == null) {
      return '';
    }

    return [profile.city, profile.country]
        .where(
          (value) =>
              value != null && value.trim().isNotEmpty,
        )
        .join(', ');
  }
}
