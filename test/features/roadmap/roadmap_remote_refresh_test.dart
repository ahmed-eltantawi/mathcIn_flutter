import 'dart:typed_data';

import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRefreshApiConsumer extends Fake implements ApiConsumer {
  dynamic postResponse;
  Object? postError;
  String? lastPostPath;
  Object? lastPostData;

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    if (postError != null) throw postError!;
    lastPostPath = path;
    lastPostData = data;
    return postResponse;
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<({Uint8List bytes, String? fileName, String? mimeType})> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    throw UnimplementedError();
  }
}

Map<String, dynamic> refreshedRoadmapPayload() => {
  'data': {
    'id': 1,
    'candidate_id': 1,
    'target_role': 'Backend Engineer',
    'title': 'Updated Backend Roadmap',
    'description': 'Updated learning roadmap',
    'status': 'in_progress',
    'completion_percentage': 35,
    'milestones': [
      {
        'id': 1,
        'roadmap_id': 1,
        'title': 'Backend Fundamentals',
        'order': 1,
        'tasks': [
          {
            'id': 1,
            'title': 'Complete backend task',
            'description': 'Task description',
            'estimated_hours': 5,
            'is_completed': false,
            'completed_at': null,
          },
        ],
      },
    ],
  },
};

void main() {
  late FakeRefreshApiConsumer fakeApiConsumer;
  late RoadmapRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    fakeApiConsumer = FakeRefreshApiConsumer();
    remoteDataSource = RoadmapRemoteDataSourceImpl(
      apiConsumer: fakeApiConsumer,
    );
  });

  group('RoadmapRemoteDataSource.refreshRoadmap', () {
    test('posts to the roadmap refresh path and parses 200', () async {
      fakeApiConsumer.postResponse = refreshedRoadmapPayload();

      final roadmap = await remoteDataSource.refreshRoadmap(
        const RefreshRoadmapParams(roadmapId: 1),
      );

      expect(fakeApiConsumer.lastPostPath, 'roadmaps/1/refresh');
      final data = fakeApiConsumer.lastPostData as Map<String, dynamic>;
      expect(data.containsKey('reason'), isFalse);
      expect(roadmap.id, 1);
      expect(roadmap.title, 'Updated Backend Roadmap');
      expect(roadmap.completionPercentage, 35);
      expect(roadmap.milestones, hasLength(1));
      expect(roadmap.milestones.first.tasks, hasLength(1));
    });

    test('sends a trimmed reason when provided', () async {
      fakeApiConsumer.postResponse = refreshedRoadmapPayload();

      await remoteDataSource.refreshRoadmap(
        const RefreshRoadmapParams(
          roadmapId: 1,
          reason: '  Focus more on backend skills  ',
        ),
      );

      final data = fakeApiConsumer.lastPostData as Map<String, dynamic>;
      expect(data['reason'], 'Focus more on backend skills');
    });

    test('omits blank reasons', () async {
      fakeApiConsumer.postResponse = refreshedRoadmapPayload();

      await remoteDataSource.refreshRoadmap(
        const RefreshRoadmapParams(roadmapId: 1, reason: '   '),
      );

      final data = fakeApiConsumer.lastPostData as Map<String, dynamic>;
      expect(data.containsKey('reason'), isFalse);
    });

    test('throws FormatException for malformed envelopes', () async {
      fakeApiConsumer.postResponse = {'data': 'oops'};

      expect(
        () => remoteDataSource.refreshRoadmap(
          const RefreshRoadmapParams(roadmapId: 1),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('propagates 422 field errors', () async {
      fakeApiConsumer.postError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 422,
          errorMessage: 'The given data was invalid.',
          fieldErrors: {
            'reason': ['The reason is too long.'],
          },
        ),
      );

      try {
        await remoteDataSource.refreshRoadmap(
          const RefreshRoadmapParams(roadmapId: 1),
        );
        fail('Expected ServerException');
      } on ServerException catch (e) {
        expect(e.errorModel.statusCode, 422);
        expect(e.errorModel.fieldErrors['reason'], ['The reason is too long.']);
      }
    });

    test('propagates 429 rate-limit message', () async {
      fakeApiConsumer.postError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 429,
          errorMessage: 'Too many attempts. Please try again later.',
        ),
      );

      try {
        await remoteDataSource.refreshRoadmap(
          const RefreshRoadmapParams(roadmapId: 1),
        );
        fail('Expected ServerException');
      } on ServerException catch (e) {
        expect(e.errorModel.statusCode, 429);
        expect(e.errorModel.errorMessage, contains('Too many attempts'));
      }
    });
  });
}
