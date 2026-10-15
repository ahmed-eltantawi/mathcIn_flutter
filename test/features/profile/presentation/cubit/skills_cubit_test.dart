import 'dart:async';

import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_skills_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/remove_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/search_skills_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit/skills_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSkillsRepository extends Fake implements ProfileRepository {
  Either<Failure, List<CandidateSkillEntity>>? listResult;
  Either<Failure, CandidateSkillEntity>? addResult;
  Either<Failure, Unit>? removeResult;
  int addCalls = 0;
  final Map<String, Either<Failure, List<SkillSearchResultEntity>>>
  searchResults = {};
  final Map<String, Completer<void>> searchGates = {};

  @override
  Future<Either<Failure, List<CandidateSkillEntity>>>
  getCandidateSkills() async {
    return listResult!;
  }

  @override
  Future<Either<Failure, CandidateSkillEntity>> addCandidateSkill(
    AddCandidateSkillParams params,
  ) async {
    addCalls++;
    return addResult!;
  }

  @override
  Future<Either<Failure, Unit>> removeCandidateSkill(
    int candidateSkillId,
  ) async {
    return removeResult!;
  }

  @override
  Future<Either<Failure, List<SkillSearchResultEntity>>> searchSkills(
    String query,
  ) async {
    final gate = searchGates[query];
    if (gate != null) await gate.future;
    return searchResults[query]!;
  }
}

const _flutter = CandidateSkillEntity(
  id: 1,
  skillId: 101,
  name: 'Flutter',
  source: 'manual',
);

const _docker = CandidateSkillEntity(
  id: 2,
  skillId: 102,
  name: 'Docker',
  source: 'manual',
);

SkillsCubit buildCubit(FakeSkillsRepository repo) => SkillsCubit(
  getCandidateSkillsUseCase: GetCandidateSkillsUseCase(repository: repo),
  addCandidateSkillUseCase: AddCandidateSkillUseCase(repository: repo),
  removeCandidateSkillUseCase: RemoveCandidateSkillUseCase(repository: repo),
  searchSkillsUseCase: SearchSkillsUseCase(repository: repo),
);

