import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';

abstract class SkillsDebugData {
  static const skills = <CandidateSkillEntity>[
    CandidateSkillEntity(
      id: 1,
      skillId: 101,
      name: 'Flutter',
      source: 'manual',
      proficiencyLevel: null,
    ),
    CandidateSkillEntity(
      id: 2,
      skillId: 102,
      name: 'Dart',
      source: 'manual',
      proficiencyLevel: null,
    ),
    CandidateSkillEntity(
      id: 3,
      skillId: 103,
      name: 'REST APIs',
      source: 'manual',
      proficiencyLevel: null,
    ),
  ];
}
