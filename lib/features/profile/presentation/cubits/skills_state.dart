import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:equatable/equatable.dart';

sealed class SkillsState extends Equatable {
  const SkillsState();

  @override
  List<Object?> get props => [];
}

final class SkillsInitial extends SkillsState {
  const SkillsInitial() : super();
}

final class SkillsLoading extends SkillsState {
  const SkillsLoading();
}

final class SkillsSuccess extends SkillsState {
  const SkillsSuccess({required this.skills});
  final List<CandidateSkillEntity> skills;

  @override
  List<Object?> get props => [skills];
}

final class SkillsFailure extends SkillsState {
  const SkillsFailure({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
