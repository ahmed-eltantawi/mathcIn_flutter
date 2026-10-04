import 'package:equatable/equatable.dart';

class CandidateSkillEntity extends Equatable {
  const CandidateSkillEntity({
    required this.id,
    required this.skillId,
    required this.name,
    required this.source,
    this.proficiencyLevel,
  });

  final int id;
  final int skillId;
  final String name;
  final String source;
  final String? proficiencyLevel;

  @override
  List<Object?> get props => [id, skillId, name, source, proficiencyLevel];
}
