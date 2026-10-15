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
  const ProjectsSuccess({
    required this.projects,
    this.formProject,
    this.isFormVisible = false,
    this.formResetToken = 0,
  });

  final List<CandidateProjectEntity> projects;
  final CandidateProjectEntity? formProject;
  final bool isFormVisible;
  final int formResetToken;

  bool get isEditing => formProject != null;

  @override
  List<Object?> get props => [
    projects,
    formProject,
    isFormVisible,
    formResetToken,
  ];
}

final class ProjectsSaving extends ProjectsState {
  const ProjectsSaving({
    required this.projects,
    this.formProject,
    this.isFormVisible = false,
    this.formResetToken = 0,
  });

  final List<CandidateProjectEntity> projects;
  final CandidateProjectEntity? formProject;
  final bool isFormVisible;
  final int formResetToken;

  @override
  List<Object?> get props => [
    projects,
    formProject,
    isFormVisible,
    formResetToken,
  ];
}

final class ProjectsFailure extends ProjectsState {
  const ProjectsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProjectsActionFailure extends ProjectsState {
  const ProjectsActionFailure({
    required this.projects,
    required this.message,
    required this.isFormVisible,
    this.formProject,
    this.formResetToken = 0,
  });

  final List<CandidateProjectEntity> projects;
  final String message;

  final bool isFormVisible;
  final CandidateProjectEntity? formProject;
  final int formResetToken;

  @override
  List<Object?> get props => [
    projects,
    message,
    isFormVisible,
    formProject,
    formResetToken,
  ];
}
