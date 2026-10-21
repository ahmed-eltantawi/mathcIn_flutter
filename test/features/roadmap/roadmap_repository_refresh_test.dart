import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source_impl.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRefreshRemoteDataSource extends Fake
    implements RoadmapRemoteDataSource {
  RoadmapModel? response;
  Object? error;
  RefreshRoadmapParams? lastParams;

  @override
  Future<RoadmapModel> refreshRoadmap(RefreshRoadmapParams params) async {
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

  late FakeRefreshRemoteDataSource fakeRemote;
  late FakeNetworkInfo fakeNetworkInfo;
  late RoadmapLocalDataSource fakeLocal;
  late RoadmapRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    fakeRemote = FakeRefreshRemoteDataSource();
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

  group('RoadmapRepositoryImpl.refreshRoadmap', () {
    const params = RefreshRoadmapParams(roadmapId: 1);

    test('returns the refreshed roadmap on success', () async {
      fakeRemote.response = const RoadmapModel(id: 1, title: 'Refreshed');

      final result = await repository.refreshRoadmap(params);

      expect(result.isRight(), isTrue);
      final roadmap = (result as Right).value;
      expect(roadmap.id, 1);
      expect(roadmap.title, 'Refreshed');
      expect(fakeRemote.lastParams, params);
    });

    test('returns OfflineFailure without a request when offline', () async {
      fakeNetworkInfo.connected = false;

      final result = await repository.refreshRoadmap(params);

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
            'reason': ['The reason is too long.'],
          },
        ),
      );

      final result = await repository.refreshRoadmap(params);

      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value as ServerFailure;
      expect(failure.message, 'The given data was invalid.');
      expect(failure.fieldErrors['reason'], ['The reason is too long.']);
    });
  });
}
