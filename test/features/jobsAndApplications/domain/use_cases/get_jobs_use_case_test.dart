import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_pagination_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeJobsRepository implements JobsRepository {
  Either<Failure, PaginatedJobsEntity>? resultToReturn;

  @override
  Future<Either<Failure, PaginatedJobsEntity>> getJobs({
    JobFilterParams? params,
  }) async {
    return resultToReturn!;
  }

  @override
  Future<Either<Failure, PaginatedJobsEntity>> searchJobs({
    required String query,
    JobFilterParams? params,
  }) async {
    return resultToReturn!;
  }

  @override
  Future<Either<Failure, PaginatedJobsEntity>> refreshJobs({
    JobFilterParams? params,
  }) async {
    return resultToReturn!;
  }

  @override
  Future<Either<Failure, PaginatedJobsEntity?>> getCachedJobs({
    JobFilterParams? params,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, JobEntity>> applyForJob(String jobId) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, JobEntity>> toggleSaveJob(String jobId,
      {bool? currentIsSaved}) async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeJobsRepository fakeRepository;
  late GetJobsUseCase getJobsUseCase;

  setUp(() {
    fakeRepository = FakeJobsRepository();
    getJobsUseCase = GetJobsUseCase(repository: fakeRepository);
  });

  group('GetJobsUseCase Tests', () {
    test('returns Right(PaginatedJobsEntity) on success', () async {
      final testEntity = PaginatedJobsEntity(
        jobs: [
          JobEntity(
            id: '1',
            title: 'Flutter Dev',
            companyName: 'MatchIn',
            location: 'Cairo',
            workMode: 'Remote',
            employmentType: 'Full-time',
            experienceLevel: 'Junior',
            postedDate: DateTime.now(),
            skills: const [],
            matchedSkills: const [],
            missingSkills: const [],
          ),
        ],
      );

      fakeRepository.resultToReturn = Right(testEntity);

      final result = await getJobsUseCase(params: const JobFilterParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be right'),
        (entity) => expect(entity.jobs.first.title, equals('Flutter Dev')),
      );
    });

    test('returns Left(ServerFailure) on repository failure', () async {
      fakeRepository.resultToReturn =
          const Left(ServerFailure(message: 'API Failure'));

      final result = await getJobsUseCase(params: const JobFilterParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('API Failure')),
        (_) => fail('Should be left'),
      );
    });
  });
}
