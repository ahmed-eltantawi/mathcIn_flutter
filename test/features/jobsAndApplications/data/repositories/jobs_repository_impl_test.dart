import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_local_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/repositories/jobs_repository_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/company_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/job_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/job_pagination_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_jobs_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({this.connected = true});
  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class FakeJobsRemoteDataSource implements JobsRemoteDataSource {
  PaginatedJobsModel? responseModel;
  Object? errorToThrow;

  @override
  Future<PaginatedJobsModel> getJobs({JobFilterParams? params}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return responseModel!;
  }

  @override
  Future<JobEntity> applyForJob(String jobId) async {
    throw UnimplementedError();
  }

  @override
  Future<JobEntity> toggleSaveJob(String jobId) async {
    throw UnimplementedError();
  }
}

class FakeJobsLocalDataSource implements JobsLocalDataSource {
  final Map<String, PaginatedJobsModel> _storage = {};

  @override
  Future<void> cacheJobs(
      String cacheKey, PaginatedJobsModel paginatedJobs) async {
    _storage[cacheKey] = paginatedJobs;
  }

  @override
  Future<void> clearCachedJobs(String cacheKey) async {
    _storage.remove(cacheKey);
  }

  @override
  Future<PaginatedJobsModel?> getCachedJobs(String cacheKey) async {
    return _storage[cacheKey];
  }
}

void main() {
  late FakeNetworkInfo fakeNetworkInfo;
  late FakeJobsRemoteDataSource fakeRemoteDataSource;
  late FakeJobsLocalDataSource fakeLocalDataSource;
  late JobsRepositoryImpl repository;

  final testJobModel = JobModel(
    id: 1,
    title: 'Flutter Lead',
    company: const CompanyModel(id: 10, name: 'Google'),
    publishedAt: DateTime.now().toIso8601String(),
  );

  final testPaginatedModel = PaginatedJobsModel(
    data: [testJobModel],
    meta: const JobPaginationModel(
      currentPage: 1,
      lastPage: 1,
      perPage: 15,
      total: 1,
    ),
  );

  setUp(() {
    fakeNetworkInfo = FakeNetworkInfo(connected: true);
    fakeRemoteDataSource = FakeJobsRemoteDataSource();
    fakeLocalDataSource = FakeJobsLocalDataSource();
    repository = JobsRepositoryImpl(
      remoteDataSource: fakeRemoteDataSource,
      localDataSource: fakeLocalDataSource,
      networkInfo: fakeNetworkInfo,
    );
  });

  group('JobsRepositoryImpl Tests', () {
    test('getJobs returns Right(PaginatedJobsEntity) on remote success and caches result',
        () async {
      fakeRemoteDataSource.responseModel = testPaginatedModel;

      final result = await repository.getJobs(params: const JobFilterParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (paginatedEntity) {
          expect(paginatedEntity.jobs.length, equals(1));
          expect(paginatedEntity.jobs.first.title, equals('Flutter Lead'));
        },
      );

      final cached = await fakeLocalDataSource.getCachedJobs('default');
      expect(cached, isNotNull);
      expect(cached!.data.first.title, equals('Flutter Lead'));
    });

    test('getJobs returns Right(cachedData) when remote fails but cache exists',
        () async {
      await fakeLocalDataSource.cacheJobs('default', testPaginatedModel);
      fakeRemoteDataSource.errorToThrow = ServerException(
        errorModel: ErrorModel(statusCode: 500, errorMessage: 'Server Error'),
      );

      final result = await repository.getJobs(params: const JobFilterParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return cached Right data'),
        (paginatedEntity) {
          expect(paginatedEntity.jobs.length, equals(1));
          expect(paginatedEntity.jobs.first.title, equals('Flutter Lead'));
        },
      );
    });

    test('getJobs returns Left(ServerFailure) when remote fails and no cache exists',
        () async {
      fakeRemoteDataSource.errorToThrow = ServerException(
        errorModel: ErrorModel(statusCode: 500, errorMessage: 'Internal Error'),
      );

      final result = await repository.getJobs(params: const JobFilterParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Internal Error')),
        (_) => fail('Should return Left'),
      );
    });

    test('getJobs returns Left(OfflineFailure) when offline and no cache exists',
        () async {
      fakeNetworkInfo.connected = false;

      final result = await repository.getJobs(params: const JobFilterParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('You are offline')),
        (_) => fail('Should return Left'),
      );
    });
  });
}
