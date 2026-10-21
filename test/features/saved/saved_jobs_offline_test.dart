import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_cached_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/refresh_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/search_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_local_data_source.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_local_data_source_impl.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source.dart';
import 'package:MatchIn/features/saved/data/models/paginated_saved_jobs_model.dart';
import 'package:MatchIn/features/saved/data/models/save_job_toggle_model.dart';
import 'package:MatchIn/features/saved/data/models/saved_job_response_model.dart';
import 'package:MatchIn/features/saved/data/repositories/saved_jobs_repository_impl.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/domain/use_cases/get_saved_jobs_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/set_saved_job_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/set_unsaved_job_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/sync_saved_jobs_use_case.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_cubit.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSavedRemote extends Fake implements SavedJobsRemoteDataSource {
  PaginatedSavedJobsModel? listResponse;
  Object? listError;
  SaveJobToggleModel? saveResponse;
  Object? saveError;
  SaveJobToggleModel? unsaveResponse;
  Object? unsaveError;
  int saveCalls = 0;
  int unsaveCalls = 0;

  @override
  Future<PaginatedSavedJobsModel> getSavedJobs({
    int page = 1,
    int perPage = 15,
  }) async {
    if (listError != null) throw listError!;
    return listResponse!;
  }

  @override
  Future<SaveJobToggleModel> saveJob({required int jobPostId}) async {
    saveCalls++;
    if (saveError != null) throw saveError!;
    return saveResponse ?? SaveJobToggleModel(jobId: jobPostId, isSaved: true);
  }

  @override
  Future<SaveJobToggleModel> unsaveJob({required int jobPostId}) async {
    unsaveCalls++;
    if (unsaveError != null) throw unsaveError!;
    return unsaveResponse ??
        SaveJobToggleModel(jobId: jobPostId, isSaved: false);
  }
}

class FakeJobsRepo extends Fake implements JobsRepository {}

