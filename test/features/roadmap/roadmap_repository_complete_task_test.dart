import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCompleteRemoteDataSource extends Fake
    implements RoadmapRemoteDataSource {
  RoadmapTaskModel? response;
  Object? error;
  CompleteRoadmapTaskParams? lastParams;

  @override
  Future<RoadmapTaskModel> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    lastParams = params;
    if (error != null) throw error!;
    return response!;
  }
}

class FakeNetworkInfo extends Fake implements NetworkInfo {
  FakeNetworkInfo({this.connected = true});

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  late FakeCompleteRemoteDataSource fakeRemote;
  late FakeNetworkInfo fakeNetworkInfo;
  late RoadmapRepositoryImpl repository;

  setUp(() {
    fakeRemote = FakeCompleteRemoteDataSource();
    fakeNetworkInfo = FakeNetworkInfo();
    repository = RoadmapRepositoryImpl(
      remoteDataSource: fakeRemote,
      networkInfo: fakeNetworkInfo,
    );
  });

  group('RoadmapRepositoryImpl.completeRoadmapTask', () {
    const params = CompleteRoadmapTaskParams(taskId: 7);

    test('returns the completed task on success', () async {
      fakeRemote.response = const RoadmapTaskModel(
        id: 7,
        title: 'Complete Docker lab',
        isCompleted: true,
        completedAt: '2026-10-14T22:33:10.515Z',
      );

      final result = await repository.completeRoadmapTask(params);

      expect(result.isRight(), isTrue);
      final task = (result as Right).value;
      expect(task.id, 7);
      expect(task.isCompleted, isTrue);
      expect(fakeRemote.lastParams, params);
    });

    test('returns OfflineFailure without a request when offline', () async {
      fakeNetworkInfo.connected = false;

      final result = await repository.completeRoadmapTask(params);

      expect(result.isLeft(), isTrue);
      expect((result as Left).value, isA<OfflineFailure>());
      expect(fakeRemote.lastParams, isNull);
    });

    test('maps 422 to ServerFailure with field errors', () async {
      fakeRemote.error = ServerException(
        errorModel: const ErrorModel(
          statusCode: 422,
          errorMessage: 'The given data was invalid.',
          fieldErrors: {
            'completion_note': ['The completion note is too long.'],
          },
        ),
      );

      final result = await repository.completeRoadmapTask(params);

      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value as ServerFailure;
      expect(failure.message, 'The given data was invalid.');
      expect(failure.fieldErrors['completion_note'], [
        'The completion note is too long.',
      ]);
    });
  });
}
