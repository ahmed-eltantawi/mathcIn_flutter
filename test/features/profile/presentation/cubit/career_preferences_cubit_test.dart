import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/save_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_cubit/career_preferences_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_cubit/career_preferences_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCareerRepository extends Fake implements ProfileRepository {
  Either<Failure, CareerPreferenceEntity?>? getResult;
  Either<Failure, CareerPreferenceEntity>? saveResult;

  @override
  Future<Either<Failure, CareerPreferenceEntity?>>
  getCareerPreferences() async {
    return getResult!;
  }

  @override
  Future<Either<Failure, CareerPreferenceEntity>> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  ) async {
    return saveResult!;
  }
}

const _prefs = CareerPreferenceEntity(
  id: 1,
  targetRole: 'Backend Engineer',
  jobType: 'full_time',
  workMode: 'remote',
  preferredCountry: 'Egypt',
  preferredCity: 'Cairo',
  experienceLevel: 'senior',
  careerGoal: 'Lead a team.',
  openToRelocation: false,
);

const _saved = CareerPreferenceEntity(
  id: 1,
  targetRole: 'Backend Technical Lead',
  jobType: 'full_time',
  workMode: 'remote',
  preferredCountry: 'Egypt',
  preferredCity: 'Cairo',
  experienceLevel: 'senior',
  careerGoal: 'Lead a team.',
  openToRelocation: false,
);

CareerPreferencesCubit buildCubit(
  FakeCareerRepository repo,
) => CareerPreferencesCubit(
  getCareerPreferencesUseCase: GetCareerPreferencesUseCase(repository: repo),
  saveCareerPreferencesUseCase: SaveCareerPreferencesUseCase(repository: repo),
);

void main() {
  late FakeCareerRepository repo;

  setUp(() {
    repo = FakeCareerRepository();
  });

  group('CareerPreferencesCubit GET', () {
    blocTest<CareerPreferencesCubit, CareerPreferencesState>(
      'emits [Loading, Success] when GET succeeds',
      build: () {
        repo.getResult = const Right(_prefs);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.getCareerPreferences(),
      expect: () => const [
        CareerPreferencesLoading(),
        CareerPreferencesSuccess(preferences: _prefs),
      ],
    );

    blocTest<CareerPreferencesCubit, CareerPreferencesState>(
      'emits [Loading, Success(null)] when data is null',
      build: () {
        repo.getResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.getCareerPreferences(),
      expect: () => const [
        CareerPreferencesLoading(),
        CareerPreferencesSuccess(preferences: null),
      ],
    );

    blocTest<CareerPreferencesCubit, CareerPreferencesState>(
      'emits [Loading, Failure] when offline',
      build: () {
        repo.getResult = const Left(OfflineFailure());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.getCareerPreferences(),
      expect: () => const [
        CareerPreferencesLoading(),
        CareerPreferencesFailure(message: 'You are offline'),
      ],
    );
  });

  group('CareerPreferencesCubit save', () {
    blocTest<CareerPreferencesCubit, CareerPreferencesState>(
      'emits [Saving, SaveSuccess] and tracks hasChanges',
      build: () {
        repo.getResult = const Right(_prefs);
        repo.saveResult = const Right(_saved);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCareerPreferences();
        await cubit.saveCareerPreferences(
          const SaveCareerPreferencesParams().copyWith(
            targetRole: 'Backend Technical Lead',
          ),
        );
      },
      expect: () => const [
        CareerPreferencesLoading(),
        CareerPreferencesSuccess(preferences: _prefs),
        CareerPreferencesSaving(preferences: _prefs),
        CareerPreferencesSaveSuccess(preferences: _saved),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<CareerPreferencesCubit, CareerPreferencesState>(
      'emits [Saving, ActionFailure] preserving preferences on failure',
      build: () {
        repo.getResult = const Right(_prefs);
        repo.saveResult = const Left(
          ServerFailure(message: 'Validation failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCareerPreferences();
        await cubit.saveCareerPreferences(
          const SaveCareerPreferencesParams().copyWith(
            targetRole: 'Backend Technical Lead',
          ),
        );
      },
      expect: () => const [
        CareerPreferencesLoading(),
        CareerPreferencesSuccess(preferences: _prefs),
        CareerPreferencesSaving(preferences: _prefs),
        CareerPreferencesActionFailure(
          preferences: _prefs,
          message: 'Validation failed',
        ),
      ],
      verify: (cubit) {
        expect(cubit.hasChanges, isFalse);
      },
    );

    blocTest<CareerPreferencesCubit, CareerPreferencesState>(
      'prevents duplicate save requests',
      build: () {
        repo.getResult = const Right(_prefs);
        repo.saveResult = const Right(_saved);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCareerPreferences();
        cubit.saveCareerPreferences(
          const SaveCareerPreferencesParams().copyWith(targetRole: 'X'),
        );
        await cubit.saveCareerPreferences(
          const SaveCareerPreferencesParams().copyWith(targetRole: 'Y'),
        );
      },
      expect: () => const [
        CareerPreferencesLoading(),
        CareerPreferencesSuccess(preferences: _prefs),
        CareerPreferencesSaving(preferences: _prefs),
        CareerPreferencesSaveSuccess(preferences: _saved),
      ],
    );
  });
}
