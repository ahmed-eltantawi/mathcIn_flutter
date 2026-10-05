import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_pagination_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/refresh_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/search_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeJobsRepository implements JobsRepository {
  Either<Failure, PaginatedJobsEntity>? getResult;
  Either<Failure, PaginatedJobsEntity?>? getCachedResult;
  Either<Failure, JobEntity>? toggleResult;
  Either<Failure, JobEntity>? applyResult;

  @override
  Future<Either<Failure, PaginatedJobsEntity>> getJobs({
    JobFilterParams? params,
  }) async =>
      getResult!;

  @override
  Future<Either<Failure, PaginatedJobsEntity>> searchJobs({
    required String query,
    JobFilterParams? params,
  }) async =>
      getResult!;

  @override
  Future<Either<Failure, PaginatedJobsEntity>> refreshJobs({
    JobFilterParams? params,
  }) async =>
      getResult!;

  @override
  Future<Either<Failure, PaginatedJobsEntity?>> getCachedJobs({
    JobFilterParams? params,
  }) async =>
      getCachedResult ?? const Right(null);

  @override
  Future<Either<Failure, JobEntity>> toggleSaveJob(String jobId) async =>
      toggleResult!;

  @override
  Future<Either<Failure, JobEntity>> applyForJob(String jobId) async =>
      applyResult!;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

JobEntity _makeJob({
  String id = '1',
  String title = 'Flutter Developer',
  bool isSaved = false,
}) =>
    JobEntity(
      id: id,
      title: title,
      companyName: 'MatchIn',
      location: 'Cairo, Egypt',
      workMode: 'Remote',
      employmentType: 'Full-time',
      experienceLevel: 'Junior',
      postedDate: DateTime(2026, 10, 1),
      skills: const ['Flutter', 'Dart'],
      matchedSkills: const ['Flutter'],
      missingSkills: const ['Dart'],
      isSaved: isSaved,
    );

PaginatedJobsEntity _makePaginated({
  List<JobEntity>? jobs,
  int currentPage = 1,
  int lastPage = 1,
}) =>
    PaginatedJobsEntity(
      jobs: jobs ?? [_makeJob()],
      pagination: JobPaginationEntity(
        currentPage: currentPage,
        lastPage: lastPage,
        perPage: 15,
        total: 15,
      ),
    );

JobsFeedCubit _makeCubit(FakeJobsRepository repo) {
  return JobsFeedCubit(
    getJobsUseCase: GetJobsUseCase(repository: repo),
    searchJobsUseCase: SearchJobsUseCase(repository: repo),
    refreshJobsUseCase: RefreshJobsUseCase(repository: repo),
    toggleSaveJobUseCase: ToggleSaveJobUseCase(repository: repo),
    applyForJobUseCase: ApplyForJobUseCase(repository: repo),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeJobsRepository repo;

  setUp(() {
    repo = FakeJobsRepository();
  });

  group('Initial loading', () {
    blocTest<JobsFeedCubit, JobsFeedState>(
      'emits [JobsFeedLoading, JobsFeedLoaded] on first fetch success',
      build: () {
        repo.getCachedResult = const Right(null);
        repo.getResult = Right(_makePaginated());
        return _makeCubit(repo);
      },
      act: (cubit) => cubit.getJobs(),
      expect: () => [
        const JobsFeedLoading(),
        isA<JobsFeedLoaded>(),
      ],
    );

    blocTest<JobsFeedCubit, JobsFeedState>(
      'emits [JobsFeedLoading, JobsFeedError] on first fetch failure with no cache',
      build: () {
        repo.getCachedResult = const Right(null);
        repo.getResult =
            const Left(ServerFailure(message: 'Server unavailable'));
        return _makeCubit(repo);
      },
      act: (cubit) => cubit.getJobs(),
      expect: () => [
        const JobsFeedLoading(),
        const JobsFeedError('Server unavailable'),
      ],
    );

    blocTest<JobsFeedCubit, JobsFeedState>(
      'emits [JobsFeedLoading, JobsFeedLoaded] with cached data when repository returns cache',
      build: () {
        repo.getResult = Right(
          PaginatedJobsEntity(
            jobs: [_makeJob(title: 'Cached Job')],
            isFromCache: true,
          ),
        );
        return _makeCubit(repo);
      },
      act: (cubit) => cubit.getJobs(),
      expect: () => [
        const JobsFeedLoading(),
        isA<JobsFeedLoaded>()
            .having((s) => s.isFromCache, 'isFromCache', isTrue)
            .having(
              (s) => s.jobs.first.title,
              'cached job title',
              'Cached Job',
            ),
      ],
    );
  });

  group('Success state', () {
    blocTest<JobsFeedCubit, JobsFeedState>(
      'JobsFeedLoaded contains jobs and pagination',
      build: () {
        repo.getCachedResult = const Right(null);
        repo.getResult = Right(_makePaginated(lastPage: 5));
        return _makeCubit(repo);
      },
      act: (cubit) => cubit.getJobs(),
      expect: () => [
        const JobsFeedLoading(),
        isA<JobsFeedLoaded>()
            .having((s) => s.jobs.isNotEmpty, 'has jobs', isTrue)
            .having(
              (s) => s.pagination?.lastPage,
              'last page is 5',
              5,
            ),
      ],
    );

    blocTest<JobsFeedCubit, JobsFeedState>(
      'emits JobsFeedEmpty when API returns empty list',
      build: () {
        repo.getCachedResult = const Right(null);
        repo.getResult = const Right(PaginatedJobsEntity(jobs: []));
        return _makeCubit(repo);
      },
      act: (cubit) => cubit.getJobs(),
      expect: () => [
        const JobsFeedLoading(),
        const JobsFeedEmpty(),
      ],
    );
  });

  group('Pagination', () {
    blocTest<JobsFeedCubit, JobsFeedState>(
      'loadMoreJobs appends new jobs to existing list',
      build: () {
        repo.getCachedResult = const Right(null);
        repo.getResult = Right(_makePaginated(
          jobs: [_makeJob(id: '2', title: 'Page 2 Job')],
          currentPage: 2,
          lastPage: 3,
        ));
        return _makeCubit(repo);
      },
      seed: () => JobsFeedLoaded(
        jobs: [_makeJob(id: '1', title: 'Page 1 Job')],
        pagination: const JobPaginationEntity(
          currentPage: 1,
          lastPage: 3,
          perPage: 15,
          total: 45,
        ),
      ),
      act: (cubit) => cubit.loadMoreJobs(),
      expect: () => [
        isA<JobsFeedLoaded>()
            .having((s) => s.isPaginationLoading, 'loading flag', isTrue),
        isA<JobsFeedLoaded>()
            .having((s) => s.jobs.length, 'total jobs count', 2)
            .having((s) => s.isPaginationLoading, 'not loading anymore', isFalse),
      ],
    );

    blocTest<JobsFeedCubit, JobsFeedState>(
      'loadMoreJobs does nothing when already on last page',
      build: () => _makeCubit(repo),
      seed: () => JobsFeedLoaded(
        jobs: [_makeJob()],
        pagination: const JobPaginationEntity(
          currentPage: 3,
          lastPage: 3,
          perPage: 15,
          total: 45,
        ),
      ),
      act: (cubit) => cubit.loadMoreJobs(),
      expect: () => [],
    );
  });

  group('Refresh', () {
    blocTest<JobsFeedCubit, JobsFeedState>(
      'refreshJobs resets to page 1 and replaces feed',
      build: () {
        repo.getCachedResult = const Right(null);
        repo.getResult = Right(_makePaginated(jobs: [_makeJob(title: 'Refreshed Job')]));
        return _makeCubit(repo);
      },
      seed: () => JobsFeedLoaded(
        jobs: [_makeJob(title: 'Old Job')],
        pagination: const JobPaginationEntity(
          currentPage: 2,
          lastPage: 5,
          perPage: 15,
          total: 75,
        ),
      ),
      act: (cubit) => cubit.refreshJobs(),
      expect: () => [
        isA<JobsFeedLoaded>().having((s) => s.isRefreshing, 'refreshing flag set', isTrue),
        isA<JobsFeedLoaded>()
            .having((s) => s.jobs.first.title, 'has refreshed job', 'Refreshed Job')
            .having((s) => s.isRefreshing, 'refreshing flag cleared', isFalse),
      ],
    );
  });

  group('Filter / Search changes', () {
    blocTest<JobsFeedCubit, JobsFeedState>(
      'applyFilterParams resets page to 1 and re-fetches',
      build: () {
        repo.getCachedResult = const Right(null);
        repo.getResult = Right(_makePaginated(jobs: [_makeJob(title: 'Remote Job')]));
        return _makeCubit(repo);
      },
      act: (cubit) => cubit.applyFilterParams(
        const JobFilterParams(workMode: 'Remote', page: 3),
      ),
      expect: () => [
        const JobsFeedLoading(),
        isA<JobsFeedLoaded>()
            .having((s) => s.jobs.first.title, 'remote job', 'Remote Job')
            .having(
              (s) => s.filterParams?.workMode,
              'work mode filter applied',
              'Remote',
            )
            .having(
              (s) => s.filterParams?.page,
              'page reset to 1',
              1,
            ),
      ],
    );
  });

  group('toggleSaveJob', () {
    blocTest<JobsFeedCubit, JobsFeedState>(
      'toggleSaveJob updates isSaved in the existing jobs list',
      build: () {
        repo.toggleResult = Right(_makeJob(id: '1', isSaved: true));
        return _makeCubit(repo);
      },
      seed: () => JobsFeedLoaded(
        jobs: [_makeJob(id: '1', isSaved: false)],
      ),
      act: (cubit) => cubit.toggleSaveJob('1'),
      expect: () => [
        isA<JobsFeedLoaded>()
            .having((s) => s.jobs.first.isSaved, 'isSaved toggled to true', isTrue),
      ],
    );
  });
}
