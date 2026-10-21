import 'dart:typed_data';

import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source_impl.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:MatchIn/features/profile/domain/entities/avatar_upload_input.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingApiConsumer extends Fake implements ApiConsumer {
  int postCalls = 0;
  int patchCalls = 0;

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    postCalls++;
    throw UnimplementedError();
  }

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    patchCalls++;
    throw UnimplementedError();
  }
}

class _OnlineNetworkInfo extends Fake implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _EmptyLocal extends Fake implements ProfileLocalDataSource {
  int cacheWrites = 0;

  @override
  Future<CandidateProfileModel?> getCachedCandidateProfile() async => null;

  @override
  Future<void> cacheCandidateProfile(CandidateProfileModel profile) async {
    cacheWrites++;
  }
}

void main() {
  group('ProfileRepositoryImpl.uploadAvatar (backend pending)', () {
    test('reports pending failure without network requests', () async {
      final apiConsumer = _RecordingApiConsumer();
      final local = _EmptyLocal();
      final repository = ProfileRepositoryImpl(
        remoteDataSource: ProfileRemoteDataSourceImpl(apiConsumer: apiConsumer),
        localDataSource: local,
        networkInfo: _OnlineNetworkInfo(),
      );

      final result = await repository.uploadAvatar(
        AvatarUploadInput(
          fileName: 'photo.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.fold((failure) => failure, (_) => null),
        isA<ServerFailure>(),
      );
      expect(
        result.fold((failure) => failure.message, (_) => ''),
        'Avatar upload is not available yet.',
      );
      expect(apiConsumer.postCalls, 0);
      expect(apiConsumer.patchCalls, 0);
      expect(local.cacheWrites, 0);
    });
  });
}
