import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_projects_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_project_use_case.dart';

import 'projects_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit({
    required this.getProjectsUseCase,
    required this.getProjectUseCase,
    required this.addCandidateProjectUseCase,
    required this.updateCandidateProjectUseCase,
    required this.deleteCandidateProjectUseCase,
  }) : super(const ProjectsInitial());

  final GetProjectsUseCase getProjectsUseCase;
  final GetProjectUseCase getProjectUseCase;
  final AddCandidateProjectUseCase addCandidateProjectUseCase;
  final UpdateCandidateProjectUseCase updateCandidateProjectUseCase;
  final DeleteCandidateProjectUseCase deleteCandidateProjectUseCase;

  List<CandidateProjectEntity> _projects = [];

  CandidateProjectEntity? _formProject;
  bool _isFormVisible = false;
  int _formResetToken = 0;

  /// Sticky session flag: once any Add/Edit/Delete succeeds it stays
  /// true until the screen is closed. Cancel never resets it.
  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  /// True when the most recent successful mutation was a delete,
  /// so the UI can show the matching localized feedback.
  bool _lastMutationWasDelete = false;

  bool get lastMutationWasDelete => _lastMutationWasDelete;

  void openAddForm() {
    if (state is ProjectsSaving) return;
    _formProject = null;
    _isFormVisible = true;
    _formResetToken++;
    _emitSuccess();
  }

  void openEditForm(CandidateProjectEntity project) {
    if (state is ProjectsSaving) return;
    _formProject = project;
    _isFormVisible = true;
    _formResetToken++;
    _emitSuccess();
  }

  void closeForm() {
    if (state is ProjectsSaving) return;
    _formProject = null;
    _isFormVisible = false;
    _formResetToken++;
    _emitSuccess();
  }

  void _emitSuccess() {
    emit(
      ProjectsSuccess(
        projects: List.unmodifiable(_projects),
        formProject: _formProject,
        isFormVisible: _isFormVisible,
        formResetToken: _formResetToken,
      ),
    );
  }

  void _emitSaving() {
    emit(
      ProjectsSaving(
        projects: List.unmodifiable(_projects),
        formProject: _formProject,
        isFormVisible: _isFormVisible,
        formResetToken: _formResetToken,
      ),
    );
  }

  void _emitActionFailure(String message) {
    emit(
      ProjectsActionFailure(
        projects: List.unmodifiable(_projects),
        message: message,
        isFormVisible: _isFormVisible,
        formProject: _formProject,
        formResetToken: _formResetToken,
      ),
    );
  }

  Future<void> getProjects() async {
    emit(const ProjectsLoading());

    final result = await getProjectsUseCase();
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(ProjectsFailure(message: failure.message));
      },
      (projects) {
        _projects = projects;
        _emitSuccess();
      },
    );
  }

  Future<void> addProject(AddCandidateProjectParams params) async {
    if (state is ProjectsSaving) return;
    _emitSaving();

    final result = await addCandidateProjectUseCase(params);
    if (isClosed) return;

    result.fold(
      (failure) {
        _emitActionFailure(failure.message);
      },
      (project) {
        if (project == null) {
          _refreshAfterMutation();
          return;
        }
        _projects = [project, ..._projects];

        _formProject = null;
        _isFormVisible = false;
        _formResetToken++;
        _hasChanges = true;
        _lastMutationWasDelete = false;

        _emitSuccess();
      },
    );
  }

  Future<void> updateProject(UpdateCandidateProjectParams params) async {
    if (state is ProjectsSaving) return;
    _emitSaving();

    final result = await updateCandidateProjectUseCase(params);
    if (isClosed) return;

    result.fold(
      (failure) {
        _emitActionFailure(failure.message);
      },
      (updatedProject) {
        if (updatedProject == null) {
          _refreshAfterMutation();
          return;
        }
        _projects = _projects
            .map(
              (project) =>
                  project.id == updatedProject.id ? updatedProject : project,
            )
            .toList();

        _formProject = null;
        _isFormVisible = false;
        _formResetToken++;
        _hasChanges = true;
        _lastMutationWasDelete = false;

        _emitSuccess();
      },
    );
  }

  Future<void> deleteProject(int projectId) async {
    if (state is ProjectsSaving) return;
    _emitSaving();

    final result = await deleteCandidateProjectUseCase(projectId);
    if (isClosed) return;

    result.fold(
      (failure) {
        _emitActionFailure(failure.message);
      },
      (_) {
        _projects = _projects
            .where((project) => project.id != projectId)
            .toList();

        if (_formProject?.id == projectId) {
          _formProject = null;
          _isFormVisible = false;
          _formResetToken++;
        }
        _hasChanges = true;
        _lastMutationWasDelete = true;

        _emitSuccess();
      },
    );
  }

  /// Reloads the authoritative list when a mutation succeeded but its
  /// response payload was incomplete. The existing list is preserved on
  /// refresh failure, while [_hasChanges] stays true because the server
  /// already applied the mutation.
  Future<void> _refreshAfterMutation() async {
    final result = await getProjectsUseCase();
    if (isClosed) return;

    result.fold(
      (failure) {
        _hasChanges = true;
        _emitActionFailure(failure.message);
      },
      (projects) {
        _projects = projects;

        _formProject = null;
        _isFormVisible = false;
        _formResetToken++;
        _hasChanges = true;
        _lastMutationWasDelete = false;

        _emitSuccess();
      },
    );
  }
}
