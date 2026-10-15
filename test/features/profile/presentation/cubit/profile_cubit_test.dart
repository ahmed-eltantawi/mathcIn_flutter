import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/profile_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';

import 'package:flutter_test/flutter_test.dart';

class FakeProfileRepository extends Fake
    implements ProfileRepository {
  Either<Failure, CandidateProfileEntity>?
  candidateProfileResult;
  Either<Failure, CandidateProfileEntity?>? cachedProfileResult;

  @override
  Future<Either<Failure, CandidateProfileEntity>>
  getCandidateProfile() async {
    return candidateProfileResult!;
  }

  @override
  Future<Either<Failure, CandidateProfileEntity?>>
  getCachedCandidateProfile() async {
    return cachedProfileResult ?? const Right(null);
  }
}

CandidateProfileEntity _makeProfile() =>
    const CandidateProfileEntity(
      profileExists: true,
      user: ProfileUserEntity(
        id: 1,
        name: 'Amira Sultan',
        email: 'amira@example.com',
        role: 'candidate',
        isActive: true,
      ),
    );

ProfileCubit _buildCubit(FakeProfileRepository repo) =>
    ProfileCubit(
      getCandidateProfileUseCase:
          GetCandidateProfileUseCase(repository: repo),
      getCachedCandidateProfileUseCase:
          GetCachedCandidateProfileUseCase(
            repository: repo,
          ),
    );

void main() {
  late FakeProfileRepository repo;

  setUp(() {
    repo = FakeProfileRepository();
  });

  group('ProfileCubit', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileSuccess] on first fetch with empty cache',
      build: () {
        repo.candidateProfileResult = Right(_makeProfile());
        repo.cachedProfileResult = const Right(null);
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.getCandidateProfile(),
      expect: () => [
        const ProfileLoading(),
        ProfileSuccess(profile: _makeProfile()),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits cached first then fresh on refresh with cache available',
      build: () {
        repo.candidateProfileResult = Right(_makeProfile());
        repo.cachedProfileResult = Right(_makeProfile());
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.getCandidateProfile(),
      expect: () => [
        ProfileSuccess(profile: _makeProfile(), isRefreshing: true),
        ProfileSuccess(profile: _makeProfile()),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'preserves cache when remote refresh fails',
      build: () {
        repo.candidateProfileResult = const Left(
          ServerFailure(message: 'Profile fetch failed'),
        );
        repo.cachedProfileResult = Right(_makeProfile());
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.getCandidateProfile(),
      expect: () => [
        ProfileSuccess(profile: _makeProfile(), isRefreshing: true),
        ProfileSuccess(profile: _makeProfile()),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileFailure] when no cache and remote fails',
      build: () {
        repo.candidateProfileResult = const Left(
          ServerFailure(message: 'Profile fetch failed'),
        );
        repo.cachedProfileResult = const Right(null);
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.getCandidateProfile(),
      expect: () => [
        const ProfileLoading(),
        const ProfileFailure(
          message: 'Profile fetch failed',
        ),
      ],
    );
  });
}
