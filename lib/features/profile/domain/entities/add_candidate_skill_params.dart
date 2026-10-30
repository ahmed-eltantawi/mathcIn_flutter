import 'package:equatable/equatable.dart';

class AddCandidateSkillParams extends Equatable {
  const AddCandidateSkillParams({
    this.skillId = 0,
    required this.name,
    this.proficiencyLevel = 'intermediate',
  });

  final int skillId;
  final String name;
  final String proficiencyLevel;

  @override
  List<Object?> get props => [skillId, name, proficiencyLevel];
}
