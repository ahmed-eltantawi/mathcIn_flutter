import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source_impl.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_milestone_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_pagination_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_cached_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/refresh_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/sync_roadmap_ops_use_case.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCachedRemote extends Fake implements RoadmapRemoteDataSource {
  List<RoadmapModel>? listRoadmaps;
  RoadmapModel? detailsResponse;
  Object? detailsError;
  int completeCalls = 0;
  RoadmapTaskModel? completeResponse;
  Object? completeError;

  @override
  Future<({List<RoadmapModel> roadmaps, RoadmapPaginationModel pagination})>
  getRoadmaps({RoadmapsParams? params}) async {
    return (
      roadmaps: listRoadmaps!,
      pagination: const RoadmapPaginationModel(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 1,
      ),
    );
  }

  @override
  Future<RoadmapModel> getRoadmapDetails(int roadmapId) async {
    if (detailsError != null) throw detailsError!;
    return detailsResponse!;
  }

  @override
  Future<RoadmapTaskModel> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
    if (completeError != null) throw completeError!;
    return completeResponse!;
  }
}

class FakeCachedNetwork extends Fake implements NetworkInfo {
  FakeCachedNetwork({this.connected = true});

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

RoadmapModel cachedDetails() => const RoadmapModel(
  id: 1,
  title: 'Cached Architect',
  milestones: [
    RoadmapMilestoneModel(
      id: 1,
      title: 'Cached phase',
      order: 1,
      tasks: [RoadmapTaskModel(id: 7, title: 'Cached lab')],
    ),
  ],
);

RoadmapModel freshDetails() => const RoadmapModel(
  id: 1,
  title: 'Fresh Architect',
  milestones: [
    RoadmapMilestoneModel(
      id: 1,
      title: 'Fresh phase',
      order: 1,
      tasks: [
        RoadmapTaskModel(
          id: 7,
          title: 'Fresh lab',
          isCompleted: true,
          completedAt: '2026-10-15T08:04:37.117Z',
        ),
      ],
    ),
  ],
);

/// Lets queued broadcast deliveries reach stream listeners: cancelling a
/// subscription immediately after the last emit can otherwise drop the
/// tail event (production widgets stay subscribed, so only tests need this).
Future<void> flushStreamEvents() => Future<void>.delayed(Duration.zero);

Future<RoadmapCubit> buildCubit({
  required FakeCachedRemote remote,
  required FakeCachedNetwork network,
  required RoadmapLocalDataSource local,
  required SharedPreferencesService prefs,
}) async {
  final repository = RoadmapRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
    networkInfo: network,
  );
  return RoadmapCubit(
    sharedPreferencesService: prefs,
    getRoadmapsUseCase: GetRoadmapsUseCase(repository: repository),
    getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(repository: repository),
    generateRoadmapUseCase: GenerateRoadmapUseCase(repository: repository),
    refreshRoadmapUseCase: RefreshRoadmapUseCase(repository: repository),
    getCachedRoadmapUseCase: GetCachedRoadmapUseCase(repository: repository),
    syncRoadmapOpsUseCase: SyncRoadmapOpsUseCase(repository: repository),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCachedRemote remote;
  late FakeCachedNetwork network;
  late RoadmapLocalDataSource local;
  late SharedPreferencesService prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final helper = SharedPreferencesHelper(preferences: sp);
    prefs = SharedPreferencesService(helper);
    local = RoadmapLocalDataSourceImpl(sharedPreferencesHelper: helper);
    remote = FakeCachedRemote();
    network = FakeCachedNetwork();
  });

  group('RoadmapCubit cached-first flow', () {
    test('offline details render from cache without a loading state', () async {
      await local.cacheRoadmapDetails(cachedDetails());
      network.connected = false;
      final cubit = await buildCubit(
        remote: remote,
        network: network,
        local: local,
        prefs: prefs,
      );
      addTearDown(cubit.close);

      final emitted = <RoadmapState>[];
      final sub = cubit.stream.listen(emitted.add);
      await cubit.loadRoadmapDetails(1);
      await flushStreamEvents();
      await sub.cancel();

      expect(emitted, isNotEmpty);
      expect(emitted.first, isA<RoadmapDetailsSuccess>());
      expect(emitted.whereType<RoadmapLoading>(), isEmpty);
      final shown = emitted.first as RoadmapDetailsSuccess;
      expect(shown.details.title, 'Cached Architect');
      expect(shown.isOffline, isTrue);
    });

    test('online details paint cache first, then refresh silently', () async {
      await local.cacheRoadmapDetails(cachedDetails());
      remote.detailsResponse = freshDetails();
      final cubit = await buildCubit(
        remote: remote,
        network: network,
        local: local,
        prefs: prefs,
      );
      addTearDown(cubit.close);

      final emitted = <RoadmapState>[];
      final sub = cubit.stream.listen(emitted.add);
      await cubit.loadRoadmapDetails(1);
      await flushStreamEvents();
      await sub.cancel();

      final successes = emitted.whereType<RoadmapDetailsSuccess>().toList();
      expect(successes.length, 2);
      expect(successes[0].details.title, 'Cached Architect');
      expect(successes[1].details.title, 'Fresh Architect');
      expect(emitted.whereType<RoadmapLoading>(), isEmpty);
    });

    test('loadRoadmaps never flashes loading over cached content', () async {
      await local.cacheRoadmaps([cachedDetails()]);
      await local.cacheRoadmapDetails(cachedDetails());
      remote.listRoadmaps = [cachedDetails()];
      remote.detailsResponse = freshDetails();
      final cubit = await buildCubit(
        remote: remote,
        network: network,
        local: local,
        prefs: prefs,
      );
      addTearDown(cubit.close);

      final emitted = <RoadmapState>[];
      final sub = cubit.stream.listen(emitted.add);
      await cubit.loadRoadmaps();
      await sub.cancel();

      expect(emitted.whereType<RoadmapsLoading>(), isEmpty);
      expect(emitted.whereType<RoadmapLoading>(), isEmpty);
      expect(emitted.last, isA<RoadmapDetailsSuccess>());
      expect(
        (emitted.last as RoadmapDetailsSuccess).details.title,
        'Fresh Architect',
      );
    });

    test('syncPending replays the queued offline completion', () async {
      await local.cacheRoadmapDetails(cachedDetails());
      network.connected = false;
      final repository = RoadmapRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: network,
      );
      await repository.completeTaskOfflineFirst(
        roadmapId: 1,
        params: const CompleteRoadmapTaskParams(taskId: 7),
      );

      network.connected = true;
      remote.completeResponse = const RoadmapTaskModel(
        id: 7,
        title: 'Fresh lab',
        isCompleted: true,
        completedAt: '2026-10-15T08:04:37.117Z',
      );
      remote.detailsResponse = freshDetails();
      remote.listRoadmaps = [cachedDetails()];
      final cubit = await buildCubit(
        remote: remote,
        network: network,
        local: local,
        prefs: prefs,
      );
      addTearDown(cubit.close);
      await cubit.loadRoadmaps();

      final synced = await cubit.syncPending();

      expect(synced, isTrue);
      expect(remote.completeCalls, 1);
      expect(cubit.state, isA<RoadmapDetailsSuccess>());
      expect(await repository.getPendingOps(), isEmpty);
    });
  });
}
