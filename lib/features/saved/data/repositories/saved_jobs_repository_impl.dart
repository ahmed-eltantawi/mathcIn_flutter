import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_local_data_source.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source.dart';
import 'package:MatchIn/features/saved/domain/entities/paginated_saved_jobs_entity.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:dartz/dartz.dart';

class SavedJobsRepositoryImpl implements SavedJobsRepository {
  const SavedJobsRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
    required this.networkInfo,
  });

  final SavedJobsRemoteDataSource remoteDataSource;
  final SavedJobsLocalDataSource? localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedSavedJobsEntity>> getSavedJobs({
    int page = 1,
    int perPage = 15,
  }) async {
    final cacheKey = 'page_${page}_per_page_$perPage';

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getSavedJobs(
          page: page,
          perPage: perPage,
        );
        if (localDataSource != null) {
          await localDataSource!.cacheSavedJobs(cacheKey, result);
        }
        return Right(result);
      } on ServerException catch (e) {
        if (localDataSource != null) {
          final cached = await localDataSource!.getCachedSavedJobs(cacheKey);
          if (cached != null && cached.jobs.isNotEmpty) {
            return Right(cached);
          }
        }
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        if (localDataSource != null) {
          final cached = await localDataSource!.getCachedSavedJobs(cacheKey);
          if (cached != null && cached.jobs.isNotEmpty) {
            return Right(cached);
          }
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      if (localDataSource != null) {
        final cached = await localDataSource!.getCachedSavedJobs(cacheKey);
        if (cached != null) {
          return Right(cached);
        }
      }
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> saveJob({required int jobPostId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.saveJob(jobPostId: jobPostId);
        return Right(result.isSaved);
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
  Future<Either<Failure, bool>> unsaveJob({required int jobPostId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.unsaveJob(jobPostId: jobPostId);
        return Right(result.isSaved);
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
