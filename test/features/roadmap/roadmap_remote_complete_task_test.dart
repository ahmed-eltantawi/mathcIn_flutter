import 'dart:typed_data';

import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCompleteApiConsumer extends Fake implements ApiConsumer {
  dynamic patchResponse;
  Object? patchError;
  String? lastPatchPath;
  Object? lastPatchData;

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    if (patchError != null) throw patchError!;
    lastPatchPath = path;
    lastPatchData = data;
    return patchResponse;
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
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
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

Map<String, dynamic> completedTaskPayload() => {
  'data': {
    'id': 7,
    'title': 'Complete Docker lab',
    'description': 'Containerize an application.',
    'estimated_hours': 6,
    'is_completed': true,
    'completed_at': '2026-10-14T22:33:10.515Z',
  },
};

void main() {
  late FakeCompleteApiConsumer fakeApiConsumer;
  late RoadmapRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    fakeApiConsumer = FakeCompleteApiConsumer();
    remoteDataSource = RoadmapRemoteDataSourceImpl(
      apiConsumer: fakeApiConsumer,
    );
  });

  group('RoadmapRemoteDataSource.completeRoadmapTask', () {
    test('patches the backend task id and parses the 200 payload', () async {
      fakeApiConsumer.patchResponse = completedTaskPayload();

      final task = await remoteDataSource.completeRoadmapTask(
        const CompleteRoadmapTaskParams(taskId: 7),
      );

      expect(fakeApiConsumer.lastPatchPath, 'roadmap-tasks/7/complete');
      final data = fakeApiConsumer.lastPatchData as Map<String, dynamic>;
      expect(data.containsKey('completion_note'), isFalse);
      expect(task.id, 7);
      expect(task.title, 'Complete Docker lab');
      expect(task.isCompleted, isTrue);
      expect(task.completedAt, '2026-10-14T22:33:10.515Z');
    });

    test('includes completion_note only when provided', () async {
      fakeApiConsumer.patchResponse = completedTaskPayload();

      await remoteDataSource.completeRoadmapTask(
        const CompleteRoadmapTaskParams(taskId: 7, completionNote: 'Done'),
      );

      final data = fakeApiConsumer.lastPatchData as Map<String, dynamic>;
      expect(data['completion_note'], 'Done');
    });

    test('throws FormatException for malformed envelopes', () async {
      fakeApiConsumer.patchResponse = {'data': 'oops'};

      expect(
        () => remoteDataSource.completeRoadmapTask(
          const CompleteRoadmapTaskParams(taskId: 7),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('propagates 422 field errors', () async {
      fakeApiConsumer.patchError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 422,
          errorMessage: 'The given data was invalid.',
          fieldErrors: {
            'completion_note': ['The completion note is too long.'],
          },
        ),
      );

      try {
        await remoteDataSource.completeRoadmapTask(
          const CompleteRoadmapTaskParams(taskId: 7),
        );
        fail('Expected ServerException');
      } on ServerException catch (e) {
        expect(e.errorModel.statusCode, 422);
        expect(e.errorModel.fieldErrors['completion_note'], [
          'The completion note is too long.',
        ]);
      }
    });
  });
}
