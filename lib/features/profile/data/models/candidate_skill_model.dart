import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
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
    final skill = json['skill'];
    if (skill is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate skill: missing skill');
    }

    return CandidateSkillModel(
      id: JsonParsing.parseId(json['id']) ?? 0,
      skillId: JsonParsing.parseId(json['skill_id']) ?? 0,
      source: JsonParsing.parseString(json['source']) ?? 'manual',
      proficiencyLevel: JsonParsing.parseString(json['proficiency_level']),
      name: skill['name']?.toString() ?? '',
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
