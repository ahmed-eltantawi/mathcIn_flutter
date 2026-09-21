import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  const JobsRepositoryImpl({
    required this.remoteDataSource,
  });

  final JobsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs() async {
    try {
      final jobs = await remoteDataSource.getJobs();
      return Right(jobs);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> toggleSaveJob(
    String jobId,
  ) async {
    try {
      final job = await remoteDataSource.toggleSaveJob(
        jobId,
      );
      return Right(job);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> applyForJob(
    String jobId,
  ) async {
    try {
      final job = await remoteDataSource.applyForJob(jobId);
      return Right(job);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
