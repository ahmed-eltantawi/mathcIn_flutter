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
    final titles = JsonParsing.parseStringList(json['preferred_titles']);
    final employmentTypes = JsonParsing.parseStringList(
      json['employment_types'],
    );
    final locations = JsonParsing.parseStringList(json['preferred_locations']);
    final locationParts = locations.isEmpty
        ? const <String>[]
        : locations.first.split(',').map((part) => part.trim()).toList();
    final isOpenToRemote = JsonParsing.parseBoolFlag(json['is_open_to_remote']);
    return CareerPreferenceModel(
      id: JsonParsing.parseId(json['id']) ?? 0,
      targetRole: titles.isNotEmpty
          ? titles.first
          : JsonParsing.parseString(json['target_role']),
      jobType: employmentTypes.isNotEmpty
          ? employmentTypes.first
          : JsonParsing.parseString(json['job_type']),
      workMode: isOpenToRemote == null
          ? JsonParsing.parseString(json['work_mode'])
          : (isOpenToRemote ? 'remote' : 'on_site'),
      preferredCountry: locationParts.length > 1
          ? locationParts[1]
          : JsonParsing.parseString(json['preferred_country']),
      preferredCity: locationParts.isNotEmpty
          ? locationParts.first
          : JsonParsing.parseString(json['preferred_city']),
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
      'preferred_titles': targetRole == null
          ? <String>[]
          : <String>[targetRole!],
      'employment_types': jobType == null ? <String>[] : <String>[jobType!],
      'is_open_to_remote': workMode?.toLowerCase().contains('remote') ?? false,
      'preferred_locations': [
        preferredCity,
        preferredCountry,
      ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
      'experience_level': experienceLevel,
      'career_goal': careerGoal,
      'open_to_relocation': openToRelocation,
      'target_roles': targetRoles,
      'preferred_industries': preferredIndustries,
    };
  }
}
