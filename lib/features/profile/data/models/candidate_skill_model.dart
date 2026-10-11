import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';

class CandidateSkillModel extends CandidateSkillEntity {
  const CandidateSkillModel({
    required super.id,
    required super.skillId,
    required super.name,
    required super.source,
    super.proficiencyLevel,
  });

  factory CandidateSkillModel.fromJson(Map<String, dynamic> json) {
    final skill = json['skill'] as Map<String, dynamic>;

    return CandidateSkillModel(
      id: json['id'] as int,
      skillId: json['skill_id'] as int,
      source: json['source'] as String,
      proficiencyLevel: json['proficiency_level'] as String?,
      name: skill['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill_id': skillId,
      'source': source,
      'proficiency_level': proficiencyLevel,
      'skill': {'id': skillId, 'name': name},
    };
  }
}
