import 'package:equatable/equatable.dart';

class AddCandidateSkillParams extends Equatable {
  const AddCandidateSkillParams({
    required this.name,
    required this.proficiencyLevel,
  });

  final String name;
  final String proficiencyLevel;

  @override
  List<Object?> get props => [name, proficiencyLevel];
}
