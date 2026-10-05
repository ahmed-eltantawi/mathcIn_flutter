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
      id: json['id'] as int,
      targetRole: json['target_role'] as String?,
      jobType: json['job_type'] as String?,
      workMode: json['work_mode'] as String?,
      preferredCountry: json['preferred_country'] as String?,
      preferredCity: json['preferred_city'] as String?,
      experienceLevel: json['experience_level'] as String?,
      careerGoal: json['career_goal'] as String?,
      openToRelocation: json['open_to_relocation'] as bool?,
      targetRoles: _stringList(json['target_roles']),
      preferredIndustries: _stringList(json['preferred_industries']),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => item.toString()).toList();
  }
}
