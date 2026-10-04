import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';

class CandidateProfileDetailsModel
    extends CandidateProfileDetailsEntity {
  const CandidateProfileDetailsModel({
    required super.id,
    super.dateOfBirth,
    super.gender,
    super.jobTitle,
    super.country,
    super.state,
    super.city,
    super.githubUrl,
    super.linkedinUrl,
    super.militaryStatus,
    super.professionalSummary,
  });

  factory CandidateProfileDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CandidateProfileDetailsModel(
      id: json['id'] as int,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      jobTitle: json['job_title'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      githubUrl: json['github_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      militaryStatus: json['military_status'] as String?,
      professionalSummary:
          json['professional_summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'job_title': jobTitle,
      'country': country,
      'state': state,
      'city': city,
      'github_url': githubUrl,
      'linkedin_url': linkedinUrl,
      'military_status': militaryStatus,
      'professional_summary': professionalSummary,
    };
  }
}
