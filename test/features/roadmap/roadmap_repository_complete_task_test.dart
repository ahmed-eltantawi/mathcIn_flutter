import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source_impl.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCompleteRemoteDataSource fakeRemote;
  late FakeNetworkInfo fakeNetworkInfo;
  late RoadmapLocalDataSource fakeLocal;
  late RoadmapRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    fakeRemote = FakeCompleteRemoteDataSource();
    fakeNetworkInfo = FakeNetworkInfo();
    fakeLocal = RoadmapLocalDataSourceImpl(
      sharedPreferencesHelper: SharedPreferencesHelper(preferences: prefs),
    );
    repository = RoadmapRepositoryImpl(
      remoteDataSource: fakeRemote,
      localDataSource: fakeLocal,
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

    test('queues offline and returns cached projection when known', () async {
      fakeNetworkInfo.connected = false;

      final result = await repository.completeRoadmapTask(params);

      // No roadmapId targets no cached roadmap: the op is still queued
      // durably and reported as offline (never a false success).
      expect(result.isLeft(), isTrue);
      expect((result as Left).value, isA<OfflineFailure>());
      expect(fakeRemote.lastParams, isNull);
      final pending = await repository.getPendingOps();
      expect(pending.map((op) => op.opKey), contains('complete_7'));
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
