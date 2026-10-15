import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_experience_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_experience_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_experiences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_experience_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/experience_cubit/edit_experience_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/experience_cubit/edit_experience_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExperienceRepository extends Fake implements ProfileRepository {
  Either<Failure, List<ExperienceEntity>>? listResult;
  Either<Failure, ExperienceEntity?>? mutationResult;

  @override
  Future<Either<Failure, List<ExperienceEntity>>> getExperiences() async {
    return listResult!;
  }

  @override
  Future<Either<Failure, ExperienceEntity?>> addExperience(
    AddExperienceParams params,
  ) async {
    return mutationResult!;
  }

  @override
  Future<Either<Failure, ExperienceEntity?>> updateExperience(
    UpdateExperienceParams params,
  ) async {
    return mutationResult!;
  }

  @override
  Future<Either<Failure, Unit>> deleteExperience(int experienceId) async {
    return mutationResult!.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }
}

const _first = ExperienceEntity(
  id: 1,
  jobTitle: 'Backend Engineer',
  companyName: 'Fawry',
  employmentType: 'full_time',
  startDate: '2023-01-01',
  isCurrent: true,
);

const _added = ExperienceEntity(
  id: 2,
  jobTitle: 'Senior Backend Developer',
  companyName: 'PayMob',
  startDate: '2024-03-01',
  endDate: '2025-01-01',
);

const _updated = ExperienceEntity(
  id: 1,
  jobTitle: 'Senior Backend Engineer',
  companyName: 'Fawry',
  employmentType: 'full_time',
  startDate: '2023-01-01',
  isCurrent: true,
);

EditExperienceCubit buildCubit(FakeExperienceRepository repo) =>
    EditExperienceCubit(
      getExperiencesUseCase: GetExperiencesUseCase(repository: repo),
      addExperienceUseCase: AddExperienceUseCase(repository: repo),
      updateExperienceUseCase: UpdateExperienceUseCase(repository: repo),
      deleteExperienceUseCase: DeleteExperienceUseCase(repository: repo),
    );

