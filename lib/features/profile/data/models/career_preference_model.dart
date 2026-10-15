import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';

class CareerPreferenceModel extends CareerPreferenceEntity {
  const CareerPreferenceModel({
    required super.id,
    super.targetRole,
    super.jobType,
    super.workMode,
    super.preferredCountry,
    super.preferredCity,
    super.experienceLevel,
    super.careerGoal,
    super.openToRelocation,
    super.targetRoles,
    super.preferredIndustries,
  });

  factory CareerPreferenceModel.fromJson(Map<String, dynamic> json) {
    return CareerPreferenceModel(
      id: JsonParsing.parseId(json['id']) ?? 0,
      targetRole: JsonParsing.parseString(json['target_role']),
      jobType: JsonParsing.parseString(json['job_type']),
      workMode: JsonParsing.parseString(json['work_mode']),
      preferredCountry: JsonParsing.parseString(json['preferred_country']),
      preferredCity: JsonParsing.parseString(json['preferred_city']),
      experienceLevel: JsonParsing.parseString(json['experience_level']),
      careerGoal: JsonParsing.parseString(json['career_goal']),
      openToRelocation: JsonParsing.parseBoolFlag(json['open_to_relocation']),
      targetRoles: JsonParsing.parseStringList(json['target_roles']),
      preferredIndustries: JsonParsing.parseStringList(
        json['preferred_industries'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_role': targetRole,
      'job_type': jobType,
      'work_mode': workMode,
      'preferred_country': preferredCountry,
      'preferred_city': preferredCity,
      'experience_level': experienceLevel,
      'career_goal': careerGoal,
      'open_to_relocation': openToRelocation,
      'target_roles': targetRoles,
      'preferred_industries': preferredIndustries,
    };
  }
}
