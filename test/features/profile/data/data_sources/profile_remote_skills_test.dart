import 'dart:typed_data';

import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source_impl.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingApiConsumer implements ApiConsumer {
  Object? postData;
  Object? postResponse;

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    expect(path, 'candidate/skills');
    postData = data;
    return postResponse;
  }

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async => throw UnimplementedError();

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async => throw UnimplementedError();

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async => throw UnimplementedError();

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async => throw UnimplementedError();

  @override
  Future<({Uint8List bytes, String? fileName, String? mimeType})> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async => throw UnimplementedError();
}

void main() {
  test('adds skill name with the contract fields and parses the response', () async {
    final apiConsumer = _RecordingApiConsumer()
      ..postResponse = {
        'data': {
          'id': 91,
          'skill_id': 2,
          'proficiency_level': 'intermediate',
          'skill': {'id': 2, 'name': 'Backend'},
        },
      };
    final dataSource = ProfileRemoteDataSourceImpl(apiConsumer: apiConsumer);

    final added = await dataSource.addCandidateSkill(
      const AddCandidateSkillParams(
        skillId: 2,
        name: '  Backend  ',
        proficiencyLevel: 'intermediate',
      ),
    );

    expect(apiConsumer.postData, {
      'name': 'Backend',
      'skill_id': 2,
      'proficiency_level': 'intermediate',
    });
    expect(added.id, 91);
    expect(added.skillId, 2);
    expect(added.name, 'Backend');
  });
}