void main() {
  late FakeExperienceRepository repo;

  setUp(() {
    repo = FakeExperienceRepository();
  });

  group('EditExperienceCubit GET', () {
    blocTest<EditExperienceCubit, EditExperienceState>(
      'emits [Loading, Success] when GET succeeds',
      build: () {
        repo.listResult = const Right([_first]);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.loadExperiences(),
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
      ],
    );

    blocTest<EditExperienceCubit, EditExperienceState>(
      'emits [Loading, Failure] when offline',
      build: () {
        repo.listResult = const Left(OfflineFailure());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.loadExperiences(),
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceFailure(message: 'You are offline'),
      ],
    );
  });

  group('EditExperienceCubit add', () {
    blocTest<EditExperienceCubit, EditExperienceState>(
      'emits [Saving, Success] with record added and hasChanges true',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_added);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        await cubit.addExperience(
          const AddExperienceParams(
            jobTitle: 'Senior Backend Developer',
            companyName: 'PayMob',
          ),
        );
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
        EditExperienceSaving(experiences: [_first]),
        EditExperienceSuccess(experiences: [_added, _first], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
        expect(cubit.lastMutationWasDelete, isFalse);
      },
    );

    blocTest<EditExperienceCubit, EditExperienceState>(
      'emits [Saving, ActionFailure] preserving the list on failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Validation failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        await cubit.addExperience(
          const AddExperienceParams(
            jobTitle: 'Senior Backend Developer',
            companyName: 'PayMob',
          ),
        );
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
        EditExperienceSaving(experiences: [_first]),
        EditExperienceActionFailure(
          experiences: [_first],
          message: 'Validation failed',
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isFalse);
      },
    );
  });

  group('EditExperienceCubit edit', () {
    blocTest<EditExperienceCubit, EditExperienceState>(
      'emits [Saving, Success] with record replaced on update success',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_updated);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        cubit.startEdit(_first);
        await cubit.updateExperience(
          const UpdateExperienceParams(experienceId: 1)
              .copyWith(experienceId: 1, jobTitle: 'Senior Backend Engineer'),
        );
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
        EditExperienceSuccess(
          experiences: [_first],
          editingExperience: _first,
          formResetToken: 1,
        ),
        EditExperienceSaving(
          experiences: [_first],
          editingExperience: _first,
          formResetToken: 1,
        ),
        EditExperienceSuccess(experiences: [_updated], formResetToken: 2),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<EditExperienceCubit, EditExperienceState>(
      'preserves list and form experience on update failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Update failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        cubit.startEdit(_first);
        await cubit.updateExperience(
          const UpdateExperienceParams(experienceId: 1)
              .copyWith(experienceId: 1, jobTitle: 'Senior Backend Engineer'),
        );
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
        EditExperienceSuccess(
          experiences: [_first],
          editingExperience: _first,
          formResetToken: 1,
        ),
        EditExperienceSaving(
          experiences: [_first],
          editingExperience: _first,
          formResetToken: 1,
        ),
        EditExperienceActionFailure(
          experiences: [_first],
          message: 'Update failed',
          editingExperience: _first,
          formResetToken: 1,
        ),
      ],
    );
  });

  group('EditExperienceCubit delete', () {
    blocTest<EditExperienceCubit, EditExperienceState>(
      'emits [Saving, Success] with record removed on delete success',
      build: () {
        repo.listResult = const Right([_first, _added]);
        repo.mutationResult = const Right(_first);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        await cubit.deleteExperience(1);
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_added, _first]),
        EditExperienceSaving(experiences: [_added, _first]),
        EditExperienceSuccess(experiences: [_added]),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
        expect(cubit.lastMutationWasDelete, isTrue);
      },
    );

    blocTest<EditExperienceCubit, EditExperienceState>(
      'keeps the list on delete failure',
      build: () {
        repo.listResult = const Right([_first, _added]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Delete failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        await cubit.deleteExperience(1);
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_added, _first]),
        EditExperienceSaving(experiences: [_added, _first]),
        EditExperienceActionFailure(
          experiences: [_added, _first],
          message: 'Delete failed',
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isFalse);
      },
    );
  });

  group('EditExperienceCubit incomplete mutation responses', () {
    blocTest<EditExperienceCubit, EditExperienceState>(
      'refreshes from GET on partial POST response',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        repo.listResult = const Right([_first, _added]);
        await cubit.addExperience(
          const AddExperienceParams(
            jobTitle: 'Senior Backend Developer',
            companyName: 'PayMob',
          ),
        );
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
        EditExperienceSaving(experiences: [_first]),
        EditExperienceSuccess(experiences: [_added, _first], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<EditExperienceCubit, EditExperienceState>(
      'refreshes from GET on partial PATCH response',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        repo.listResult = const Right([_updated]);
        await cubit.updateExperience(
          const UpdateExperienceParams(experienceId: 1)
              .copyWith(experienceId: 1, jobTitle: 'Senior Backend Engineer'),
        );
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
        EditExperienceSaving(experiences: [_first]),
        EditExperienceSuccess(experiences: [_updated], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<EditExperienceCubit, EditExperienceState>(
      'preserves list but keeps hasChanges on refresh failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        repo.listResult = const Left(OfflineFailure());
        await cubit.addExperience(
          const AddExperienceParams(
            jobTitle: 'Senior Backend Developer',
            companyName: 'PayMob',
          ),
        );
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
        EditExperienceSaving(experiences: [_first]),
        EditExperienceActionFailure(
          experiences: [_first],
          message: 'You are offline',
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );
  });

  group('EditExperienceCubit session flags', () {
    blocTest<EditExperienceCubit, EditExperienceState>(
      'cancelEdit resets to Add mode without clearing hasChanges',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_added);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadExperiences();
        await cubit.addExperience(
          const AddExperienceParams(
            jobTitle: 'Senior Backend Developer',
            companyName: 'PayMob',
          ),
        );
        cubit.cancelEdit();
      },
      expect: () => const [
        EditExperienceLoading(),
        EditExperienceSuccess(experiences: [_first]),
        EditExperienceSaving(experiences: [_first]),
        EditExperienceSuccess(experiences: [_added, _first], formResetToken: 1),
        EditExperienceSuccess(experiences: [_added, _first], formResetToken: 2),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );
  });
}