void main() {
  late FakeSkillsRepository repo;
  late bool addOutcome;
  late bool removeOutcome;

  setUp(() {
    repo = FakeSkillsRepository();
  });

  group('SkillsCubit GET', () {
    blocTest<SkillsCubit, SkillsState>(
      'emits [Loading, Success] when GET succeeds',
      build: () {
        repo.listResult = const Right([_flutter]);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.getCandidateSkills(),
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter]),
      ],
    );

    blocTest<SkillsCubit, SkillsState>(
      'emits [Loading, Failure] when offline',
      build: () {
        repo.listResult = const Left(OfflineFailure());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.getCandidateSkills(),
      expect: () => const [
        SkillsLoading(),
        SkillsFailure(message: 'You are offline'),
      ],
    );
  });

  group('SkillsCubit add', () {
    blocTest<SkillsCubit, SkillsState>(
      'emits [Success] with the skill prepended and returns true',
      build: () {
        repo.listResult = const Right([_flutter]);
        repo.addResult = const Right(_docker);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCandidateSkills();
        addOutcome = await cubit.addSkill(name: 'Docker');
      },
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter]),
        SkillsSuccess(skills: [_docker, _flutter]),
      ],
      verify: (cubit) {
        expect(addOutcome, isTrue);
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<SkillsCubit, SkillsState>(
      'emits [ActionFailure] with the list preserved and returns false',
      build: () {
        repo.listResult = const Right([_flutter]);
        repo.addResult = const Left(
          ServerFailure(message: 'Validation failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCandidateSkills();
        addOutcome = await cubit.addSkill(name: 'Docker');
      },
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter]),
        SkillsActionFailure(skills: [_flutter], message: 'Validation failed'),
      ],
      verify: (cubit) {
        expect(addOutcome, isFalse);
        expect(cubit.hasChanges, isFalse);
      },
    );
  });

  group('SkillsCubit delete', () {
    blocTest<SkillsCubit, SkillsState>(
      'emits [Success] without the skill and returns true',
      build: () {
        repo.listResult = const Right([_flutter, _docker]);
        repo.removeResult = const Right(unit);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCandidateSkills();
        removeOutcome = await cubit.removeSkill(1);
      },
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter, _docker]),
        SkillsSuccess(skills: [_docker]),
      ],
      verify: (cubit) {
        expect(removeOutcome, isTrue);
        expect(cubit.hasChanges, isTrue);
      },
    );

    blocTest<SkillsCubit, SkillsState>(
      'emits [ActionFailure] with the list preserved and returns false',
      build: () {
        repo.listResult = const Right([_flutter, _docker]);
        repo.removeResult = const Left(ServerFailure(message: 'Delete failed'));
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCandidateSkills();
        removeOutcome = await cubit.removeSkill(1);
      },
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter, _docker]),
        SkillsActionFailure(
          skills: [_flutter, _docker],
          message: 'Delete failed',
        ),
      ],
      verify: (cubit) {
        expect(removeOutcome, isFalse);
        expect(cubit.hasChanges, isFalse);
      },
    );
  });

  group('SkillsCubit search', () {
    const node = SkillSearchResultEntity(id: 201, name: 'Node.js');
    const dockerSuggestion = SkillSearchResultEntity(id: 202, name: 'Docker');

    blocTest<SkillsCubit, SkillsState>(
      'emits [SearchSuccess] preserving the list',
      build: () {
        repo.listResult = const Right([_flutter]);
        repo.searchResults['dock'] = const Right([dockerSuggestion]);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCandidateSkills();
        await cubit.searchSkills('dock');
      },
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter]),
        SkillsSearchSuccess(
          skills: [_flutter],
          suggestions: [dockerSuggestion],
        ),
      ],
    );

    blocTest<SkillsCubit, SkillsState>(
      'emits [ActionFailure] preserving the list on search failure',
      build: () {
        repo.listResult = const Right([_flutter]);
        repo.searchResults['dock'] = const Left(
          ServerFailure(message: 'Search failed'),
        );
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCandidateSkills();
        await cubit.searchSkills('dock');
      },
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter]),
        SkillsActionFailure(skills: [_flutter], message: 'Search failed'),
      ],
    );

    blocTest<SkillsCubit, SkillsState>(
      'ignores stale search responses',
      build: () {
        repo.listResult = const Right([_flutter]);
        repo.searchGates['slow'] = Completer<void>();
        repo.searchResults['slow'] = const Right([node]);
        repo.searchResults['fast'] = const Right([dockerSuggestion]);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCandidateSkills();
        final slow = cubit.searchSkills('slow');
        await cubit.searchSkills('fast');
        repo.searchGates['slow']!.complete();
        await slow;
      },
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter]),
        SkillsSearchSuccess(
          skills: [_flutter],
          suggestions: [dockerSuggestion],
        ),
      ],
    );
  });

  group('SkillsCubit duplicate prevention', () {
    test('ignores a second add while one is in flight', () async {
      repo.listResult = const Right([_flutter]);
      repo.addResult = const Right(_docker);
      final cubit = buildCubit(repo);
      await cubit.getCandidateSkills();

      final first = cubit.addSkill(name: 'Docker');
      final second = await cubit.addSkill(name: 'Docker');
      expect(second, isFalse);
      expect(await first, isTrue);
      expect(repo.addCalls, 1);

      await cubit.close();
    });
  });

  group('SkillsCubit session flags', () {
    blocTest<SkillsCubit, SkillsState>(
      'hasChanges stays true once set',
      build: () {
        repo.listResult = const Right([_flutter]);
        repo.addResult = const Right(_docker);
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.getCandidateSkills();
        await cubit.addSkill(name: 'Docker');
      },
      verify: (cubit) {
        expect(cubit.hasChanges, isTrue);
      },
      expect: () => const [
        SkillsLoading(),
        SkillsSuccess(skills: [_flutter]),
        SkillsSuccess(skills: [_docker, _flutter]),
      ],
    );
  });
}
