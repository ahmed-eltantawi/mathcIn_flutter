import 'dart:typed_data';

import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/avatar_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_for_edit_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/upload_avatar_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/edit_profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/edit_profile_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeEditProfileRepository extends Fake implements ProfileRepository {
  Either<Failure, CandidateProfileEntity>? loadResult;
  Either<Failure, CandidateProfileEntity>? updateResult;
  UpdateCandidateProfileParams? lastParams;
  Either<Failure, Unit>? avatarResult;
  int avatarCalls = 0;

  @override
  Future<Either<Failure, CandidateProfileEntity>>
  getCandidateProfileForEdit() async {
    return loadResult!;
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  ) async {
    lastParams = params;
    return updateResult!;
  }

  @override
  Future<Either<Failure, Unit>> uploadAvatar(AvatarUploadInput input) async {
    avatarCalls++;
    return avatarResult ??
        const Left(
          ServerFailure(message: 'Avatar upload is not available yet.'),
        );
  }
}

CandidateProfileEntity makeProfile({String jobTitle = 'Junior Developer'}) =>
    CandidateProfileEntity(
      profileExists: true,
      user: const ProfileUserEntity(
        id: 1,
        name: 'Ahmed Mohamed',
        email: 'ahmed@example.com',
        role: 'candidate',
        isActive: true,
      ),
      profile: CandidateProfileDetailsEntity(
        id: 3,
        jobTitle: jobTitle,
        country: 'Egypt',
        city: 'Cairo',
      ),
    );

EditProfileCubit buildCubit(FakeEditProfileRepository repo) => EditProfileCubit(
  getCandidateProfileForEditUseCase: GetCandidateProfileForEditUseCase(repo),
  updateCandidateProfileUseCase: UpdateCandidateProfileUseCase(repo),
  uploadAvatarUseCase: UploadAvatarUseCase(repository: repo),
);

