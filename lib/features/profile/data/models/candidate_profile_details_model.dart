import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';

class CandidateProfileDetailsModel extends CandidateProfileDetailsEntity {
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

  factory CandidateProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    final id = JsonParsing.parseId(json['id']);
    if (id == null) {
      throw const FormatException('Invalid candidate profile: missing id');
    }
    return CandidateProfileDetailsModel(
      id: id,
      dateOfBirth: JsonParsing.parseString(json['date_of_birth']),
      gender: JsonParsing.parseString(json['gender']),
      jobTitle: JsonParsing.parseString(json['job_title']),
      country: JsonParsing.parseString(json['country']),
      state: JsonParsing.parseString(json['state']),
      city: JsonParsing.parseString(json['city']),
      githubUrl: JsonParsing.parseString(json['github_url']),
      linkedinUrl: JsonParsing.parseString(json['linkedin_url']),
      militaryStatus: JsonParsing.parseString(json['military_status']),
      professionalSummary: JsonParsing.parseString(
        json['professional_summary'],
      ),
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
