import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/profile_user_model.dart';
import 'package:MatchIn/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';
import 'package:flutter_test/flutter_test.dart';

class _OnlineNetworkInfo extends Fake implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _ThrowingRemote extends Fake implements ProfileRemoteDataSource {
  @override
  Future<CandidateProfileModel> getCandidateProfile() {
    throw ServerException(
      errorModel: const ErrorModel(
        statusCode: 422,
        errorMessage: 'The given data was invalid.',
        fieldErrors: {
          'job_title': ['The job title field is required.'],
        },
      ),
    );
  }

  @override
  Future<CandidateProfileModel> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  ) {
    throw ServerException(
      errorModel: const ErrorModel(
        statusCode: 422,
        errorMessage: 'The given data was invalid.',
        fieldErrors: {
          'date_of_birth': ['The date of birth is not a valid date.'],
        },
      ),
    );
  }
}

class _EmptyLocal extends Fake implements ProfileLocalDataSource {
  @override
  Future<CandidateProfileModel?> getCachedCandidateProfile() async => null;

  @override
  Future<void> cacheCandidateProfile(CandidateProfileModel profile) async {}
}

CandidateProfileModel _createdProfile() => const CandidateProfileModel(
  profileExists: true,
  user: ProfileUserModel(
    id: 7,
    name: 'New Candidate',
    email: 'new@example.com',
    role: 'candidate',
    isActive: true,
  ),
);

void main() {
  late ProfileRepositoryImpl repository;

  setUp(() {
    repository = ProfileRepositoryImpl(
      remoteDataSource: _ThrowingRemote(),
      localDataSource: _EmptyLocal(),
      networkInfo: _OnlineNetworkInfo(),
    );
  });

  group('ProfileRepositoryImpl 422 fieldErrors (profile creation)', () {
    test('updateCandidateProfile preserves fieldErrors', () async {
      final result = await repository.updateCandidateProfile(
        const UpdateCandidateProfileParams().copyWith(jobTitle: 'x'),
      );

      expect(result.isLeft(), isTrue);
      final failure = result.fold(
        (failure) => failure,
        (_) => throw StateError('expected failure'),
      );
      expect(failure, isA<ServerFailure>());
      expect(
        (failure as ServerFailure).fieldErrors,
        containsPair('date_of_birth', [
          'The date of birth is not a valid date.',
        ]),
      );
    });

    test('getCandidateProfileForEdit preserves fieldErrors', () async {
      final result = await repository.getCandidateProfileForEdit();

      expect(result.isLeft(), isTrue);
      final failure = result.fold(
        (failure) => failure,
        (_) => throw StateError('expected failure'),
      );
      expect(failure, isA<ServerFailure>());
      expect(
        (failure as ServerFailure).fieldErrors,
        containsPair('job_title', ['The job title field is required.']),
      );
    });

    test('sanity: created profile carries profile_exists=true', () {
      expect(_createdProfile().profileExists, isTrue);
    });
  });
}
