import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';

class CandidateProfileDetailsModel extends CandidateProfileDetailsEntity {
  const CandidateProfileDetailsModel({
    required super.id,
    super.dateOfBirth,
    super.gender,
    super.jobTitle,
    super.location,
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
    final location = json['location'];
    final locationMap = location is Map ? location : null;
    final locationString = location is String ? location : null;
    final locationFromMap = locationMap == null
        ? ''
        : [locationMap['city'], locationMap['state'] ?? locationMap['region'], locationMap['country']]
              .whereType<String>()
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty)
              .join(', ');
    return CandidateProfileDetailsModel(
      id: id,
      dateOfBirth: JsonParsing.parseString(json['date_of_birth']),
      gender: JsonParsing.parseString(json['gender']),
      // The profile API uses `headline`, `summary`, and `location` in
      // some responses while other endpoints return the database names.
      jobTitle: JsonParsing.parseString(json['job_title'] ?? json['headline']),
      location: JsonParsing.parseString(locationString) ??
          (locationFromMap.isEmpty ? null : locationFromMap),
      country: JsonParsing.parseString(
        json['country'] ?? locationMap?['country'],
      ),
      state: JsonParsing.parseString(
        json['state'] ?? locationMap?['state'] ?? locationMap?['region'],
      ),
      city: _firstNonEmptyString([
        json['city'],
        locationMap?['city'],
      ]),
      githubUrl: JsonParsing.parseString(json['github_url']),
      linkedinUrl: JsonParsing.parseString(json['linkedin_url']),
      militaryStatus: JsonParsing.parseString(json['military_status']),
      professionalSummary: JsonParsing.parseString(
        json['professional_summary'] ?? json['summary'],
      ),
    );
  }

  static String? _firstNonEmptyString(Iterable<dynamic> values) {
    for (final value in values) {
      final parsed = JsonParsing.parseString(value)?.trim();
      if (parsed != null && parsed.isNotEmpty) return parsed;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'job_title': jobTitle,
      'location': location,
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
