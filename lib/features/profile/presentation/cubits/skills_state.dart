import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:equatable/equatable.dart';

sealed class SkillsState extends Equatable {
  const SkillsState();

  @override
  List<Object?> get props => [];
}

final class SkillsInitial extends SkillsState {
  const SkillsInitial();
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

final class SkillsActionFailure extends SkillsState {
  const SkillsActionFailure({required this.skills, required this.message});

  final List<CandidateSkillEntity> skills;
  final String message;

  @override
  List<Object?> get props => [skills, message];
}

final class SkillsSearchSuccess extends SkillsState {
  const SkillsSearchSuccess({required this.skills, required this.suggestions});

  final List<CandidateSkillEntity> skills;
  final List<SkillSearchResultEntity> suggestions;

  @override
  List<Object?> get props => [skills, suggestions];
}

final class SkillsSearchCleared extends SkillsState {
  const SkillsSearchCleared({required this.skills});

  final List<CandidateSkillEntity> skills;

  @override
  List<Object?> get props => [skills];
}
