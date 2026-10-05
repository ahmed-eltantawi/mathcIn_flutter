import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:equatable/equatable.dart';

sealed class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

final class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

final class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

final class ProjectsSuccess extends ProjectsState {
  const ProjectsSuccess({required this.projects});

  final List<CandidateProjectEntity> projects;

  @override
  List<Object?> get props => [projects];
}

final class ProjectsFailure extends ProjectsState {
  const ProjectsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProjectsActionFailure extends ProjectsState {
  const ProjectsActionFailure({required this.projects, required this.message});

  final List<CandidateProjectEntity> projects;
  final String message;

  @override
  List<Object?> get props => [projects, message];
}
