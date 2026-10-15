import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGenerateApiConsumer extends Fake implements ApiConsumer {
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
  }) async {
    if (postError != null) throw postError!;
    lastPostPath = path;
    lastPostData = data;
    return postResponse;
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
}

Map<String, dynamic> generatedPayload() => {
  'data': {
    'id': 9,
    'candidate_id': 1,
    'target_role': 'Backend Engineer',
    'title': 'Roadmap to Backend Mastery',
    'description': 'Strategic learning plan.',
    'status': 'in_progress',
    'completion_percentage': 0,
    'milestones': [],
    'created_at': '2026-10-14T22:33:10.503Z',
  },
};

void main() {
  late FakeGenerateApiConsumer fakeApiConsumer;
  late RoadmapRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    fakeApiConsumer = FakeGenerateApiConsumer();
    remoteDataSource = RoadmapRemoteDataSourceImpl(
      apiConsumer: fakeApiConsumer,
    );
  });

  group('RoadmapRemoteDataSource.generateRoadmap', () {
    test('posts to roadmaps and parses the 201 payload', () async {
      fakeApiConsumer.postResponse = generatedPayload();

      final roadmap = await remoteDataSource.generateRoadmap(
        const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
      );

      expect(fakeApiConsumer.lastPostPath, 'roadmaps');
      final data = fakeApiConsumer.lastPostData as Map<String, dynamic>;
      expect(data['target_type'], 'role');
      expect(data['target_role'], 'Backend Engineer');
      expect(data.containsKey('notes'), isFalse);
      expect(roadmap.id, 9);
      expect(roadmap.title, 'Roadmap to Backend Mastery');
    });

    test('throws FormatException for malformed envelopes', () async {
      fakeApiConsumer.postResponse = {'data': 'oops'};

      expect(
        () => remoteDataSource.generateRoadmap(
          const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
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
            'target_role': ['The target role field is required.'],
          },
        ),
      );

      try {
        await remoteDataSource.generateRoadmap(
          const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
        );
        fail('Expected ServerException');
      } on ServerException catch (e) {
        expect(e.errorModel.statusCode, 422);
        expect(e.errorModel.fieldErrors['target_role'], [
          'The target role field is required.',
        ]);
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
        await remoteDataSource.generateRoadmap(
          const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
        );
        fail('Expected ServerException');
      } on ServerException catch (e) {
        expect(e.errorModel.statusCode, 429);
        expect(e.errorModel.errorMessage, contains('Too many attempts'));
      }
    });
  });
}
