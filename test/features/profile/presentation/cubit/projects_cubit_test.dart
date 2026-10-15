import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_projects_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit/projects_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit/projects_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProjectsRepository extends Fake implements ProfileRepository {
  Either<Failure, List<CandidateProjectEntity>>? listResult;
  Either<Failure, CandidateProjectEntity?>? mutationResult;
  UpdateCandidateProjectParams? lastUpdateParams;

  @override
  Future<Either<Failure, List<CandidateProjectEntity>>> getProjects() async {
    return listResult!;
  }

  @override
  Future<Either<Failure, CandidateProjectEntity?>> addCandidateProject(
    AddCandidateProjectParams params,
  ) async {
    return mutationResult!;
  }

  @override
  Future<Either<Failure, CandidateProjectEntity?>> updateCandidateProject(
    UpdateCandidateProjectParams params,
  ) async {
    lastUpdateParams = params;
    return mutationResult!;
  }

  @override
  Future<Either<Failure, Unit>> deleteCandidateProject(int projectId) async {
    return mutationResult!.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }
}

const _first = CandidateProjectEntity(
  id: 1,
  name: 'Order Engine',
  description: 'Queue processing.',
  technologies: ['Dart'],
  source: 'manual',
);

const _added = CandidateProjectEntity(
  id: 2,
  name: 'Health Tracker',
  source: 'manual',
  technologies: [],
);

const _updated = CandidateProjectEntity(
  id: 1,
  name: 'Order Engine v2',
  description: 'Queue processing.',
  technologies: ['Dart'],
  source: 'manual',
);

ProjectsCubit buildCubit(FakeProjectsRepository repo) => ProjectsCubit(
  getProjectsUseCase: GetProjectsUseCase(repository: repo),
  getProjectUseCase: GetProjectUseCase(repository: repo),
  addCandidateProjectUseCase: AddCandidateProjectUseCase(repository: repo),
  updateCandidateProjectUseCase: UpdateCandidateProjectUseCase(
    repository: repo,
  ),
  deleteCandidateProjectUseCase: DeleteCandidateProjectUseCase(
    repository: repo,
  ),
);

AddCandidateProjectParams addParams() =>
    const AddCandidateProjectParams(name: 'Health Tracker');