class FakeSavedNetwork extends Fake implements NetworkInfo {
  FakeSavedNetwork({this.connected = true});

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

SavedJobResponseModel savedJob(int id, {bool isSaved = true}) =>
    SavedJobResponseModel(
      id: id,
      title: 'Backend Engineer $id',
      company: 'NileTech',
      location: 'Cairo',
      workMode: 'remote',
      experience: 'senior',
      jobType: 'full-time',
      postedDate: '2026-10-11T08:29:29.682Z',
      skills: const ['Dart'],
      isSaved: isSaved,
    );

JobEntity feedJob(String id, {bool isSaved = false}) => JobEntity(
  id: id,
  title: 'Backend Engineer $id',
  companyName: 'NileTech',
  location: 'Cairo',
  workMode: 'remote',
  employmentType: 'full-time',
  experienceLevel: 'senior',
  postedDate: DateTime(2026, 10, 11),
  skills: const ['Dart'],
  matchedSkills: const [],
  missingSkills: const [],
  isSaved: isSaved,
);

Future<SavedJobsLocalDataSource> freshLocal() async {
  final prefs = await SharedPreferences.getInstance();
  return SavedJobsLocalDataSourceImpl(
    sharedPreferencesHelper: SharedPreferencesHelper(preferences: prefs),
  );
}

SavedJobsRepositoryImpl buildRepo(
  FakeSavedRemote remote,
  SavedJobsLocalDataSource local,
  FakeSavedNetwork network,
) => SavedJobsRepositoryImpl(
  remoteDataSource: remote,
  localDataSource: local,
  networkInfo: network,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSavedRemote remote;
  late FakeSavedNetwork network;
  late SavedJobsLocalDataSource local;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    remote = FakeSavedRemote();
    network = FakeSavedNetwork();
    local = await freshLocal();
  });

  group('Local-first save', () {
    test('persists + queues before network, survives restart', () async {
      final repo = buildRepo(remote, local, network);
      network.connected = false;

      final result = await repo.setSavedJob(savedJob(7));

      expect(result.isRight(), isTrue);
      expect(remote.saveCalls, 0);
      // Immediately readable from local truth.
      final jobs = await repo.getLocalSavedJobs();
      expect(jobs.map((job) => job.id), contains(7));
      // Durable across restarts.
      final restarted = await freshLocal();
      final ops = await restarted.getPendingOps();
      expect(ops.map((op) => op.opKey), contains('savejob_7'));
      expect(await restarted.getLocalSavedJobs(), isNotEmpty);
    });

    test('failed API never deletes the local save', () async {
      final repo = buildRepo(remote, local, network);
      remote.saveError = ServerException(
        errorModel: const ErrorModel(statusCode: 500, errorMessage: 'Down'),
      );

      final result = await repo.setSavedJob(savedJob(7));

      expect(result.isRight(), isTrue);
      expect(await repo.getLocalSavedJobs(), isNotEmpty);
      expect(await repo.getPendingOps(), hasLength(1));
    });

    test('rapid save then unsave keeps only the latest intent', () async {
      final repo = buildRepo(remote, local, network);
      network.connected = false;

      await repo.setSavedJob(savedJob(7));
      await repo.setUnsavedJob(7);

      expect(await repo.getLocalSavedJobs(), isEmpty);
      final ops = await repo.getPendingOps();
      expect(ops, hasLength(1));
      expect(ops.first.type, 'unsave');
    });

    test('duplicate saves never duplicate local records', () async {
      final repo = buildRepo(remote, local, network);
      network.connected = false;

      await repo.setSavedJob(savedJob(7));
      await repo.setSavedJob(savedJob(7));

      final jobs = await repo.getLocalSavedJobs();
      expect(jobs.where((job) => job.id == 7), hasLength(1));
    });
  });

  group('Background sync', () {
    test('replays queued save and clears it', () async {
      final repo = buildRepo(remote, local, network);
      network.connected = false;
      await repo.setSavedJob(savedJob(7));

      network.connected = true;
      final report = await repo.syncPendingOps();

      expect(report.succeeded, 1);
      expect(remote.saveCalls, 1);
      expect(await repo.getPendingOps(), isEmpty);
      // Local save retained after confirmation.
      expect(await repo.getLocalSavedJobs(), isNotEmpty);
    });

    test('already-saved 422 clears the op idempotently', () async {
      final repo = buildRepo(remote, local, network);
      network.connected = false;
      await repo.setSavedJob(savedJob(7));

      network.connected = true;
      remote.saveError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 422,
          errorMessage: 'Already saved.',
        ),
      );
      final report = await repo.syncPendingOps();

      expect(report.succeeded, 1);
      expect(await repo.getPendingOps(), isEmpty);
    });

    test('auth expiry stops the pass and keeps ops queued', () async {
      final repo = buildRepo(remote, local, network);
      network.connected = false;
      await repo.setUnsavedJob(7);

      network.connected = true;
      remote.unsaveError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 401,
          errorMessage: 'Unauthenticated or token expired.',
        ),
      );
      final report = await repo.syncPendingOps();

      expect(report.stoppedForAuth, isTrue);
      expect(await repo.getPendingOps(), hasLength(1));
    });

    test('server list overlays pending unsaves, never resurrects', () async {
      final repo = buildRepo(remote, local, network);
      remote.listResponse = PaginatedSavedJobsModel(
        jobs: [savedJob(7), savedJob(9)],
        currentPage: 1,
        lastPage: 1,
        total: 2,
        hasMorePages: false,
      );
      network.connected = false;
      await repo.setUnsavedJob(7);

      network.connected = true;
      final result = await repo.getSavedJobs();

      expect(result.isRight(), isTrue);
      final jobs = (result as Right).value.jobs;
      expect(jobs.map((job) => (job as SavedJobEntity).id), contains(9));
      expect(jobs.map((job) => (job as SavedJobEntity).id), isNot(contains(7)));
    });
  });

  group('SavedJobsCubit', () {
    SavedJobsCubit buildCubit(SavedJobsRepositoryImpl repo) => SavedJobsCubit(
      getSavedJobsUseCase: GetSavedJobsUseCase(repository: repo),
      setSavedJobUseCase: SetSavedJobUseCase(repository: repo),
      setUnsavedJobUseCase: SetUnsavedJobUseCase(repository: repo),
      syncSavedJobsUseCase: SyncSavedJobsUseCase(repository: repo),
    );

    test('toggle unsave updates UI + local immediately, offline', () async {
      final repo = buildRepo(remote, local, network);
      await local.upsertSavedJob(savedJob(7));
      network.connected = false;
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      cubit.emit(
        const SavedJobsLoaded(jobs: [], currentPage: 1, hasMore: false),
      );
      await cubit.fetchSavedJobs();

      final job = (cubit.state as SavedJobsLoaded).jobs.firstWhere(
        (j) => j.id == 7,
      );
      await cubit.toggleBookmark(job);

      final state = cubit.state as SavedJobsLoaded;
      expect(state.jobs.where((j) => j.id == 7), isEmpty);
      expect(await local.getLocalSavedJobs(), isEmpty);
      expect(await repo.getPendingOps(), hasLength(1));
    });

    test('toggle save adds the job immediately, offline', () async {
      final repo = buildRepo(remote, local, network);
      network.connected = false;
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      cubit.emit(
        const SavedJobsLoaded(jobs: [], currentPage: 1, hasMore: false),
      );

      await cubit.toggleBookmark(savedJob(8, isSaved: false));

      final state = cubit.state as SavedJobsLoaded;
      expect(state.jobs.map((j) => j.id), contains(8));
      expect((await local.getLocalSavedJobs()).map((j) => j.id), contains(8));
    });
  });

  group('JobsFeedCubit ledger path', () {
    test('toggle persists locally first and stays flipped offline', () async {
      final repo = buildRepo(remote, local, network);
      final jobsRepo = FakeJobsRepo();
      final cubit = JobsFeedCubit(
        getJobsUseCase: GetJobsUseCase(repository: jobsRepo),
        getCachedJobsUseCase: GetCachedJobsUseCase(repository: jobsRepo),
        searchJobsUseCase: SearchJobsUseCase(repository: jobsRepo),
        refreshJobsUseCase: RefreshJobsUseCase(repository: jobsRepo),
        toggleSaveJobUseCase: ToggleSaveJobUseCase(repository: jobsRepo),
        applyForJobUseCase: ApplyForJobUseCase(repository: jobsRepo),
        savedJobsRepository: repo,
      );
      addTearDown(cubit.close);
      cubit.emit(JobsFeedLoaded(jobs: [feedJob('7')]));
      network.connected = false;

      await cubit.toggleSaveJob('7');

      final state = cubit.state as JobsFeedLoaded;
      expect(state.jobs.first.isSaved, isTrue);
      expect((await local.getLocalSavedJobs()).map((j) => j.id), contains(7));
      expect(await repo.getPendingOps(), hasLength(1));
    });
  });
}
