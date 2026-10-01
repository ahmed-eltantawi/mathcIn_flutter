import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_local_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_pagination_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  const JobsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final JobsRemoteDataSource remoteDataSource;
  final JobsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedJobsEntity>> getJobs({
    JobFilterParams? params,
  }) async {
    final cacheKey = params?.toCacheKey() ?? 'default';

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getJobs(params: params);
        await localDataSource.cacheJobs(cacheKey, result);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        final cached = await localDataSource.getCachedJobs(cacheKey);
        if (cached != null && cached.data.isNotEmpty) {
          return Right(cached.toEntity());
        }
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        final cached = await localDataSource.getCachedJobs(cacheKey);
        if (cached != null && cached.data.isNotEmpty) {
          return Right(cached.toEntity());
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final cached = await localDataSource.getCachedJobs(cacheKey);
      if (cached != null && cached.data.isNotEmpty) {
        return Right(cached.toEntity());
      }
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedJobsEntity?>> getCachedJobs({
    JobFilterParams? params,
  }) async {
    try {
      final cacheKey = params?.toCacheKey() ?? 'default';
      final cached = await localDataSource.getCachedJobs(cacheKey);
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> toggleSaveJob(
    String jobId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final job = await remoteDataSource.toggleSaveJob(jobId);
        return Right(job);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, JobEntity>> applyForJob(
    String jobId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final job = await remoteDataSource.applyForJob(jobId);
        return Right(job);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }
}