void main() {
  late FakeProjectsRepository repo;

  setUp(() {
    repo = FakeProjectsRepository();
  });

  group('ProjectsCubit GET', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'emits [Loading, Success] when GET succeeds',
      build: () {
        repo.listResult = const Right([_first]);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.getProjects(),
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
      ],
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'emits [Loading, Failure] when offline',
      build: () {
        repo.listResult = const Left(OfflineFailure());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.getProjects(),
      expect: () => const [
        ProjectsLoading(),
        ProjectsFailure(message: 'You are offline'),
      ],
    );
  });

  group('ProjectsCubit add', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'emits [Saving, Success] with the project prepended',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_added);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        await cubit.addProject(addParams());
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSaving(projects: [_first]),
        ProjectsSuccess(projects: [_added, _first], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'emits [Saving, ActionFailure] preserving the list on failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Validation failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        cubit.openAddForm();
        await cubit.addProject(addParams());
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSuccess(
          projects: [_first],
          isFormVisible: true,
          formResetToken: 1,
        ),
        ProjectsSaving(
          projects: [_first],
          isFormVisible: true,
          formResetToken: 1,
        ),
        ProjectsActionFailure(
          projects: [_first],
          message: 'Validation failed',
          isFormVisible: true,
          formResetToken: 1,
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isFalse);
      },
    );
  });

  group('ProjectsCubit edit', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'emits [Saving, Success] with the project replaced',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_updated);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        await cubit.updateProject(
          const UpdateCandidateProjectParams(projectId: 1)
              .copyWith(projectId: 1, name: 'Order Engine v2'),
        );
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSaving(projects: [_first]),
        ProjectsSuccess(projects: [_updated], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'sends explicit null for cleared optional fields',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_updated);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        await cubit.updateProject(
          const UpdateCandidateProjectParams(projectId: 1)
              .copyWith(projectId: 1, description: null),
        );
      },
      verify: (_) {
        final params = repo.lastUpdateParams!;
        expect(params.hasChanges, isTrue);
        expect(UpdateCandidateProjectParams.isSet(params.description), isTrue);
        expect(params.description, isNull);
        expect(UpdateCandidateProjectParams.isSet(params.name), isFalse);
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSaving(projects: [_first]),
        ProjectsSuccess(projects: [_updated], formResetToken: 1),
      ],
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'preserves list and form on update failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Update failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        cubit.openEditForm(_first);
        await cubit.updateProject(
          const UpdateCandidateProjectParams(projectId: 1)
              .copyWith(projectId: 1, name: 'Order Engine v2'),
        );
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSuccess(
          projects: [_first],
          formProject: _first,
          isFormVisible: true,
          formResetToken: 1,
        ),
        ProjectsSaving(
          projects: [_first],
          formProject: _first,
          isFormVisible: true,
          formResetToken: 1,
        ),
        ProjectsActionFailure(
          projects: [_first],
          message: 'Update failed',
          isFormVisible: true,
          formProject: _first,
          formResetToken: 1,
        ),
      ],
    );
  });

  group('ProjectsCubit delete', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'emits [Saving, Success] with the project removed',
      build: () {
        repo.listResult = const Right([_first, _added]);
        repo.mutationResult = const Right(_first);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        await cubit.deleteProject(1);
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first, _added]),
        ProjectsSaving(projects: [_first, _added]),
        ProjectsSuccess(projects: [_added]),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
        expect(cubit.lastMutationWasDelete, isTrue);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'keeps the list on delete failure',
      build: () {
        repo.listResult = const Right([_first, _added]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Delete failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        await cubit.deleteProject(1);
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first, _added]),
        ProjectsSaving(projects: [_first, _added]),
        ProjectsActionFailure(
          projects: [_first, _added],
          message: 'Delete failed',
          isFormVisible: false,
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isFalse);
      },
    );
  });

  group('ProjectsCubit incomplete mutation responses', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'refreshes from GET on partial POST response',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        repo.listResult = const Right([_first, _added]);
        await cubit.addProject(addParams());
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSaving(projects: [_first]),
        ProjectsSuccess(projects: [_first, _added], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'refreshes from GET on partial PATCH response',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        repo.listResult = const Right([_updated]);
        await cubit.updateProject(
          const UpdateCandidateProjectParams(projectId: 1)
              .copyWith(projectId: 1, name: 'Order Engine v2'),
        );
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSaving(projects: [_first]),
        ProjectsSuccess(projects: [_updated], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<ProjectsCubit, ProjectsState>(
      'preserves list but keeps hasChanges on refresh failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        repo.listResult = const Left(OfflineFailure());
        await cubit.addProject(addParams());
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSaving(projects: [_first]),
        ProjectsActionFailure(
          projects: [_first],
          message: 'You are offline',
          isFormVisible: false,
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );
  });

  group('ProjectsCubit form lifecycle', () {
    blocTest<ProjectsCubit, ProjectsState>(
      'openAddForm resets the form and cancelEdit keeps hasChanges',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_added);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getProjects();
        await cubit.addProject(addParams());
        cubit.openAddForm();
        cubit.closeForm();
      },
      expect: () => const [
        ProjectsLoading(),
        ProjectsSuccess(projects: [_first]),
        ProjectsSaving(projects: [_first]),
        ProjectsSuccess(projects: [_added, _first], formResetToken: 1),
        ProjectsSuccess(
          projects: [_added, _first],
          isFormVisible: true,
          formResetToken: 2,
        ),
        ProjectsSuccess(projects: [_added, _first], formResetToken: 3),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );
  });
}
