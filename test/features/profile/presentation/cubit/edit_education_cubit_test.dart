import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_education_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_education_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_education_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_educations_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_education_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/education_cubit/edit_education_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/education_cubit/edit_education_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeEducationRepository extends Fake implements ProfileRepository {
  Either<Failure, List<EducationEntity>>? listResult;
  Either<Failure, EducationEntity?>? mutationResult;

  @override
  Future<Either<Failure, List<EducationEntity>>> getEducations() async {
    return listResult!;
  }

  @override
  Future<Either<Failure, EducationEntity?>> addEducation(
    AddEducationParams params,
  ) async {
    return mutationResult!;
  }

  @override
  Future<Either<Failure, EducationEntity?>> updateEducation(
    UpdateEducationParams params,
  ) async {
    return mutationResult!;
  }

  @override
  Future<Either<Failure, Unit>> deleteEducation(int educationId) async {
    return mutationResult!.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }
}

const _first = EducationEntity(
  id: 1,
  degree: 'Bachelor of Engineering',
  institution: 'Ain Shams University',
  fieldOfStudy: 'Computer Engineering',
  startDate: '2018-09-01',
  endDate: '2023-07-01',
  grade: 'Excellent',
);

const _added = EducationEntity(
  id: 2,
  degree: 'Master of Science',
  institution: 'Cairo University',
  startDate: '2023-09-01',
);

const _updated = EducationEntity(
  id: 1,
  degree: 'Bachelor of Engineering',
  institution: 'Ain Shams University',
  fieldOfStudy: 'Computer Engineering',
  startDate: '2018-09-01',
  endDate: '2023-07-01',
  grade: 'Excellent with Honours',
);

EditEducationCubit buildCubit(FakeEducationRepository repo) =>
    EditEducationCubit(
      getEducationsUseCase: GetEducationsUseCase(repository: repo),
      addEducationUseCase: AddEducationUseCase(repository: repo),
      updateEducationUseCase: UpdateEducationUseCase(repository: repo),
      deleteEducationUseCase: DeleteEducationUseCase(repository: repo),
    );

