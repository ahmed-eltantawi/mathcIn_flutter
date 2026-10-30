import 'dart:typed_data';

import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source_impl.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:MatchIn/features/profile/domain/entities/avatar_upload_input.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingApiConsumer extends Fake implements ApiConsumer {
  int postCalls = 0;
  int patchCalls = 0;
  String? lastPostPath;
  Object? lastPostData;
  bool lastPostIsFormData = false;

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    postCalls++;
    lastPostPath = path;
    lastPostData = data;
    lastPostIsFormData = isFormData;
    return {'data': <String, dynamic>{'id': 1}};
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
  group('ProfileRepositoryImpl.uploadAvatar', () {
    test('sends the documented multipart avatar upload', () async {
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

      expect(result.isRight(), isTrue);
      expect(apiConsumer.postCalls, 1);
      expect(apiConsumer.patchCalls, 0);
      expect(apiConsumer.lastPostPath, 'candidate/profile/avatar');
      expect(apiConsumer.lastPostIsFormData, isTrue);
      expect(apiConsumer.lastPostData, isA<Map<String, dynamic>>());
      final payload = apiConsumer.lastPostData! as Map<String, dynamic>;
      expect(payload.keys, contains('avatar'));
      expect(payload['avatar'], isA<MultipartFile>());
      expect(local.cacheWrites, 0);
    });
  });
}
