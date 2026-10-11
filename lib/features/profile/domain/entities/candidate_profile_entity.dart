import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';
import 'package:equatable/equatable.dart';

class CandidateProfileEntity extends Equatable {
  const CandidateProfileEntity({
    required this.profileExists,
    required this.user,
    this.profile,
  });

  final bool profileExists;
  final ProfileUserEntity user;
  final CandidateProfileDetailsEntity? profile;

  @override
  List<Object?> get props => [profileExists, user, profile];
}