void main() {
  late FakeEducationRepository repo;

  setUp(() {
    repo = FakeEducationRepository();
  });

  group('EditEducationCubit GET', () {
    blocTest<EditEducationCubit, EditEducationState>(
      'emits [Loading, Success] when GET succeeds',
      build: () {
        repo.listResult = const Right([_first]);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.loadEducations(),
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
      ],
    );

    blocTest<EditEducationCubit, EditEducationState>(
      'emits [Loading, Failure] when offline',
      build: () {
        repo.listResult = const Left(OfflineFailure());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.loadEducations(),
      expect: () => const [
        EditEducationLoading(),
        EditEducationFailure(message: 'You are offline'),
      ],
    );
  });

  group('EditEducationCubit add', () {
    blocTest<EditEducationCubit, EditEducationState>(
      'emits [Saving, Success] with record added and hasChanges true',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_added);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        await cubit.addEducation(
          const AddEducationParams(institution: 'Cairo University'),
        );
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
        EditEducationSaving(educations: [_first]),
        EditEducationSuccess(educations: [_added, _first], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
        expect(cubit.lastMutationWasDelete, isFalse);
      },
    );

    blocTest<EditEducationCubit, EditEducationState>(
      'emits [Saving, ActionFailure] preserving the list on failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Validation failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        await cubit.addEducation(
          const AddEducationParams(institution: 'Cairo University'),
        );
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
        EditEducationSaving(educations: [_first]),
        EditEducationActionFailure(
          educations: [_first],
          message: 'Validation failed',
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isFalse);
      },
    );
  });

  group('EditEducationCubit edit', () {
    blocTest<EditEducationCubit, EditEducationState>(
      'emits [Saving, Success] with record replaced on update success',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_updated);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        cubit.startEdit(_first);
        await cubit.updateEducation(
          const UpdateEducationParams(educationId: 1)
              .copyWith(educationId: 1, grade: 'Excellent with Honours'),
        );
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
        EditEducationSuccess(
          educations: [_first],
          editingEducation: _first,
          formResetToken: 1,
        ),
        EditEducationSaving(
          educations: [_first],
          editingEducation: _first,
          formResetToken: 1,
        ),
        EditEducationSuccess(educations: [_updated], formResetToken: 2),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<EditEducationCubit, EditEducationState>(
      'preserves list and form education on update failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Update failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        cubit.startEdit(_first);
        await cubit.updateEducation(
          const UpdateEducationParams(educationId: 1)
              .copyWith(educationId: 1, grade: 'Excellent with Honours'),
        );
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
        EditEducationSuccess(
          educations: [_first],
          editingEducation: _first,
          formResetToken: 1,
        ),
        EditEducationSaving(
          educations: [_first],
          editingEducation: _first,
          formResetToken: 1,
        ),
        EditEducationActionFailure(
          educations: [_first],
          message: 'Update failed',
          editingEducation: _first,
          formResetToken: 1,
        ),
      ],
    );
  });

  group('EditEducationCubit delete', () {
    blocTest<EditEducationCubit, EditEducationState>(
      'emits [Saving, Success] with record removed on delete success',
      build: () {
        repo.listResult = const Right([_first, _added]);
        repo.mutationResult = const Right(_first);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        await cubit.deleteEducation(1);
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_added, _first]),
        EditEducationSaving(educations: [_added, _first]),
        EditEducationSuccess(educations: [_added]),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
        expect(cubit.lastMutationWasDelete, isTrue);
      },
    );

    blocTest<EditEducationCubit, EditEducationState>(
      'keeps the list on delete failure',
      build: () {
        repo.listResult = const Right([_first, _added]);
        repo.mutationResult = const Left(
          ServerFailure(message: 'Delete failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        await cubit.deleteEducation(1);
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_added, _first]),
        EditEducationSaving(educations: [_added, _first]),
        EditEducationActionFailure(
          educations: [_added, _first],
          message: 'Delete failed',
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isFalse);
      },
    );
  });

  group('EditEducationCubit incomplete mutation responses', () {
    blocTest<EditEducationCubit, EditEducationState>(
      'refreshes from GET on partial POST response',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        repo.listResult = const Right([_first, _added]);
        await cubit.addEducation(
          const AddEducationParams(institution: 'Cairo University'),
        );
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
        EditEducationSaving(educations: [_first]),
        EditEducationSuccess(educations: [_added, _first], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<EditEducationCubit, EditEducationState>(
      'refreshes from GET on partial PATCH response',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        repo.listResult = const Right([_updated]);
        await cubit.updateEducation(
          const UpdateEducationParams(educationId: 1)
              .copyWith(educationId: 1, grade: 'Excellent with Honours'),
        );
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
        EditEducationSaving(educations: [_first]),
        EditEducationSuccess(educations: [_updated], formResetToken: 1),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<EditEducationCubit, EditEducationState>(
      'preserves list but keeps hasChanges on refresh failure',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        repo.listResult = const Left(OfflineFailure());
        await cubit.addEducation(
          const AddEducationParams(institution: 'Cairo University'),
        );
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
        EditEducationSaving(educations: [_first]),
        EditEducationActionFailure(
          educations: [_first],
          message: 'You are offline',
        ),
      ],
      verify: (cubit) {
        // The server applied the mutation; only the refresh failed.
        expect(cubit.hasChanges, isTrue);
      },
    );
  });

  group('EditEducationCubit session flags', () {
    blocTest<EditEducationCubit, EditEducationState>(
      'cancelEdit resets to Add mode without clearing hasChanges',
      build: () {
        repo.listResult = const Right([_first]);
        repo.mutationResult = const Right(_added);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadEducations();
        await cubit.addEducation(
          const AddEducationParams(institution: 'Cairo University'),
        );
        cubit.cancelEdit();
      },
      expect: () => const [
        EditEducationLoading(),
        EditEducationSuccess(educations: [_first]),
        EditEducationSaving(educations: [_first]),
        EditEducationSuccess(educations: [_added, _first], formResetToken: 1),
        EditEducationSuccess(educations: [_added, _first], formResetToken: 2),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );
  });
}