void main() {
  late FakeEditProfileRepository repo;

  setUp(() {
    repo = FakeEditProfileRepository();
  });

  group('EditProfileCubit load', () {
    blocTest<EditProfileCubit, EditProfileState>(
      'emits [Loading, Ready] when remote load succeeds',
      build: () {
        repo.loadResult = Right(makeProfile());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        const EditProfileLoading(),
        EditProfileReady(makeProfile()),
      ],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'emits [Loading, LoadFailure] when offline',
      build: () {
        repo.loadResult = const Left(OfflineFailure());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => const [
        EditProfileLoading(),
        EditProfileLoadFailure('You are offline'),
      ],
    );
  });

  group('EditProfileCubit save', () {
    blocTest<EditProfileCubit, EditProfileState>(
      'emits [Saving, Success] on successful PATCH',
      build: () {
        repo.updateResult = Right(makeProfile(jobTitle: 'Senior Developer'));
        return buildCubit(repo);
      },
      seed: () => EditProfileReady(makeProfile()),
      act: (cubit) => cubit.updateProfile(
        const UpdateCandidateProfileParams().copyWith(
          jobTitle: 'Senior Developer',
        ),
      ),
      expect: () => [
        EditProfileSaving(makeProfile()),
        EditProfileSuccess(makeProfile(jobTitle: 'Senior Developer')),
      ],
      verify: (_) {
        expect(repo.lastParams?.hasChanges, isTrue);
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'emits [Saving, ActionFailure] with baseline preserved on save failure',
      build: () {
        repo.updateResult = const Left(
          ServerFailure(message: 'Validation failed'),
        );
        return buildCubit(repo);
      },
      seed: () => EditProfileReady(makeProfile()),
      act: (cubit) => cubit.updateProfile(
        const UpdateCandidateProfileParams().copyWith(
          jobTitle: 'Senior Developer',
        ),
      ),
      expect: () => [
        EditProfileSaving(makeProfile()),
        EditProfileActionFailure('Validation failed', profile: makeProfile()),
      ],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'allows retry after action failure without losing baseline',
      build: () {
        repo.updateResult = Right(makeProfile(jobTitle: 'Senior Developer'));
        return buildCubit(repo);
      },
      seed: () =>
          EditProfileActionFailure('Validation failed', profile: makeProfile()),
      act: (cubit) => cubit.updateProfile(
        const UpdateCandidateProfileParams().copyWith(
          jobTitle: 'Senior Developer',
        ),
      ),
      expect: () => [
        EditProfileSaving(makeProfile()),
        EditProfileSuccess(makeProfile(jobTitle: 'Senior Developer')),
      ],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'does nothing when saving without a loaded baseline',
      build: () => buildCubit(repo),
      act: (cubit) => cubit.updateProfile(
        const UpdateCandidateProfileParams().copyWith(
          jobTitle: 'Senior Developer',
        ),
      ),
      expect: () => isEmpty,
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'does nothing when params carry no changes (empty PATCH prevention)',
      build: () => buildCubit(repo),
      seed: () => EditProfileReady(makeProfile()),
      act: (cubit) => cubit.updateProfile(const UpdateCandidateProfileParams()),
      expect: () => isEmpty,
      verify: (_) {
        expect(repo.lastParams, isNull);
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'ignores a second save while already saving',
      build: () {
        repo.updateResult = Right(makeProfile(jobTitle: 'Senior Developer'));
        return buildCubit(repo);
      },
      seed: () => EditProfileSaving(makeProfile()),
      act: (cubit) => cubit.updateProfile(
        const UpdateCandidateProfileParams().copyWith(
          jobTitle: 'Senior Developer',
        ),
      ),
      expect: () => isEmpty,
    );
  });

  group('EditProfileCubit avatar staging', () {
    final avatarBytes = Uint8List.fromList([1, 2, 3]);

    blocTest<EditProfileCubit, EditProfileState>(
      'emits Staged with preview bytes on stageAvatar',
      build: () => buildCubit(repo),
      seed: () => EditProfileReady(makeProfile()),
      act: (cubit) =>
          cubit.stageAvatar(avatarBytes: avatarBytes, fileName: 'photo.jpg'),
      expect: () => [
        EditProfileAvatarStaged(
          makeProfile(),
          avatarBytes: avatarBytes,
          fileName: 'photo.jpg',
        ),
      ],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'ignores empty avatar bytes',
      build: () => buildCubit(repo),
      seed: () => EditProfileReady(makeProfile()),
      act: (cubit) =>
          cubit.stageAvatar(avatarBytes: Uint8List(0), fileName: 'photo.jpg'),
      expect: () => isEmpty,
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'does nothing without a loaded baseline',
      build: () => buildCubit(repo),
      act: (cubit) =>
          cubit.stageAvatar(avatarBytes: avatarBytes, fileName: 'photo.jpg'),
      expect: () => isEmpty,
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'clearStagedAvatar returns to Ready with baseline preserved',
      build: () => buildCubit(repo),
      seed: () => EditProfileAvatarStaged(
        makeProfile(),
        avatarBytes: avatarBytes,
        fileName: 'photo.jpg',
      ),
      act: (cubit) => cubit.clearStagedAvatar(),
      expect: () => [EditProfileReady(makeProfile())],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'clearStagedAvatar does nothing when nothing is staged',
      build: () => buildCubit(repo),
      seed: () => EditProfileReady(makeProfile()),
      act: (cubit) => cubit.clearStagedAvatar(),
      expect: () => isEmpty,
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'confirm emits pending failure without fake success',
      build: () => buildCubit(repo),
      seed: () => EditProfileAvatarStaged(
        makeProfile(),
        avatarBytes: avatarBytes,
        fileName: 'photo.jpg',
      ),
      act: (cubit) => cubit.confirmAvatarUpload(),
      expect: () => [
        EditProfileActionFailure(
          'Avatar upload is not available yet.',
          profile: makeProfile(),
        ),
      ],
      verify: (_) {
        expect(repo.avatarCalls, 1);
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'confirm does nothing when nothing is staged',
      build: () => buildCubit(repo),
      seed: () => EditProfileReady(makeProfile()),
      act: (cubit) => cubit.confirmAvatarUpload(),
      expect: () => isEmpty,
      verify: (_) {
        expect(repo.avatarCalls, 0);
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'updateProfile works from a staged baseline',
      build: () {
        repo.updateResult = Right(makeProfile(jobTitle: 'Senior Developer'));
        return buildCubit(repo);
      },
      seed: () => EditProfileAvatarStaged(
        makeProfile(),
        avatarBytes: avatarBytes,
        fileName: 'photo.jpg',
      ),
      act: (cubit) => cubit.updateProfile(
        const UpdateCandidateProfileParams().copyWith(
          jobTitle: 'Senior Developer',
        ),
      ),
      expect: () => [
        EditProfileSaving(makeProfile()),
        EditProfileSuccess(makeProfile(jobTitle: 'Senior Developer')),
      ],
    );
  });
}
