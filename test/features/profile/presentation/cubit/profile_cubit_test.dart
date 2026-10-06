import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/user_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProfileRepository implements ProfileRepository {
  Either<Failure, UserProfileEntity>? result;

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    return result!;
  }
}

UserProfileEntity _makeProfile() => const UserProfileEntity(
  id: 1,
  name: 'Amira Sultan',
  email: 'amira@example.com',
  jobTitle: 'Flutter Developer',
  location: 'Mansoura, Egypt',
);

void main() {
  late FakeProfileRepository repo;

  setUp(() {
    repo = FakeProfileRepository();
  });

  group('ProfileCubit', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when getUserProfile succeeds',
      build: () {
        repo.result = Right(_makeProfile());
        return ProfileCubit(getUserProfileUseCase: GetUserProfileUseCase(repo));
      },
      act: (cubit) => cubit.fetchUserProfile(),
      expect: () => [
        ProfileLoading(),
        ProfileLoaded(userProfile: _makeProfile()),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] when getUserProfile fails',
      build: () {
        repo.result = const Left(
          ServerFailure(message: 'Profile fetch failed'),
        );
        return ProfileCubit(getUserProfileUseCase: GetUserProfileUseCase(repo));
      },
      act: (cubit) => cubit.fetchUserProfile(),
      expect: () => [
        ProfileLoading(),
        const ProfileError('Profile fetch failed'),
      ],
    );
  });
}
