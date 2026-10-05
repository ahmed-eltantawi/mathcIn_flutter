import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_projects_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_state.dart';
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
  final AddCandidateProjectUseCase
  addCandidateProjectUseCase;
  final UpdateCandidateProjectUseCase
  updateCandidateProjectUseCase;
  final DeleteCandidateProjectUseCase
  deleteCandidateProjectUseCase;

  List<CandidateProjectEntity> _projects = [];

  CandidateProjectEntity? _formProject;
  bool _isFormVisible = false;

  void openAddForm() {
    _formProject = null;
    _isFormVisible = true;
    _emitSuccess();
  }

  void openEditForm(CandidateProjectEntity project) {
    _formProject = project;
    _isFormVisible = true;
    _emitSuccess();
  }

  void closeForm() {
    _formProject = null;
    _isFormVisible = false;
    _emitSuccess();
  }

  void _emitSuccess() {
    emit(
      ProjectsSuccess(
        projects: List.unmodifiable(_projects),
        formProject: _formProject,
        isFormVisible: _isFormVisible,
      ),
    );
  }

  Future<void> getProjects() async {
    emit(const ProjectsLoading());

    final result = await getProjectsUseCase();

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

  Future<void> addProject(
    AddCandidateProjectParams params,
  ) async {
    final result = await addCandidateProjectUseCase(params);

    result.fold(
      (failure) {
        emit(
          ProjectsActionFailure(
            projects: List.unmodifiable(_projects),
            message: failure.message,
            isFormVisible: _isFormVisible,
            formProject: _formProject,
          ),
        );
      },
      (project) {
        _projects = [project, ..._projects];

        _formProject = null;
        _isFormVisible = false;

        _emitSuccess();
      },
    );
  }

  Future<void> updateProject(
    UpdateCandidateProjectParams params,
  ) async {
    final result = await updateCandidateProjectUseCase(
      params,
    );

    result.fold(
      (failure) {
        emit(
          ProjectsActionFailure(
            projects: List.unmodifiable(_projects),
            message: failure.message,
            isFormVisible: _isFormVisible,
            formProject: _formProject,
          ),
        );
      },
      (updatedProject) {
        _projects = _projects
            .map(
              (project) => project.id == updatedProject.id
                  ? updatedProject
                  : project,
            )
            .toList();

        _formProject = null;
        _isFormVisible = false;

        _emitSuccess();
      },
    );
  }

  Future<void> deleteProject(int projectId) async {
    final result = await deleteCandidateProjectUseCase(
      projectId,
    );

    result.fold(
      (failure) {
        emit(
          ProjectsActionFailure(
            projects: List.unmodifiable(_projects),
            message: failure.message,
            isFormVisible: _isFormVisible,
            formProject: _formProject,
          ),
        );
      },
      (_) {
        _projects = _projects
            .where((project) => project.id != projectId)
            .toList();

        _emitSuccess();
      },
    );
  }
}
