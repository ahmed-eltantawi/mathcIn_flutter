import 'package:MatchIn/features/profile/data/models/candidate_profile_details_model.dart';
import 'package:MatchIn/features/profile/data/models/profile_user_model.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';

class CandidateProfileModel extends CandidateProfileEntity {
  const CandidateProfileModel({
    required super.profileExists,
    required ProfileUserModel super.user,
    CandidateProfileDetailsModel? super.profile,
  });

  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final profileJson = json['profile'] as Map<String, dynamic>?;

    return CandidateProfileModel(
      profileExists: json['profile_exists'] as bool,
      user: ProfileUserModel.fromJson(userJson),
      profile: profileJson == null
          ? null
          : CandidateProfileDetailsModel.fromJson(profileJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_exists': profileExists,
      'user': ProfileUserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
        phone: user.phone,
        avatar: user.avatar,
      ).toJson(),
      'profile': profile == null
          ? null
          : CandidateProfileDetailsModel(
              id: profile!.id,
              dateOfBirth: profile!.dateOfBirth,
              gender: profile!.gender,
              jobTitle: profile!.jobTitle,
              country: profile!.country,
              state: profile!.state,
              city: profile!.city,
              githubUrl: profile!.githubUrl,
              linkedinUrl: profile!.linkedinUrl,
              militaryStatus: profile!.militaryStatus,
              professionalSummary: profile!.professionalSummary,
            ).toJson(),
    };
  }
}
