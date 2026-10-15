import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_document_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';
import 'package:equatable/equatable.dart';

class CandidateProfileEntity extends Equatable {
  const CandidateProfileEntity({
    required this.profileExists,
    required this.user,
    this.profile,
    this.skills = const [],
    this.projects = const [],
    this.careerPreferences,
    this.education = const [],
    this.experience = const [],
    this.cvDocument,
  });

  final bool profileExists;
  final ProfileUserEntity user;
  final CandidateProfileDetailsEntity? profile;
  final List<CandidateSkillEntity> skills;
  final List<CandidateProjectEntity> projects;
  final CareerPreferenceEntity? careerPreferences;
  final List<EducationEntity> education;
  final List<ExperienceEntity> experience;
  final CvDocumentEntity? cvDocument;

  @override
  List<Object?> get props => [
    profileExists,
    user,
    profile,
    skills,
    projects,
    careerPreferences,
    education,
    experience,
    cvDocument,
  ];
}
