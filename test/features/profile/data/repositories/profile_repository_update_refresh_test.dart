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

class _ProfileRemote extends Fake implements ProfileRemoteDataSource {
  _ProfileRemote({required this.patchResult, this.getError});

  final CandidateProfileModel patchResult;
  final Object? getError;
  int getCalls = 0;

  @override
  Future<CandidateProfileModel> updateCandidateProfile(
    UpdateCandidateProfileParams params,
  ) async => patchResult;

  @override
  Future<CandidateProfileModel> getCandidateProfile() async {
    getCalls++;
    if (getError case final error?) throw error;
    return _completeProfile;
  }
}

class _ProfileLocal extends Fake implements ProfileLocalDataSource {
  CandidateProfileModel? cached;

  @override
  Future<void> cacheCandidateProfile(CandidateProfileModel profile) async {
    cached = profile;
  }
}

CandidateProfileModel makeProfile(String name) => CandidateProfileModel(
  profileExists: true,
  user: ProfileUserModel(
    id: 1,
    name: name,
    email: 'candidate@example.com',
    role: 'candidate',
    isActive: true,
  ),
);

final _completeProfile = makeProfile('Updated Candidate');

void main() {
  group('updateCandidateProfile canonical refresh', () {
    test('returns and caches the full GET profile after PATCH', () async {
      final remote = _ProfileRemote(patchResult: makeProfile('Partial'));
      final local = _ProfileLocal();
      final repository = ProfileRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: _OnlineNetworkInfo(),
      );

      final result = await repository.updateCandidateProfile(
        const UpdateCandidateProfileParams().copyWith(
          fullName: 'Updated Candidate',
        ),
      );

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => throw StateError('expected success')).user.name,
        'Updated Candidate',
      );
      expect(local.cached?.user.name, 'Updated Candidate');
      expect(remote.getCalls, 1);
    });

    test(
      'keeps a successful PATCH successful when canonical refresh fails',
      () async {
        final remote = _ProfileRemote(
          patchResult: makeProfile('Patch Result'),
          getError: StateError('refresh unavailable'),
        );
        final local = _ProfileLocal();
        final repository = ProfileRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: local,
          networkInfo: _OnlineNetworkInfo(),
        );

        final result = await repository.updateCandidateProfile(
          const UpdateCandidateProfileParams().copyWith(
            fullName: 'Patch Result',
          ),
        );

        expect(result.isRight(), isTrue);
        expect(local.cached, isNull);
        expect(remote.getCalls, 1);
      },
    );
  });
}
