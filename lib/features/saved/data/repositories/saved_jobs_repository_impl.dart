import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source.dart';
import 'package:MatchIn/features/saved/domain/entities/paginated_saved_jobs_entity.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:dartz/dartz.dart';

class SavedJobsRepositoryImpl implements SavedJobsRepository {
  const SavedJobsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final SavedJobsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedSavedJobsEntity>> getSavedJobs({
    int page = 1,
    int perPage = 15,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getSavedJobs(
          page: page,
          perPage: perPage,
        );
        return Right(result);
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
