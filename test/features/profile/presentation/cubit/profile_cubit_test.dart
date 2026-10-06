import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProfileRepository extends Fake implements ProfileRepository {
  Either<Failure, CandidateProfileEntity>? candidateProfileResult;

  @override
  Future<Either<Failure, CandidateProfileEntity>> getCandidateProfile() async {
    return candidateProfileResult!;
  }

  @override
  Future<Either<Failure, CandidateProfileEntity?>>
  getCachedCandidateProfile() async {
    return Right(
      candidateProfileResult?.fold((_) => null, (profile) => profile),
    );
  }
}

CandidateProfileEntity _makeProfile() => const CandidateProfileEntity(
  profileExists: true,
  user: ProfileUserEntity(
    id: 1,
    name: 'Amira Sultan',
    email: 'amira@example.com',
    role: 'candidate',
    isActive: true,
  ),
);

ProfileCubit _buildCubit(FakeProfileRepository repo) => ProfileCubit(
  getCandidateProfileUseCase: GetCandidateProfileUseCase(repository: repo),
  getCachedCandidateProfileUseCase: GetCachedCandidateProfileUseCase(
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
      'emits [ProfileLoading, ProfileSuccess] when getCandidateProfile succeeds',
      build: () {
        repo.candidateProfileResult = Right(_makeProfile());
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.getCandidateProfile(),
      expect: () => [
        const ProfileLoading(),
        ProfileSuccess(profile: _makeProfile()),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileFailure] when getCandidateProfile fails',
      build: () {
        repo.candidateProfileResult = const Left(
          ServerFailure(message: 'Profile fetch failed'),
        );
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.getCandidateProfile(),
      expect: () => [
        const ProfileLoading(),
        const ProfileFailure(message: 'Profile fetch failed'),
      ],
    );
  });
}
